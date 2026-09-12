#!/usr/bin/env python3
"""
Statische Pruefung von Power-Apps-Canvas-YAML gegen das offizielle Schema v3.0.

Quellen (unveraendert mitgeliefert in diesem Ordner):
  - pa.schema.v3.0.yaml
        https://raw.githubusercontent.com/microsoft/PowerApps-Tooling/
        refs/heads/master/schemas/pa-yaml/v3.0/pa.schema.yaml
  - ControlTypeId-1P-controls-enum.schema.yaml
        microsoft/PowerApps-Tooling, src/schemas/pa-yaml/v3.0/ControlLibraryVDev/

WICHTIG / Grenze dieser Pruefung:
  Geprueft wird ausschliesslich die YAML-Struktur, die Control-Typen, die
  Control-Varianten und die Formel-Schreibweise (jede Eigenschaft muss mit
  "=" beginnen).
  NICHT geprueft wird, ob eine Power-Fx-Formel kompiliert, ob eine Spalte in
  SharePoint existiert oder ob eine Eigenschaft fuer genau diesen Control-Typ
  zulaessig ist. Das leistet nur Power Apps Studio selbst.

Aufruf:  python3 tools/validate_pa_yaml.py <datei.yaml> [...]
         python3 tools/validate_pa_yaml.py --fragment <datei.yaml>   (Control-Liste ohne Screens:)
"""
from __future__ import annotations
import re
import sys
import pathlib
import yaml
import jsonschema

HIER = pathlib.Path(__file__).resolve().parent


def lade_schema() -> dict:
    schema = yaml.safe_load((HIER / "pa.schema.v3.0.yaml").read_text(encoding="utf-8"))
    enum_datei = HIER / "ControlTypeId-1P-controls-enum.schema.yaml"
    enum_schema = yaml.safe_load(enum_datei.read_text(encoding="utf-8"))
    # Im Original ist ControlTypeId-1P-controls-enum als "true" hinterlegt (Platzhalter).
    # Wir setzen die echte Control-Liste ein, damit falsche Control-Typen auffallen.
    controls = list(enum_schema["enum"])
    # Die veroeffentlichte Liste kennt aus dem Classic-Namensraum nur
    # "Classic/Icon". Power Apps Studio akzeptiert dort aber die gesamte
    # klassische Familie - belegt durch den Tenant-Test vom 11.09.2026:
    # "Classic/Icon" lief fehlerfrei durch, waehrend die blanken Namen
    # Button, TextInput, DropDown, DatePicker und CheckBox auf die MODERNEN
    # Controls aufloesen und deren abweichende Eigenschaften verlangen.
    controls += [
        "Classic/Button", "Classic/TextInput", "Classic/DropDown",
        "Classic/DatePicker", "Classic/CheckBox", "Classic/ComboBox",
        "Classic/Toggle", "Classic/Radio", "Classic/Slider", "Classic/ListBox",
    ]
    schema["definitions"]["ControlTypeId-1P-controls-enum"] = {"enum": controls}

    # BEFUND im offiziellen Schema (Stand des mitgelieferten Abzugs):
    # "CodeComponent-ComponentName".pattern ist ein ungueltiger regulaerer Ausdruck
    #   ^([a-zA-Z][a-zA-Z0-9]{1,7})_)?(\w+\.)+(\w+)(\([0-9a-f-]{36}\))?$
    # -> eine schliessende Klammer ohne oeffnende. Python lehnt das Schema deshalb ab.
    # Wir reparieren genau dieses eine Muster (fehlende oeffnende Klammer), damit die
    # uebrige Pruefung laufen kann. Diese App verwendet keine Code-Komponenten (PCF),
    # die Korrektur hat also keinen Einfluss auf das Ergebnis.
    schema["definitions"]["CodeComponent-ComponentName"]["pattern"] = (
        r"^(([a-zA-Z][a-zA-Z0-9]{1,7})_)?(\w+\.)+(\w+)(\([0-9a-f-]{36}\))?$"
    )
    return schema


