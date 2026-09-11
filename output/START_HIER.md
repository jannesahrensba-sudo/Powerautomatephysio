# Start hier

Kürzester vollständiger Weg von einer leeren Canvas App zur fertigen
Praxis-App. Rechnen Sie mit **45 bis 60 Minuten** für die Schritte 1 bis 7.

> **Bitte zuerst lesen:** Das Verzeichnis `referenzen/` mit den Dateien 01 bis
> 12 war beim Erstellen dieser Lösung **nicht vorhanden** – das Repository war
> leer. Grundlage war ausschließlich die Auftragsbeschreibung. Was daraus
> folgt und was Sie deshalb prüfen müssen, steht in `referenzen/FEHLT.md` und
> in `03_Datenmodell.md`. **Schritt 1 ist deswegen nicht optional.**

---

## Schritt 1 – Listen prüfen (10 Minuten, ändert nichts)

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
cd output\04_Setup
.\Pruefe-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis"
```

Öffnen Sie den erzeugten `Schema-Bericht.md`. Er nennt die **echten**
Spaltennamen und listet jede Abweichung gegenüber `03_Datenmodell.md`.

Zwei Zeilenarten sind wichtig:

- **„POWER-FX-FORMELN ANPASSEN"** – ein Anzeigename weicht ab. Betrifft die
  App.
- **„FLOWS ANPASSEN"** – ein interner Name weicht ab. Betrifft Power Automate.

Arbeiten Sie diese Zeilen ab, bevor Sie weitermachen. Ein falscher Spaltenname
führt in der App zu einem sichtbaren Fehler – in einem Flow dagegen nur zu
null Treffern, ohne Fehlermeldung.

## Schritt 2 – Fehlende Spalten ergänzen (5 Minuten)

```powershell
.\Ergaenze-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
.\Ergaenze-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -EinstellungszeileAnlegen
```

Erst die Vorschau lesen, dann ohne `-WhatIf` ausführen. Das Skript legt nur
**Fehlendes** an, ändert nie einen vorhandenen Typ und löscht nichts.

## Schritt 3 – Leere App anlegen (2 Minuten)

1. [make.powerapps.com](https://make.powerapps.com) → **Erstellen** → **Leere App**
   → **Canvas-App (leer)** → Format **Tablet**.
2. Name: `Physio Human Performance`.
3. **Einstellungen → Anzeige**: „An Bildschirmgröße anpassen" **aus**,
   „Seitenverhältnis sperren" **aus**.
4. **Einstellungen → Allgemein**: Datenzeilenlimit **500**.

> Ohne Schritt 3.3 skaliert Power Apps die Oberfläche, statt sie umzubrechen.
> Das responsive Layout wäre dann wirkungslos.

## Schritt 4 – Datenquellen hinzufügen (5 Minuten)

**Daten → Daten hinzufügen → SharePoint → Ihre Website**, dann genau diese
vier Listen:

| Name in der App | Liste |
|---|---|
| `Patientenstamm` | Patientenstammdaten |
| `Rezepte` | Rezepte |
| `Behandlungsdokumentation` | Behandlungsdokumentation |
| `AufgabenEinstellungen` | Aufgaben-/Einstellungsliste |

Heißt eine Liste bei Ihnen anders, benennen Sie **die Datenquelle in der App**
um. Dann bleiben alle Formeln gültig.

## Schritt 5 – Bildschirm und App-Formeln (10 Minuten)

> **Diese Reihenfolge ist wichtig.** Werden die App-Formeln erst nach dem
> Einfügen gesetzt, zeigt zunächst fast jede Farb- und Größenangabe einen
> Fehler.

1. Neuen leeren Bildschirm einfügen, umbenennen in **`scrPraxis`**.
2. Öffnen Sie **`02_Eigenschaften_DE.md`** – oder `..._EN.md`, falls Ihr Studio
   auf Englisch läuft.

   > Woran Sie es erkennen: Tippen Sie `If(` in die Formelleiste. Steht dort
   > `If( Bedingung; Dann; Sonst )`, nehmen Sie die DE-Datei; steht dort
   > `If( condition, then, else )`, die EN-Datei. Die Trennzeichen sind der
   > einzige Unterschied.

3. Setzen Sie daraus in dieser Reihenfolge:
   `scrPraxis.Fill` → `scrPraxis.OnVisible` → `App.StartScreen` →
   `App.BackEnabled` → **`App.Formulas`** → `App.OnStart`.

   `App.Formulas` ist die zentrale Stelle für Farben, Abstände, Umbruchpunkte
   und Konfiguration. Eine Farbänderung dort wirkt in der ganzen App.

   > Das App-Objekt lässt sich in Power Apps Studio **nicht** über die
   > Codeansicht einfügen. Das ist eine dokumentierte Einschränkung – deshalb
   > dieser Schritt von Hand.

## Schritt 6 – Oberfläche einfügen (2 Minuten)

1. Rechtsklick auf **`scrPraxis`** in der Strukturansicht → **Code einfügen**.
2. Den **vollständigen** Inhalt von `01_AppShell_einfuegen.yaml` einfügen.
   (Inhaltsgleich mit der `.txt`-Fassung – falls Ihr Editor `.yaml` nicht
   öffnet.)
3. Bestätigen.

Danach steht `conPraxisApp` mit 217 untergeordneten Steuerelementen im Baum.

> Erscheint beim Einfügen nichts, prüfen Sie die
> **Zwischenablage-Berechtigung** des Browsers für `make.powerapps.com`.
> Power Apps braucht sie zum Einfügen von Code.

Ein eingefügter YAML-Block installiert **keine** Anmeldungen,
Datenverbindungen, Berechtigungen, Listen und keine Flows. Genau deshalb gibt
es die Schritte 1, 2, 4 und 7.

## Schritt 7 – Erster Test (5 Minuten)

**App-Prüfung** öffnen. Es sollten keine Fehler stehen.

| Prüfung | Erwartet |
|---|---|
| Vorschau starten | Navigation links, Ansicht „Heute" |
| Fenster schmal ziehen | Navigation wird zur Auswahlliste oben |
| Bereich **Patienten** → Namen tippen | Trefferliste, Hinweis mit Trefferzahl |
| **Patient aufnehmen** → Test-Patient anlegen | Meldung „Patient angelegt (ID …)" |
| Weiter zum Rezept, Entwurf sichern | Meldung „Rezeptentwurf gesichert" |
| Bereich **Rezepte** | Rezept sichtbar, **„Einheiten noch nicht berechnet"** |

> Die letzte Zeile ist **richtig so**. Die Zähler kommen aus Power Automate.
> Solange Flow 1 nicht läuft, sagt die App das ausdrücklich – sie zeigt
> bewusst nicht „0 offen".

Legen Sie Testdaten nur mit erkennbaren Testnamen an, etwa `ZZ-Test`.

## Schritt 8 – Flows (45 bis 60 Minuten)

Siehe **`05_Flows/Einrichtung.md`**. Nach Flow 1 verschwindet der Hinweis
„noch nicht berechnet", sobald eine Dokumentation gespeichert wurde.

Versand und Vortagserinnerung sind im Auslieferungszustand **aus**.

---

## Welche Datei wofür

| Datei | Zweck |
|---|---|
| `START_HIER.md` | dieser Einbauweg |
| `01_AppShell_einfuegen.yaml` / `.txt` | die Oberfläche zum Einfügen |
| `01b_Vollstaendiger_Screen.pa.yaml` | derselbe Code als vollständiger Bildschirm, zum Nachlesen und Versionieren |
| `02_Eigenschaften_DE.md` / `_EN.md` | die von Hand zu setzenden App-Formeln |
| `03_Datenmodell.md` | Feldmatrix mit bestätigt / unklar / fehlt |
| `03_Schema_Mapping.json` | dieselbe Zuordnung maschinenlesbar |
| `04_Setup/` | Prüf- und Ergänzungsskripte |
| `05_Flows/` | Zählung, Erinnerungen, Versand |
| `06_Tests.md` | was geprüft wurde und was Sie testen sollten |
| `../tools/` | die Prüfwerkzeuge, wiederholbar ausführbar |

## Was noch offen ist

1. **Anzeigename der Titelspalte im Rezept** (`Title` / `Titel` /
   `Rezeptname`). Die App liest dieses Feld deshalb **nicht**, sondern bildet
   die Rezeptbezeichnung aus ID und Diagnose. Kein Handlungsbedarf, solange
   Sie damit leben können.
2. **Typ und Ziel der Spalten `Patient` und `Rezept`.** Die App schreibt
   stattdessen die Zahlenspalten `PatientID` und `RezeptID`.
3. **Fachliche Bedeutung der Doku-Spalte `AltEinheiten`** (Befund 3).
   `04_Setup/Pruefe-Bestandsdaten.ps1` beantwortet das an Ihren Daten.
4. **Rezeptfoto und Anlagen** – als eigenes Modul beschrieben in
   `05_Flows/Einrichtung.md`. Die App zeigt dort einen ehrlichen Hinweis statt
   eines wirkungslosen Feldes.
5. **Therapeuten-Zuordnung.** `Therapeut` ist ein Auswahlfeld, kein
   Personenfeld. Der angemeldete Benutzer wird bewusst **nicht** als Therapeut
   angenommen.
