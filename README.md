# Physio Human Performance – Praxis-App

Eine zusammenhängende **Power Apps Canvas App** für Patientenaufnahme,
Patientenakte, Rezepte, Behandlungsdokumentation und Praxisaufgaben – auf der
bestehenden SharePoint-Datenhaltung.

## Drei Fassungen

| Ordner | Für wen |
|---|---|
| **[`v3/`](v3/START_HIER.md)** | **Aktuell. Hier anfangen.** Wie V2, zusätzlich Textbausteine und Längenprüfung in der Dokumentation. 81 Steuerelemente, 16 Spalten, keine Flows. |
| [`v2/`](v2/START_HIER.md) | Dieselbe einfache Fassung ohne die Schreibhilfen. 77 Steuerelemente. Bleibt liegen, falls V3 im Studio Probleme macht. |
| [`output/`](output/START_HIER.md) | Die ausführliche Fassung mit Aufnahme-Assistent, Rezeptverwaltung, Aufgaben, Einheitenzählung und Power-Automate-Flows. 219 Steuerelemente. |

Beide nutzen dieselben SharePoint-Listen. Die einfache Fassung schreibt nur
eine Teilmenge der Spalten – ein späterer Umstieg ist deshalb möglich, ohne
Daten zu verlieren.

## Einstieg

→ **[`v3/START_HIER.md`](v3/START_HIER.md)**

## Aufbau

```
v3/                                aktuelle einfache Fassung – hier anfangen
  START_HIER.md                    Einbauweg in 5 Schritten
  01_AppShell_einfuegen.yaml/.txt  Oberfläche zum Einfügen (81 Steuerelemente)
  02_Eigenschaften_DE.md / _EN.md  App-Formeln, beide Trennzeichenfassungen
  03_Spalten.md / .json            die 16 benötigten Spalten
  04_Spalten_anlegen.ps1           legt fehlende Spalten an, prüft zuerst
  05_Fehlerbehebung/               wenn Studio Spalten rot markiert
  06_Textpruefung_KI/              optionaler Zusatz: Rechtschreibprüfung
                                   per Flow – nicht eingebaut, nicht nötig
  Logo_Vorschau.png                so sieht das eingebettete Logo aus

v2/                                Vorgänger ohne Schreibhilfen

output/
  START_HIER.md                    kürzester vollständiger Einbauweg
  01_AppShell_einfuegen.yaml/.txt  Oberfläche zum Einfügen (219 Steuerelemente)
  01b_Vollstaendiger_Screen.pa.yaml  derselbe Code als vollständiger Bildschirm
  02_Eigenschaften_DE.md / _EN.md  App-Formeln, deutsche und englische Trennzeichen
  03_Datenmodell.md                Feldmatrix: bestätigt / unklar / fehlt
  03_Schema_Mapping.json           dieselbe Zuordnung maschinenlesbar
  04_Setup/                        Prüf- und Ergänzungsskripte (PnP.PowerShell)
  05_Flows/                        Zählung, Erinnerungen, Versand
  06_Tests.md                      ausgeführte Prüfungen und Testfälle
  Physio_Praxis_App.zip            alle Ausgabedateien als Paket

tools/                             wiederholbare Prüfwerkzeuge
referenzen/FEHLT.md                warum die Referenzdateien fehlten
```

## Prüfungen wiederholen

```bash
pip install pyyaml jsonschema

python3 tools/validate_pa_yaml.py --fragment output/01_AppShell_einfuegen.yaml
python3 tools/validate_pa_yaml.py           output/01b_Vollstaendiger_Screen.pa.yaml
python3 tools/pruefe_referenzen.py          output/01_AppShell_einfuegen.yaml output/02_Eigenschaften_EN.md
python3 tools/pruefe_felder.py              output/01_AppShell_einfuegen.yaml output/03_Schema_Mapping.json
python3 tools/pruefe_auswahlwerte.py        output/01_AppShell_einfuegen.yaml output/04_Setup/Schema-Ergaenzungen.json

# aktuelle einfache Fassung
python3 tools/validate_pa_yaml.py --fragment v3/01_AppShell_einfuegen.yaml
python3 tools/validate_pa_yaml.py --fragment v3/06_Textpruefung_KI/Zusatz_Controls.yaml
python3 tools/pruefe_referenzen.py          v3/01_AppShell_einfuegen.yaml v3/02_Eigenschaften_EN.md
python3 tools/pruefe_felder.py              v3/01_AppShell_einfuegen.yaml v3/03_Spalten.json
```

Geprüft wird gegen das offizielle Power-Apps-Schema `pa.schema.yaml` (v3.0)
aus [`microsoft/PowerApps-Tooling`](https://github.com/microsoft/PowerApps-Tooling),
das unverändert in `tools/` mitliegt.

## Stand der Prüfung

| Stufe | Status |
|---|---|
| statische Prüfung (Schema, Verweise, Felder, Auswahlwerte) | **ausgeführt, bestanden** |
| Power-Apps-Kompilierung | **nicht ausgeführt** – kein Studio-Zugang |
| Test im Tenant, auf Geräten | **nicht ausgeführt** – kein Tenant-Zugang |
| PowerShell-Skripte | **nicht ausgeführt** – keine PowerShell in der Umgebung |

Einzelheiten und die vollständige Testliste: [`output/06_Tests.md`](output/06_Tests.md).

Die Flow-Dateien in `output/05_Flows/` sind **Referenzdefinitionen im
Peek-code-Format, kein geprüftes Importpaket.** Sie wurden nicht importiert
und nicht ausgeführt.

Für den optionalen Zusatz in `v3/06_Textpruefung_KI/` liegt **bewusst keine
Importdatei** bei: Die Aktionen des AI-Builder-Connectors unterscheiden sich
je nach Tenant und Region, und ich kann keine davon nachsehen. Stattdessen
steht dort eine Bauanleitung. Der Zusatz ist **nicht getestet** und für den
Betrieb der App **nicht erforderlich**.