# Varianten, die Power Apps Studio im SOURCE-CODE-Schema akzeptiert.
# Die Liste stammt aus der Fehlermeldung von Studio selbst (PA2109s nennt die
# gueltigen Alternativen). Sie ist bewusst kurz: Eingetragen wird nur, was
# tatsaechlich belegt ist.
ERLAUBTE_VARIANTEN = {
    "GroupContainer": {"GridLayout", "AutoLayout", "ManualLayout"},
}

# Control-Typen, bei denen Studio eine Variante ZWINGEND verlangt (PA1011).
VARIANTE_PFLICHT = {"Gallery"}

# Eigenschaften, die Studio fuer eine Kombination aus Control-Typ und Variante
# ablehnt (PA2108). Aus dem Tenant-Test vom 11.09.2026.
VERBOTENE_EIGENSCHAFTEN = {
    # Die Variante legt den Layoutmodus bereits fest.
    ("GroupContainer", "AutoLayout"): {"LayoutMode"},
    # Die Variante legt die Laufrichtung bereits fest; eine Eigenschaft
    # "Layout" gibt es bei der Galerie nicht.
    ("Gallery", "Vertical"): {"Layout"},
    ("Gallery", "Horizontal"): {"Layout"},
}

# Eigenschaften, die ein Control-Typ unabhaengig von der Variante nicht kennt.
VERBOTEN_JE_TYP = {
    # Die Anzeigespalte wird nicht ueber "Value" gewaehlt. Stattdessen die
    # Liste mit ShowColumns auf eine Spalte reduzieren.
    "Classic/DropDown": {"Value"},
}

# Die blanken Namen loesen auf die MODERNEN Controls auf. Wer dort die
# klassischen Eigenschaften verwendet, bekommt PA2108. Diese Liste nennt je
# Control-Typ die Eigenschaften, die dann fehlschlagen - und damit zugleich
# den Hinweis, dass "Classic/<Name>" gemeint war.
MODERNE_CONTROLS_OHNE = {
    "Button": {"Fill", "Color", "HoverFill", "HoverColor", "PressedFill",
               "PressedColor", "DisabledFill", "DisabledColor", "Size",
               "RadiusTopLeft", "RadiusTopRight", "RadiusBottomLeft",
               "RadiusBottomRight"},
    "TextInput": {"Default", "HintText", "Reset", "DelayOutput", "Format",
                  "Size", "RadiusTopLeft", "RadiusTopRight",
                  "RadiusBottomLeft", "RadiusBottomRight"},
    "DatePicker": {"DefaultDate", "Reset", "StartYear", "Size"},
    "DropDown": {"Default", "Reset", "Size", "Value"},
    "CheckBox": {"Text", "Default", "Reset", "Size", "Color"},
}


