#!/usr/bin/env python3
"""
Listet alle Formeln auf, die bestimmte SharePoint-Spalten ansprechen -
je Steuerelement und Eigenschaft, in beiden Trennzeichenfassungen.

Zweck: Wenn Power Apps Studio Spalten rot unterringelt, zeigt diese Liste
genau, welche Formeln betroffen sind. Sie wird AUS DEM CODE erzeugt und kann
deshalb nicht von ihm abweichen.

Aufruf:
  python3 tools/betroffene_formeln.py <datei.yaml> <spalten.json> <zielordner>
"""
from __future__ import annotations
import json
import pathlib
import re
import sys

import yaml

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from trennzeichen_de import nach_deutsch


def sammle(knoten, muster, treffer):
    if not isinstance(knoten, list):
        return
    for eintrag in knoten:
        for name, inhalt in (eintrag or {}).items():
            if not isinstance(inhalt, dict):
                continue
            typ = inhalt.get("Control", "")
            for prop, formel in (inhalt.get("Properties") or {}).items():
                if not isinstance(formel, str):
                    continue
                # Kommentare und Zeichenketten ausblenden: Anzeigetext wie
                # "Befund und Anamnese" ist kein Spaltenverweis.
                ohne = "\n".join(
                    z for z in formel.split("\n") if not z.strip().startswith("//")
                )
                ohne = re.sub(r'"(?:[^"]|"")*"', '""', ohne)
                genutzt = sorted(s for s, m in muster.items() if m.search(ohne))
                if genutzt:
                    treffer.append((name, typ, prop, formel.rstrip(), genutzt))
            sammle(inhalt.get("Children"), muster, treffer)


def main(yaml_pfad: str, spalten_pfad: str, ziel: str) -> int:
    zuordnung = json.loads(pathlib.Path(spalten_pfad).read_text(encoding="utf-8"))
    # Systemspalten und nachweislich funktionierende Spalten bleiben aussen vor.
    # Es geht nur um die, die fehlen koennten.
    UNKRITISCH = {"system", "bestaetigt"}
    spalten = sorted({
        f["anzeigename"]
        for liste, felder in zuordnung["listen"].items()
        for f in felder
        if f["status"] not in UNKRITISCH
    })
    muster = {
        s: re.compile(rf"(?<![A-Za-z0-9_]){re.escape(s)}(?![A-Za-z0-9_])")
        for s in spalten
    }

    daten = yaml.safe_load(pathlib.Path(yaml_pfad).read_text(encoding="utf-8"))
    treffer: list = []
    sammle(daten, muster, treffer)

    zielordner = pathlib.Path(ziel)
    zielordner.mkdir(parents=True, exist_ok=True)

    for sprache in ("DE", "EN"):
        de = sprache == "DE"
        w = nach_deutsch if de else (lambda t: t)
        trenn = ("Argumente mit `;`, mehrere Anweisungen mit `;;`" if de
                 else "Argumente mit `,`, mehrere Anweisungen mit `;`")
        t = [f"# Betroffene Formeln, Steuerelement für Steuerelement ({sprache})\n",
             f"Trennzeichen dieser Datei: {trenn}. Die andere Fassung liegt daneben.\n",
             "> **Aus dem Oberflächencode erzeugt, nicht abgetippt.** Diese Liste",
             "> kann deshalb nicht vom Code abweichen.\n",
             "## Wozu diese Liste gut ist – und wozu nicht\n",
             "Jede Formel hier spricht mindestens eine Spalte an, die Power Apps",
             "Studio rot unterringelt.\n",
             "**Solange die Spalte in SharePoint fehlt, hilft kein Umschreiben der",
             "Formel.** Legen Sie zuerst die Spalten an – die Markierungen",
             "verschwinden dann von selbst, ohne dass Sie eine Zeile anfassen.\n",
             "Diese Liste brauchen Sie nur, wenn eine Spalte bei Ihnen **anders**",
             "**heißt**. Dann tauschen Sie den Namen in der jeweiligen Formel aus",
             "und fügen sie in die genannte Eigenschaft ein.\n",
             f"Betroffen: **{len(treffer)} Formeln** in "
             f"**{len({x[0] for x in treffer})} Steuerelementen**.\n",
             "| Steuerelement | Eigenschaft | Spalten |", "|---|---|---|"]
        for name, _, prop, _, g in treffer:
            t.append(f"| `{name}` | `{prop}` | " + ", ".join(f"`{x}`" for x in g) + " |")
        t.append("\n---\n")
        for name, typ, prop, formel, genutzt in treffer:
            t.append(f"## `{name}` · Eigenschaft `{prop}`\n")
            t.append(f"Control `{typ}`, verwendet " + ", ".join(f"`{g}`" for g in genutzt) + "\n")
            t.append("```powerfx")
            t.append(w(formel))
            t.append("```\n")
        (zielordner / f"Formeln_je_Steuerelement_{sprache}.md").write_text(
            "\n".join(t), encoding="utf-8")

    print(f"{len(treffer)} Formeln in {len({x[0] for x in treffer})} Steuerelementen")
    for name, _, prop, _, g in treffer:
        print(f"  {name:22s} {prop:10s} {', '.join(g)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1], sys.argv[2], sys.argv[3]))
