# Einrichtung der SharePoint-Listen

## Was hier ausführbar ist - und was Anleitung bleibt

| Datei | Art | Verändert Daten? |
|---|---|---|
| `Pruefe-Schema.ps1` | ausführbar | **nein** – liest nur Metadaten, schreibt einen Bericht |
| `Pruefe-Bestandsdaten.ps1` | ausführbar | **nein** – liest nur Daten, schreibt einen Bericht |
| `Ergaenze-Schema.ps1` | ausführbar | ja – legt **fehlende** Spalten, Auswahlwerte und Indizes an |
| `Schema-Ergaenzungen.json` | Datenbasis | – erzeugt aus `03_Schema_Mapping.json` |
| Abschnitt „Von Hand" unten | **Anleitung, kein Skript** | – |

Voraussetzung für alle drei Skripte:

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
```

## Reihenfolge

```powershell
# 1. IST-Zustand feststellen. Ändert nichts.
.\Pruefe-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis"

# 2. Den erzeugten Schema-Bericht.md lesen und jede Abweichung abarbeiten.

# 3. Vorschau der Änderungen. Ändert nichts.
.\Ergaenze-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf

# 4. Erst jetzt tatsächlich ergänzen.
.\Ergaenze-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -EinstellungszeileAnlegen

# 5. Bestandsdaten bewerten. Ändert nichts.
.\Pruefe-Bestandsdaten.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis"

# 6. Nur wenn Flow 4 (Versand) genutzt werden soll:
.\Ergaenze-Schema.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" `
                      -StandardwertMailGesendetamEntfernen
```

Schritt 2 ist nicht optional. Weicht ein **interner** Spaltenname von der
Dokumentation ab, laufen die Flows später ins Leere – und zwar ohne
Fehlermeldung, weil ein leerer Filter einfach null Zeilen liefert.

## Grundsätze von `Ergaenze-Schema.ps1`

- **Zuerst prüfen.** Jede Spalte wird vor dem Anlegen gesucht – über den
  internen Namen **und** über den Anzeigenamen. Ist sie vorhanden, wird sie
  übersprungen und nicht angefasst.
- **Nichts löschen, nichts umbenennen.** Ein vorhandener Typ wird nie
  geändert. Weicht er ab, erscheint ein Hinweis zur fachlichen Klärung.
- **Auswahlwerte nur ergänzen.** Vorhandene Werte bleiben erhalten und
  behalten ihre Reihenfolge.
- **Wiederholbar.** Ein zweiter Lauf ändert nichts mehr.
- **Keine Daten anfassen** – einzige Ausnahme ist die Einstellungszeile, und
  auch die nur mit `-EinstellungszeileAnlegen`.

## Was die Skripte bewusst nicht tun

Zwei Eingriffe sind bestätigungspflichtig und deshalb ausdrücklich **nicht**
automatisiert:

### 1. Anzeigename der Doku-Spalte `AltEinheiten`

Die Spalte heißt intern `Einheiten`, wird als `AltEinheiten` angezeigt und hat
den Standardwert 1 (Befund 3). Der Standardwert spricht für „Behandlungsmenge
dieser einen Zeile", der Anzeigename für „Altbestand des Rezepts". Das ist
genau die Verwechslung, vor der der Auftrag warnt.

`Pruefe-Bestandsdaten.ps1` beantwortet das an den echten Daten und gibt eine
Empfehlung. **Entscheiden muss die Praxis.**

Fällt die Entscheidung auf „Behandlungsmenge", sind es zwei Schritte:

1. In SharePoint den **Anzeigenamen** auf `Behandlungsmenge` ändern. Der
   interne Name `Einheiten` bleibt – bestehende Verweise und die Flows brechen
   dadurch nicht.
2. In `01_AppShell_einfuegen.yaml` die vier Fundstellen `AltEinheiten` auf
   `Behandlungsmenge` umstellen (`06_Tests.md`, Abschnitt „Nach einer
   Umbenennung" nennt sie einzeln).

Der Rezept-Altbestand bekommt davon unabhängig seine eigene Spalte
`Rezepte.AltEinheiten` – die legt das Skript an.

### 2. Umzug vorhandener Zählerwerte von der Doku an das Rezept

`EinheitenApp`, `Erbracht`, `Offen`, `LetzterAppTermin` und `InaktivTage`
liegen teilweise in der Dokumentation (Befund 4). Gemeinsame Zähler gehören an
das Rezept.

**Bestandswerte werden nicht kopiert.** Der Zähler-Flow berechnet die Werte
vollständig neu aus den tatsächlichen Doku-Zeilen. Ein Kopieren würde die
alten Werte zusätzlich zu den neu berechneten wirksam machen – also doppelt
zählen.

Empfohlenes Vorgehen:

1. Flow 1 einmal über alle Rezepte laufen lassen (eine Doku-Zeile je Rezept
   speichern genügt als Auslöser).
2. Neu berechnete Rezeptwerte stichprobenartig gegen die alten Doku-Werte
   halten.
3. Erst danach entscheiden, ob die alten Doku-Spalten ausgeblendet werden.
   **Löschen ist nicht nötig und nicht empfohlen.**

## Von Hand: Berechtigungen

Das ist **Anleitung, kein Skript** – Berechtigungen automatisiert zu setzen
wäre an dieser Stelle riskanter als hilfreich.

| Rolle | Rechte |
|---|---|
| Physiotherapie | Bearbeiten auf `Patientenstamm`, `Rezepte`, `Behandlungsdokumentation`; Lesen auf `AufgabenEinstellungen` |
| Praxisleitung | zusätzlich Bearbeiten auf `AufgabenEinstellungen` |
| Dienstkonto der Flows | Bearbeiten auf allen vier Listen |

> Die App blendet den Einstellungsbereich **nicht** rollenabhängig aus. Ein
> ausgeblendetes Steuerelement ist keine Berechtigung – wer die Liste direkt
> in SharePoint öffnet, käme trotzdem heran. Die Steuerung gehört deshalb
> dorthin, wo sie wirkt: in die SharePoint-Berechtigungen.
