#!/usr/bin/env python3
"""
Abgleich der Auswahlwerte (Choice) zwischen Oberflaechencode und Einrichtung.

Schreibt die App einen Auswahlwert, den es in SharePoint nicht gibt, schlaegt
der Schreibvorgang zur Laufzeit fehl - in der Praxis, waehrend der Behandlung.
Diese Pruefung faengt das vorher ab.

Unterschieden wird:
  GESCHRIEBEN   { Value: "..." }      -> muss als Auswahlwert existieren
  VERGLICHEN    Spalte.Value = "..."  -> muss als Auswahlwert existieren
  ERSATZTEXT    Coalesce(..., "...")  -> nur Anzeige bei leerem Feld,
                                         muss NICHT existieren

Aufruf:
  python3 tools/pruefe_auswahlwerte.py output/01_AppShell_einfuegen.yaml \
      output/04_Setup/Schema-Ergaenzungen.json
"""
from __future__ import annotations
import json
import pathlib
import re
import sys


def main(yaml_pfad: str, plan_pfad: str) -> int:
    code = pathlib.Path(yaml_pfad).read_text(encoding="utf-8")
    code = "\n".join(z for z in code.split("\n") if not z.lstrip().startswith("#"))
    plan = json.loads(pathlib.Path(plan_pfad).read_text(encoding="utf-8"))

    erlaubt: set[str] = set()
    for s in plan["spalten"]:
        erlaubt |= set(s.get("auswahlwerte", []))
    for a in plan["auswahlwerte_ergaenzen"]:
        erlaubt |= set(a["werte"])

    geschrieben = set(re.findall(r'\{\s*Value:\s*"([^"]+)"\s*\}', code))
    verglichen = set(re.findall(r'\.Value\s*(?:=|<>)\s*"([^"]+)"', code))
    ersatztext = set(re.findall(r'Coalesce\([^()"]*\.Value,\s*"([^"]+)"\)', code))

    print(f"Oberflaechencode: {yaml_pfad}")
    print(f"In der Einrichtung definierte Auswahlwerte: {len(erlaubt)}")
    print()
    print("GESCHRIEBEN :", ", ".join(sorted(geschrieben)) or "-")
    print("VERGLICHEN  :", ", ".join(sorted(verglichen)) or "-")
    print("ERSATZTEXT  :", ", ".join(sorted(ersatztext)) or "-")
    print("              (nur Anzeige bei leerem Feld - wird nie gespeichert)")
    print()

    fehlend = sorted((geschrieben | verglichen) - erlaubt)
    for w in fehlend:
        art = "geschrieben" if w in geschrieben else "verglichen"
        print(f'FEHLER  Auswahlwert "{w}" wird {art}, ist aber in der Einrichtung nicht definiert.')

    # Ersatztexte, die zufaellig echte Auswahlwerte sind, sind unkritisch -
    # aber ein Ersatztext, der wie ein Wert aussieht und keiner ist, ist ein
    # Hinweis auf einen Tippfehler. Deshalb als Information ausgeben.
    verdaechtig = sorted(w for w in ersatztext - erlaubt if " " not in w)
    if verdaechtig:
        print("Hinweis: Ersatztexte ohne Leerzeichen, die keinem Auswahlwert entsprechen:")
        print("        ", ", ".join(verdaechtig))
        print("         Das ist in Ordnung, solange es Anzeigetext sein soll.")

    if fehlend:
        print(f"\nErgebnis: {len(fehlend)} Fehler.")
        return 1
    print("Ergebnis: alle geschriebenen und verglichenen Auswahlwerte sind definiert.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
