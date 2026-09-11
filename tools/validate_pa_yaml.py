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
  Geprueft wird ausschliesslich die YAML-Struktur, die Control-Typen und die
  Formel-Schreibweise (jede Eigenschaft muss mit "=" beginnen).
  NICHT geprueft wird, ob eine Power-Fx-Formel kompiliert, ob eine Spalte in
  SharePoint existiert oder ob eine Eigenschaft fuer genau diesen Control-Typ
  zulaessig ist. Das leistet nur Power Apps Studio selbst.

Aufruf:  python3 tools/validate_pa_yaml.py <datei.yaml> [...]
         python3 tools/validate_pa_yaml.py --fragment <datei.yaml>   (Control-Liste ohne Screens:)
"""
from __future__ import annotations
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
    schema["definitions"]["ControlTypeId-1P-controls-enum"] = {"enum": enum_schema["enum"]}

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

        controls = sammle_controls(kinder)
        if schema_ok and not formelfehler:
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
