#!/usr/bin/env python3
"""
Setzt in ANZEIGETEXT und DATENWERTEN die richtigen Umlaute.

Bewusste Trennung:
  * Anzeigetext und Auswahlwerte  -> echtes Deutsch ("Maßnahmen", "Durchgeführt")
  * Bezeichner, Steuerelementnamen, benannte Formeln und SHAREPOINT-SPALTEN
    -> bleiben ASCII ("Massnahmen", "Heimuebungen", "clrFlaeche")

Grund fuer die ASCII-Spaltennamen: SharePoint kodiert Umlaute im internen
Namen als _x00e4_ und aehnlich. Solche Namen sind in Power Automate schwer
lesbar und fehleranfaellig. Der ANZEIGENAME darf spaeter jederzeit auf
"Maßnahmen" gesetzt werden - der interne Name bleibt stabil.

Technisch wird das erreicht, indem im YAML ausschliesslich der Inhalt
doppelter Anfuehrungszeichen ersetzt wird. Spaltennamen stehen dort nie:
sie erscheinen als Bezeichner (gblDoku.Massnahmen), als Datensatzschluessel
(Massnahmen:) oder in EINFACHEN Anfuehrungszeichen ('Diagnose laut Rezept').
In Markdown wird alles in Backticks geschuetzt.
"""
from __future__ import annotations
import re
import sys
import pathlib

WORTE = {
    "Aenderung": "Änderung", "Auswaehlen": "Auswählen",
    "Durchgefuehrt": "Durchgeführt", "Eintraege": "Einträge",
    "Empfaengeradresse": "Empfängeradresse", "Fuer": "Für", "Geprueft": "Geprüft",
    "Heimuebungen": "Heimübungen", "Massnahmen": "Maßnahmen",
    "Schliessen": "Schließen", "Ueber": "Über", "Zurueck": "Zurück",
    "Zurueckgestellt": "Zurückgestellt", "Inaktivitaet": "Inaktivität",
    "abschliessen": "abschließen", "aendern": "ändern", "ausfuellen": "ausfüllen",
    "ausgewaehlt": "ausgewählt", "ausserhalb": "außerhalb", "auswaehlen": "auswählen",
    "benoetigt": "benötigt", "dafuer": "dafür", "durchgefuehrte": "durchgeführte",
    "einfuegen": "einfügen", "ergaenzt": "ergänzt", "fuer": "für",
    "gehoeren": "gehören", "geoeffnet": "geöffnet", "geprueft": "geprüft",
    "groesser": "größer", "koennen": "können", "laeuft": "läuft",
    "moechten": "möchten", "oeffnen": "öffnen", "pruefen": "prüfen",
    "schreibgeschuetzt": "schreibgeschützt", "spaeter": "später",
    "tatsaechlich": "tatsächlich", "ueber": "über", "uebernehmen": "übernehmen",
    "uebernommen": "übernommen", "unveraendert": "unverändert",
    "urspruengliche": "ursprüngliche", "veraendert": "verändert",
    "waehlen": "wählen", "zurueckgestellt": "zurückgestellt",
    "zurueckstellen": "zurückstellen",
    # weitere Prosaformen, die nur in den Dokumentationsdateien vorkommen
    "Anfuehrungszeichen": "Anführungszeichen", "Ausfuehren": "Ausführen",
    "Aenderungen": "Änderungen", "Abstaende": "Abstände", "Groessen": "Größen",
    "Pruefung": "Prüfung", "Pruefen": "Prüfen", "Erklaerung": "Erklärung",
    "Loeschen": "Löschen", "Moeglichkeit": "Möglichkeit", "Naechste": "Nächste",
    "Umbruchpunkte": "Umbruchpunkte", "Uebersicht": "Übersicht",
    "abhaengig": "abhängig", "aendert": "ändert", "ausfuehren": "ausführen",
    "ausgefuehrt": "ausgeführt", "bestaetigt": "bestätigt",
    "bestaetigen": "bestätigen", "dafuerhalten": "dafürhalten",
    "eingefuegt": "eingefügt", "enthaelt": "enthält", "erfuellt": "erfüllt",
    "faellt": "fällt", "gaengig": "gängig", "gehoert": "gehört",
    "gelaeufig": "geläufig", "gemaess": "gemäß", "gepruefte": "geprüfte",
    "haeufigste": "häufigste", "haette": "hätte", "heisst": "heißt",
    "hoeher": "höher", "laesst": "lässt", "loeschen": "löschen",
    "moeglich": "möglich", "muessen": "müssen", "naechsten": "nächsten",
    "noetig": "nötig", "oefter": "öfter", "pruefend": "prüfend",
    "schliesslich": "schließlich", "selbstverstaendlich": "selbstverständlich",
    "staendig": "ständig", "taeglich": "täglich", "tatsaechliche": "tatsächliche",
    "tatsaechlichen": "tatsächlichen", "ueberall": "überall",
    "ueberschreiben": "überschreiben", "ueberschrieben": "überschrieben",
    "uebersprungen": "übersprungen", "ungueltig": "ungültig",
    "vollstaendig": "vollständig", "vollstaendige": "vollständige",
    "vollstaendigen": "vollständigen", "waere": "wäre", "zusaetzlich": "zusätzlich",
    "Zaehler": "Zähler", "zaehlt": "zählt", "Erlaeuterung": "Erläuterung",
    "Gruende": "Gründe", "Grundsaetze": "Grundsätze", "Schluessel": "Schlüssel",
    "unabhaengig": "unabhängig", "zugehoerige": "zugehörige",
}

_MUSTER = re.compile("|".join(rf"\b{re.escape(w)}\b" for w in sorted(WORTE, key=len, reverse=True)))


def ersetze(text: str) -> str:
    return _MUSTER.sub(lambda m: WORTE[m.group(0)], text)


def yaml_datei(text: str) -> str:
    """Nur den Inhalt doppelter Anfuehrungszeichen ersetzen."""
    return re.sub(r'"((?:[^"]|"")*)"', lambda m: '"' + ersetze(m.group(1)) + '"', text)


def markdown_datei(text: str) -> str:
    """Alles ausser Code in Backticks ersetzen."""
    teile = re.split(r"(```.*?```|`[^`]*`)", text, flags=re.S)
    return "".join(t if i % 2 else ersetze(t) for i, t in enumerate(teile))


if __name__ == "__main__":
    for pfad_text in sys.argv[1:]:
        pfad = pathlib.Path(pfad_text)
        alt = pfad.read_text(encoding="utf-8")
        neu = yaml_datei(alt) if pfad.suffix in (".yaml", ".txt") else markdown_datei(alt)
        if neu != alt:
            pfad.write_text(neu, encoding="utf-8")
            print(f"angepasst: {pfad}")
        else:
            print(f"unveraendert: {pfad}")
