# Physio Human Performance – Praxis-Apps

**Power Apps Canvas Apps** für Erstaufnahme, Patientenakte, Rezepte und
Behandlungsdokumentation – auf der bestehenden SharePoint-Datenhaltung.

## Drei Apps, eine Datenhaltung

| App | Wer bedient sie | Macht | Schreibt in |
|---|---|---|---|
| **[`anmeldung/`](anmeldung/START_HIER.md)** | der Patient, am iPad | Kontaktdaten, Honoraraufklärung, Einwilligungen | `Patientenstamm`, `Anmeldungen` |
| **[`erstaufnahme/`](erstaufnahme/START_HIER.md)** | Therapeut | Befund und Anamnese bei der Erstaufnahme | `Rezepte` |
| **[`v3/`](v3/START_HIER.md)** | Therapeut | Patient aufrufen, Vorbereitung, Behandlung dokumentieren | `Behandlungsdokumentation` |

Sie greifen ineinander, ohne sich zu kennen:

- Die **Anmelde-App** legt den Patienten in `Patientenstamm` an – genau dort,
  wo die anderen zwei ihn suchen.
- Die **Aufnahme-App** schreibt Befund und Anamnese in die Felder, aus denen
  die Behandlungs-App den Befund liest (`Erstbefund`, `Anamnese`,
  `Diagnose laut Rezept` über `PatientID`).

**An den bestehenden Apps ist für keine der Erweiterungen eine Änderung
nötig.** Die Anmelde-App fügt `Patientenstamm` nur Spalten hinzu; die drei
Felder, die die anderen lesen, bleiben unverändert.

> Beide Apps sprechen die Rezeptliste als **`Rezept`** an – Einzahl, so wie in
> der laufenden App. Der Name muss in beiden gleich sein.

## Fassungen der Behandlungs-App

| Ordner | Für wen |
|---|---|
| **[`v3/`](v3/START_HIER.md)** | **Aktuell.** Wie V2, zusätzlich Textbausteine und Längenprüfung in der Dokumentation. 82 Steuerelemente, 16 Spalten, keine Flows. |
| [`v2/`](v2/START_HIER.md) | Dieselbe einfache Fassung ohne die Schreibhilfen. 78 Steuerelemente. Bleibt liegen, falls V3 im Studio Probleme macht. |
| [`output/`](output/START_HIER.md) | Die ausführliche Fassung mit Aufnahme-Assistent, Rezeptverwaltung, Aufgaben, Einheitenzählung und Power-Automate-Flows. 219 Steuerelemente. |

Beide nutzen dieselben SharePoint-Listen. Die einfache Fassung schreibt nur
eine Teilmenge der Spalten – ein späterer Umstieg ist deshalb möglich, ohne
Daten zu verlieren.

## Einstieg

| | |
|---|---|
| Behandlungs-App | → **[`v3/START_HIER.md`](v3/START_HIER.md)** |
| Aufnahme-App | → **[`erstaufnahme/START_HIER.md`](erstaufnahme/START_HIER.md)** |
| Anmelde-App | → **[`anmeldung/START_HIER.md`](anmeldung/START_HIER.md)** |

## Aufbau

```
anmeldung/                         Anmeldung am iPad, vom Patienten bedient
  START_HIER.md                    Einbauweg in 5 Schritten
  01_AppShell_einfuegen.yaml/.txt  Oberfläche zum Einfügen (109 Steuerelemente)
  02_Eigenschaften_DE.md / _EN.md  App-Formeln, Honorarsätze, Praxisanschrift
  03_Spalten.md / .json            neue Liste Anmeldungen, Zusatzspalten
  04_Spalten_anlegen.ps1           legt Liste und Spalten an, prüft zuerst
  06_Rechtstexte.md                jeder Rechtstext wörtlich, zum Gegenlesen

erstaufnahme/                      Erstaufnahme: Befund und Anamnese
  START_HIER.md                    Einbauweg in 5 Schritten
  01_AppShell_einfuegen.yaml/.txt  Oberfläche zum Einfügen (42 Steuerelemente)
  02_Eigenschaften_DE.md / _EN.md  App-Formeln, beide Trennzeichenfassungen
  03_Spalten.md / .json            welche Spalten gebraucht werden
  04_Spalten_anlegen.ps1           legt fehlende Spalten an, prüft zuerst
  05_Rezeptfoto/                   optionaler Zusatz: Kamera plus Flow

v3/                                Behandlungs-App – aktuelle Fassung
  START_HIER.md                    Einbauweg in 5 Schritten
  01_AppShell_einfuegen.yaml/.txt  Oberfläche zum Einfügen (82 Steuerelemente)
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

# Anmelde-App
python3 tools/validate_pa_yaml.py --fragment anmeldung/01_AppShell_einfuegen.yaml
python3 tools/pruefe_referenzen.py          anmeldung/01_AppShell_einfuegen.yaml anmeldung/02_Eigenschaften_EN.md
python3 tools/pruefe_felder.py              anmeldung/01_AppShell_einfuegen.yaml anmeldung/03_Spalten.json

# Aufnahme-App
python3 tools/validate_pa_yaml.py --fragment erstaufnahme/01_AppShell_einfuegen.yaml
python3 tools/validate_pa_yaml.py --fragment erstaufnahme/05_Rezeptfoto/Zusatz_Controls.yaml
python3 tools/pruefe_referenzen.py          erstaufnahme/01_AppShell_einfuegen.yaml erstaufnahme/02_Eigenschaften_EN.md
python3 tools/pruefe_felder.py              erstaufnahme/01_AppShell_einfuegen.yaml erstaufnahme/03_Spalten.json

# Behandlungs-App, aktuelle Fassung
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

Die beiden optionalen Zusätze (`v3/06_Textpruefung_KI/` und
`erstaufnahme/05_Rezeptfoto/`) brauchen je einen Power-Automate-Flow. Für beide
liegt **bewusst keine Importdatei** bei: Die Aktionen des AI-Builder-Connectors unterscheiden sich
je nach Tenant und Region, und ich kann keine davon nachsehen. Stattdessen
steht dort eine Bauanleitung. Der Zusatz ist **nicht getestet** und für den
Betrieb der App **nicht erforderlich**.