def pruefe_varianten(knoten, pfad="", fehler=None):
    """Findet Varianten aus dem alten Early-Preview-Format.

    Studio meldet solche Varianten mit PA2109s ("Unknown variant") und
    PA4102 ("Early Preview code detected") - und zwar erst beim Einfuegen.
    Diese Pruefung zieht den Befund nach vorne.

    Merkmal: Early-Preview-Varianten beginnen klein und sind camelCase
    (horizontalAutoLayoutContainer, galleryVertical, textualEditCard).
    Source-Code-Varianten sind PascalCase (AutoLayout, ManualLayout).
    """
    if fehler is None:
        fehler = []
    if isinstance(knoten, list):
        for eintrag in knoten:
            if not isinstance(eintrag, dict):
                continue
            for name, inhalt in eintrag.items():
                if not isinstance(inhalt, dict):
                    continue
                p = f"{pfad}/{name}"
                typ = (inhalt.get("Control") or "").split("@")[0]
                eigenschaften = set((inhalt.get("Properties") or {}).keys())
                variante = inhalt.get("Variant")

                if typ in VARIANTE_PFLICHT and not variante:
                    fehler.append(
                        f"{p}: Control-Typ {typ!r} verlangt zwingend eine Variante "
                        f"(Studio meldet sonst PA1011)."
                    )

                verboten = set(VERBOTENE_EIGENSCHAFTEN.get((typ, variante or ""), set()))
                verboten |= VERBOTEN_JE_TYP.get(typ, set())
                for e in sorted(eigenschaften & verboten):
                    fehler.append(
                        f"{p}: Eigenschaft {e!r} ist fuer {typ!r} mit Variante "
                        f"{variante!r} nicht zulaessig (PA2108)."
                    )

                klassisch = MODERNE_CONTROLS_OHNE.get(typ, set())
                treffer = sorted(eigenschaften & klassisch)
                if treffer:
                    fehler.append(
                        f"{p}: {typ!r} loest auf das MODERNE Control auf, aber "
                        f"{', '.join(treffer)} sind Eigenschaften des klassischen. "
                        f"Vermutlich ist 'Classic/{typ}' gemeint."
                    )

                if isinstance(variante, str) and variante:
                    erlaubt = ERLAUBTE_VARIANTEN.get(typ)
                    if erlaubt is not None and variante not in erlaubt:
                        fehler.append(
                            f"{p}: Variante {variante!r} ist fuer Control-Typ {typ!r} "
                            f"nicht zulaessig. Erlaubt: {', '.join(sorted(erlaubt))}"
                        )
                    elif erlaubt is None and variante[:1].islower():
                        fehler.append(
                            f"{p}: Variante {variante!r} sieht nach dem alten "
                            f"Early-Preview-Format aus (beginnt klein). Studio lehnt das "
                            f"beim Einfuegen ab. Variante weglassen oder den "
                            f"Source-Code-Namen verwenden."
                        )
                pruefe_varianten(inhalt.get("Children"), p, fehler)
    return fehler


def pruefe_mehrfachformeln(text: str) -> list[str]:
    """Findet Eigenschaften, die MEHR ALS EINE Formel enthalten.

    Ein Blockskalar darf genau eine Power-Fx-Formel enthalten. Stehen dort
    zwei Formeln untereinander, ist das gueltiges YAML und beginnt mit "=" -
    die Schemapruefung merkt also nichts. Power Apps meldet es erst beim
    Einfuegen, und in der Oberflaeche steht danach an jedem betroffenen
    Steuerelement ein Fehler.

    Genau so ein Schaden entstand am 11.09.2026 durch eine Massenersetzung,
    die eine Zeile an JEDES "DisplayMode: |-" anhaengte - auch dort, wo
    bereits eine Formel stand. 16 Steuerelemente waren betroffen.
    """
    zeilen = text.split("\n")
    fehler: list[str] = []
    i = 0
    while i < len(zeilen):
        m = re.match(r"^(\s*)([A-Za-z][A-Za-z0-9]*): \|-\s*$", zeilen[i])
        if not m:
            i += 1
            continue
        einzug, eigenschaft = m.group(1), m.group(2)
        j, formeln = i + 1, []
        while j < len(zeilen) and (
            not zeilen[j].strip() or len(zeilen[j]) - len(zeilen[j].lstrip()) > len(einzug)
        ):
            if zeilen[j].lstrip().startswith("="):
                formeln.append((j + 1, zeilen[j].strip()))
            j += 1
        if len(formeln) > 1:
            orte = ", ".join(f"Zeile {nr}" for nr, _ in formeln)
            fehler.append(
                f"Eigenschaft {eigenschaft!r} enthaelt {len(formeln)} Formeln ({orte}). "
                f"Erlaubt ist genau eine."
            )
        i = j
    return fehler


