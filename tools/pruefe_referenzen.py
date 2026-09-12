#!/usr/bin/env python3
"""
Querverweispruefung fuer den Oberflaechencode.

Prueft drei Dinge, die eine reine Schemapruefung NICHT findet:
  1. Jeder Verweis der Form <Steuerelement>.<Eigenschaft> zeigt auf ein
     Steuerelement, das in derselben Datei definiert ist.
  2. Jede benannte Formel (clr..., sp..., fs..., bp..., cfg..., rad..., h...,
     recEinstellungen) ist in der Liste der in App.Formulas definierten Namen
     enthalten - sonst fehlt sie spaeter in Power Apps Studio.
  3. Jede globale Variable gbl... wird mindestens einmal mit Set() gesetzt
     und mindestens einmal gelesen.

Auch das ersetzt keine Power-Apps-Kompilierung: Ob eine Eigenschaft fuer
genau diesen Control-Typ zulaessig ist, prueft nur Studio selbst.
"""
from __future__ import annotations
import re
import sys
import pathlib

def lies_definitionen(pfad: pathlib.Path) -> tuple[set[str], set[str]]:
    """Liest die benannten Formeln und die OnStart-Variablen aus der
    Eigenschaften-Datei.

    Dadurch pflegt sich der Pruefer selbst: Wird in App.Formulas eine Farbe
    ergaenzt oder entfernt, muss hier nichts nachgetragen werden. Genau diese
    Doppelpflege war vorher eine Fehlerquelle.
    """
    text = pfad.read_text(encoding="utf-8")
    bloecke = re.findall(r"```powerfx\n(.*?)\n```", text, re.S)
    formeln: set[str] = set()
    variablen: set[str] = set()
    for b in bloecke:
        ohne_kommentar = "\n".join(
            z for z in b.split("\n") if not z.lstrip().startswith("//")
        )
        # "name = ausdruck;" am Zeilenanfang -> benannte Formel
        formeln |= set(re.findall(r"^\s*([A-Za-z][A-Za-z0-9]*)\s*=", ohne_kommentar, re.M))
        variablen |= set(re.findall(r"Set\(\s*(gbl[A-Za-z0-9_]*)", ohne_kommentar))
    # Zuweisungen innerhalb von Set(...) sind keine benannten Formeln.
    formeln -= variablen
    return formeln, variablen


# Power-Fx-Bezeichner, die vor einem Punkt stehen duerfen, ohne Steuerelement zu sein.
KEINE_STEUERELEMENTE = {
    "Parent", "Self", "ThisItem", "ThisRecord", "App", "Acceleration", "Compass",
    "Location", "Connection", "Host", "Param", "Color", "Icon", "Align",
    "VerticalAlign", "FontWeight", "DisplayMode", "TextMode", "TextFormat",
    "Layout", "LayoutMode", "LayoutDirection", "LayoutAlignItems", "LayoutOverflow",
    "LayoutJustifyContent", "BorderStyle", "SortOrder", "TimeUnit", "ScreenTransition",
    "DateTimeFormat", "Live", "FirstError", "Behandlungsdokumentation", "Rezepte",
    "Patientenstamm", "AufgabenEinstellungen", "DataSourceInfo", "Notify",
    "NotificationType", "Errors", "ErrorKind",
}


def main(pfad_text: str, eigenschaften_text: str) -> int:
    pfad = pathlib.Path(pfad_text)
    BENANNTE_FORMELN, IN_ONSTART_GESETZT = lies_definitionen(pathlib.Path(eigenschaften_text))
    text = pfad.read_text(encoding="utf-8")

    # Kommentarzeilen ausblenden, damit Beispiele in Kommentaren nichts ausloesen.
    ohne_kommentar = "\n".join(
        z for z in text.split("\n") if not z.lstrip().startswith(("#", "//"))
    )
    # Zeichenketten ausblenden: deutscher Anzeigetext wie "spaeter" oder
    # "speichern" ist kein Bezeichner und darf keine Meldung ausloesen.
    # In Power Fx wird ein Anfuehrungszeichen durch Verdoppelung geschrieben.
    ohne_kommentar = re.sub(r'"(?:[^"]|"")*"', '""', ohne_kommentar)

    # Definierte Steuerelemente: "- Name:" gefolgt von "Control:"
    definierte = set(
        re.findall(r"^\s*-\s+([A-Za-z][A-Za-z0-9_]*):\s*$\n\s+Control:", text, re.M)
    )
    definierte |= set(
        re.findall(r'^\s*-\s+"([^"]+)":\s*$\n\s+Control:', text, re.M)
    )

    fehler: list[str] = []

    # --- 1. Steuerelementverweise -----------------------------------
    praefixe = ("con", "lbl", "btn", "txt", "gal", "drp", "chk", "dp", "rect", "ico", "img", "scr")
    verweise = set(re.findall(r"\b([a-z][A-Za-z0-9_]*)\.[A-Za-z]", ohne_kommentar))
    for name in sorted(verweise):
        if not name.startswith(praefixe):
            continue
        if name in KEINE_STEUERELEMENTE or name in definierte:
            continue
        fehler.append(f"Verweis auf unbekanntes Steuerelement: {name}")

    # --- 2. Benannte Formeln ----------------------------------------
    kandidaten = set(
        re.findall(r"\b((?:clr|sp|rad|fs|bp|cfg|rec)[A-Za-z0-9]*)\b", ohne_kommentar)
    ) | set(re.findall(r"\b(hTouch|hEingabe)\b", ohne_kommentar))
    for name in sorted(kandidaten):
        if name in definierte or name in KEINE_STEUERELEMENTE:
            continue
        if name not in BENANNTE_FORMELN:
            fehler.append(f"Benannte Formel wird verwendet, ist aber nicht definiert: {name}")

    nicht_genutzt = sorted(
        n for n in BENANNTE_FORMELN if not re.search(rf"\b{re.escape(n)}\b", ohne_kommentar)
    )

    # --- 3. Globale Variablen ---------------------------------------
    gesetzt = set(re.findall(r"Set\(\s*(gbl[A-Za-z0-9_]*)\s*,", ohne_kommentar)) | IN_ONSTART_GESETZT
    gelesen = set(re.findall(r"\b(gbl[A-Za-z0-9_]*)\b", ohne_kommentar))
    for name in sorted(gelesen - gesetzt):
        fehler.append(f"Variable wird gelesen, aber nirgends gesetzt: {name}")
    nie_gelesen = sorted(n for n in gesetzt if n not in gelesen)

    # --- Ausgabe ----------------------------------------------------
    print(f"Datei: {pfad}")
    print(f"  definierte Steuerelemente : {len(definierte)}")
    print(f"  geprüfte Verweise         : {len(verweise)}")
    print(f"  benannte Formeln in Nutzung: {len(kandidaten & BENANNTE_FORMELN)}")
    print(f"  globale Variablen          : {len(gelesen)}")
    if nicht_genutzt:
        print(f"  Hinweis: definiert, aber ungenutzt: {', '.join(nicht_genutzt)}")
    if nie_gelesen:
        print(f"  Hinweis: gesetzt, aber nie gelesen: {', '.join(nie_gelesen)}")
    print()
    for f in fehler:
        print(f"FEHLER  {f}")
    if fehler:
        print(f"\nErgebnis: {len(fehler)} Fehler.")
        return 1
    print("Ergebnis: alle Verweise aufloesbar.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
