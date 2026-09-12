#!/usr/bin/env python3
"""
Abgleich zwischen Oberflaechencode und Feldzuordnung.

Jede SharePoint-Spalte, die der Oberflaechencode anspricht, muss in
03_Schema_Mapping.json stehen - und umgekehrt soll die Zuordnung keine
Spalten auffuehren, die nirgends verwendet werden, ohne dass das auffaellt.

So bleibt die Dokumentation mit dem Code in Deckung. Ein Tippfehler in einem
Spaltennamen faellt hier auf, nicht erst zur Laufzeit in der Praxis.

Aufruf: python3 tools/pruefe_felder.py output/01_AppShell_einfuegen.yaml output/03_Schema_Mapping.json
"""
from __future__ import annotations
import json
import pathlib
import re
import sys

# Eigenschaften von Steuerelementen, Datensaetzen und Power-Fx-Objekten.
# Das sind KEINE SharePoint-Spalten.
KEINE_SPALTEN = {
    "ID", "Value", "Text", "Selected", "SelectedDate", "SelectedText", "AllItems",
    "Width", "Height", "TemplateWidth", "TemplateHeight", "IsSelected", "Message",
    "FullName", "Email", "Connected", "Result", "DisplayName", "Claims",
    "Department", "JobTitle", "Picture", "Error", "Default", "DisplayMode",
    "AllItemsCount", "Size", "X", "Y", "Visible", "Fill", "Color",
    # Felder der App-internen Navigationstabelle Table({Bez: ..., Sym: ...}) -
    # kein SharePoint, sondern im Code erzeugte Zeilen.
    "Bez", "Sym",
}

# Datensatzvariablen, deren Eigenschaften SharePoint-Spalten sind.
DATENSATZ_VARIABLEN = ("gblPatient", "gblRezept", "gblDoku", "gblAufgabe",
                       "recEinstellungen", "ThisItem", "gblSchreibErgebnis")


def main(yaml_pfad: str, json_pfad: str) -> int:
    text = pathlib.Path(yaml_pfad).read_text(encoding="utf-8")
    zuordnung = json.loads(pathlib.Path(json_pfad).read_text(encoding="utf-8"))

    bekannt: set[str] = set()
    for felder in zuordnung["listen"].values():
        for f in felder:
            bekannt.add(f["anzeigename"])
    # In der Zuordnung steht eine Sammelzeile fuer das ungeklaerte Titelfeld.
    bekannt.add("Title")

    # Kommentare entfernen - dort stehen Erlaeuterungen, keine echten Verweise.
    code = "\n".join(z for z in text.split("\n") if not z.lstrip().startswith(("#", "//")))

    verwendet: dict[str, str] = {}

    # Zeichenketten ausblenden, BEVOR nach Spalten in einfachen
    # Anfuehrungszeichen gesucht wird. Sonst gelten auch SVG-Attribute wie
    # stroke='#9C9C9C' oder d='M22 13 L68 10' als Spaltennamen - einfache
    # Anfuehrungszeichen INNERHALB eines Power-Fx-Strings sind nie Spalten.
    ohne_strings = re.sub(r'"(?:[^"]|"")*"', '""', code)

    # 1) Spalten in einfachen Anfuehrungszeichen, z. B. 'Diagnose laut Rezept'
    for name in re.findall(r"'([A-Za-zÄÖÜäöüß][A-Za-z0-9 ÄÖÜäöüß]*)'", ohne_strings):
        verwendet.setdefault(name, "in Anfuehrungszeichen")

    # 2) Eigenschaften von Datensatzvariablen, z. B. gblRezept.Behandlungseinheiten
    for var in DATENSATZ_VARIABLEN:
        for name in re.findall(rf"\b{var}\.([A-Za-z][A-Za-z0-9]*)", code):
            if name not in KEINE_SPALTEN:
                verwendet.setdefault(name, f"{var}.{name}")

    # 3) Feldnamen in Patch-Datensaetzen, z. B. "PatientID: gblPatient.ID,"
    for zeile in code.split("\n"):
        m = re.match(r"^\s{20,}([A-Za-z][A-Za-z0-9]*):\s+\S", zeile)
        if m and zeile.rstrip().endswith((",", "{")):
            name = m.group(1)
            if name not in KEINE_SPALTEN:
                verwendet.setdefault(name, "Patch-Datensatz")

    fehlend = sorted(n for n in verwendet if n not in bekannt)
    unbenutzt = sorted(
        n for n in bekannt
        if n not in verwendet and not re.search(rf"\b{re.escape(n)}\b", code)
    )

    print(f"Oberflaechencode : {yaml_pfad}")
    print(f"Feldzuordnung    : {json_pfad}")
    print(f"  Spalten in der Zuordnung : {len(bekannt)}")
    print(f"  Spalten im Code          : {len(verwendet)}")
    if unbenutzt:
        print(f"  Nur dokumentiert, nicht in der Oberflaeche verwendet "
              f"({len(unbenutzt)}): {', '.join(unbenutzt)}")
        print("    (erwartet: Zaehlerfelder und Flow-Felder werden von Power Automate")
        print("     geschrieben, nicht von der App)")
    print()
    for n in fehlend:
        print(f"FEHLER  Spalte im Code, aber nicht in der Feldzuordnung: {n}  ({verwendet[n]})")
    if fehlend:
        print(f"\nErgebnis: {len(fehlend)} Fehler.")
        return 1
    print("Ergebnis: jede vom Code angesprochene Spalte ist dokumentiert.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