def sammle_controls(knoten, pfad="", treffer=None):
    """Laeuft durch Children-Listen und sammelt (Pfad, Control-Typ)."""
    if treffer is None:
        treffer = []
    if isinstance(knoten, list):
        for eintrag in knoten:
            if isinstance(eintrag, dict):
                for name, inhalt in eintrag.items():
                    if isinstance(inhalt, dict):
                        p = f"{pfad}/{name}"
                        treffer.append((p, inhalt.get("Control")))
                        sammle_controls(inhalt.get("Children"), p, treffer)
    return treffer


def pruefe_formeln(knoten, pfad="", fehler=None):
    """Jede Eigenschaft muss ein String sein, der mit '=' beginnt (oder null)."""
    if fehler is None:
        fehler = []
    if isinstance(knoten, list):
        for eintrag in knoten:
            if isinstance(eintrag, dict):
                for name, inhalt in eintrag.items():
                    if isinstance(inhalt, dict):
                        p = f"{pfad}/{name}"
                        for prop, wert in (inhalt.get("Properties") or {}).items():
                            if wert is None:
                                continue
                            if not isinstance(wert, str) or not wert.startswith("="):
                                fehler.append(f"{p}.{prop}: Formel beginnt nicht mit '=' -> {wert!r}")
                        pruefe_formeln(inhalt.get("Children"), p, fehler)
    return fehler


def main(argv: list[str]) -> int:
    fragment = "--fragment" in argv
    dateien = [a for a in argv[1:] if not a.startswith("--")]
    if not dateien:
        print(__doc__)
        return 2

    schema = lade_schema()
    gesamt_fehler = 0

    for name in dateien:
        pfad = pathlib.Path(name)
        text = pfad.read_text(encoding="utf-8")
        try:
            daten = yaml.safe_load(text)
        except yaml.YAMLError as exc:
            print(f"FEHLER  {pfad}: kein gueltiges YAML -> {exc}")
            gesamt_fehler += 1
            continue

        ist_fragment = fragment or isinstance(daten, list)
        if ist_fragment:
            # Control-Liste ohne Screens:-Wrapper -> zum Pruefen in einen Screen huellen.
            pruefling = {"Screens": {"PruefScreen": {"Children": daten}}}
            kinder = daten
        else:
            pruefling = daten
            kinder = []
            for screen in (daten.get("Screens") or {}).values():
                kinder.extend(screen.get("Children") or [])

        try:
            jsonschema.validate(pruefling, schema)
            schema_ok = True
        except jsonschema.ValidationError as exc:
            ort = "/".join(str(p) for p in exc.absolute_path)
            print(f"FEHLER  {pfad}: Schema -> {exc.message}")
            print(f"        Ort: {ort or '(Wurzel)'}")
            schema_ok = False
            gesamt_fehler += 1

        formelfehler = pruefe_formeln(kinder)
        for f in formelfehler:
            print(f"FEHLER  {pfad}: {f}")
        gesamt_fehler += len(formelfehler)

        mehrfachfehler = pruefe_mehrfachformeln(text)
        for f in mehrfachfehler:
            print(f"FEHLER  {pfad}: {f}")
        gesamt_fehler += len(mehrfachfehler)

        variantenfehler = pruefe_varianten(kinder)
        for f in variantenfehler:
            print(f"FEHLER  {pfad}: {f}")
        gesamt_fehler += len(variantenfehler)

        controls = sammle_controls(kinder)
        if schema_ok and not formelfehler and not variantenfehler and not mehrfachfehler:
            art = "Control-Fragment" if ist_fragment else "vollstaendiger Bildschirm"
            print(f"OK      {pfad}  ({art}, {len(controls)} Controls)")

    print()
    if gesamt_fehler:
        print(f"Ergebnis: {gesamt_fehler} Fehler.")
        return 1
    print("Ergebnis: alle Dateien bestehen die statische Schemapruefung.")
    print("Hinweis: Das ersetzt keine Power-Apps-Kompilierung und keinen Tenant-Test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
