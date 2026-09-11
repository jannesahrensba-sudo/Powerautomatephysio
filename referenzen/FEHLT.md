# Dieses Verzeichnis war leer

Der Auftrag verweist auf zwölf Referenzdateien in `referenzen/`:

| Datei | Inhalt laut Auftrag |
|---|---|
| `01_Original_Appcode.yaml` | ursprünglicher Bildschirm `MainScreen1`, `Form1` |
| `02_Ueberarbeiteter_Appcode.yaml` | Erweiterung für Rezeptauswahl und Patientensuche |
| `03_Bisheriger_Einbau.md` | bisherige Schemaanalyse und Einbauschritte |
| `04_Feldzuordnung.json` | bisherige Zuordnung und bekannte Unterschiede |
| `05_Schema_Patientenstamm.md` | Schemaexport |
| `06_Schema_Aufgaben_Einstellungen.md` | Schemaexport |
| `07_Schema_Rezepte.md` | Schemaexport |
| `08_Schema_Behandlungsdokumentation.md` | Schemaexport |
| `09_Schema_Extraktion.json` | Auswertung der XML-Felder |
| `10_/11_Bisherige_Gesamtanleitung` | fachlicher Prozess, Flow-Anleitung |
| `12_Bisherige_App.png` | Screenshot der bisherigen Oberfläche |

**Keine dieser Dateien war vorhanden.** Das Repository
`jannesahrensba-sudo/Powerautomatephysio` hatte zu Beginn dieser Arbeit keinen
einzigen Commit; es lag ausschließlich die Auftragsbeschreibung vor.

## Was daraus folgt

**Was trotzdem vollständig geliefert werden konnte,** weil es nicht von den
Referenzdateien abhängt: die gesamte Oberfläche, das responsive Layout, die
Ablauflogik, die Fehlerbehandlung, die Flow-Logik, die Einrichtungsskripte und
die Prüfwerkzeuge.

**Was von den Referenzdateien abhing:** die exakten Spaltennamen. Grundlage
dafür war Abschnitt 5 der Auftragsbeschreibung mit den Befunden 1 bis 10.
Diese Befunde sind vollständig umgesetzt und in `output/03_Datenmodell.md`
nachvollziehbar markiert.

In der Feldmatrix ist jedes Feld einer von fünf Stufen zugeordnet:

| Zeichen | Bedeutung |
|---|---|
| `[S]` | Systemspalte von SharePoint |
| `[B]` | im Auftrag ausdrücklich benannt |
| `[?]` | plausibel, aber nicht belegt |
| `[!]` | ausdrücklich ungeklärt |
| `[+]` | muss ergänzt werden |

**`[B]` heißt: im Auftragstext benannt. Es heißt nicht: gegen die Liste
geprüft.** Es gab keinen Zugang zum Tenant.

## Was zu tun ist

`output/04_Setup/Pruefe-Schema.ps1` liest die tatsächlichen Anzeigenamen,
internen Namen und Typen aus und erzeugt einen Abgleichbericht. Dieser Bericht
ist die belastbare Quelle – wo er von `03_Datenmodell.md` abweicht, gilt der
Bericht.

Er beantwortet auch die vier Punkte, die offen bleiben mussten:

1. Wie heißt die Titelspalte im Rezept wirklich (Befund 5)?
2. Welchen Typ und welches Ziel haben `Patient` und `Rezept` (Befund 6)?
3. Stimmen die internen Namen, die die Flows verwenden?
4. Existieren die Auswahlwerte, die die App schreibt?

Sollten die Originaldateien noch auftauchen, ist der Abgleich schnell: Die
Feldzuordnung liegt mit `03_Schema_Mapping.json` maschinenlesbar vor, und
`tools/pruefe_felder.py` prüft nach jeder Änderung, ob Code und Dokumentation
noch zueinander passen.
