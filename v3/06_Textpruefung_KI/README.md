# Textprüfung per KI – optionaler Zusatz

> **Dieser Ordner ist nicht Teil der App.** V3 funktioniert vollständig ohne
> ihn. Schalten Sie ihn erst ein, wenn Lizenz **und** Datenschutz geklärt sind.

Was er ergänzt: eine Schaltfläche **„Text prüfen"** in Schritt 3. Ein Druck
schickt **alle drei Felder in einem Aufruf** an einen Power-Automate-Flow, der
sie auf Rechtschreibung und Formulierung prüft und Vorschläge zurückgibt.

---

## Drei Dinge vorab, die wichtiger sind als die Technik

### 1. Die KI darf niemals still überschreiben

Die Behandlungsdokumentation ist ein Rechtsdokument nach **§ 630f BGB**.
Deshalb ist der Zusatz so gebaut, dass die KI **vorschlägt** und der Therapeut
**übernimmt** – je Feld einzeln oder alles auf einmal. Gespeichert wird nur,
was am Bildschirm stand, als „Behandlung speichern" gedrückt wurde.

Bauen Sie das nicht um. Ein Automatismus, der den Text beim Speichern
„glättet", erzeugt Einträge, die so niemand geschrieben hat.

### 2. Gesundheitsdaten verlassen die Praxis

Behandlungstexte sind Daten nach **Art. 9 DSGVO**. Sobald sie zur Prüfung an
ein Sprachmodell gehen, ist das eine Auftragsverarbeitung. Vor dem
Einschalten zu klären:

- [ ] AVV mit Microsoft vorhanden (über M365 meist schon abgedeckt)
- [ ] In welcher Region rechnet AI Builder für Ihre Umgebung? Das steht im
      **Power Platform Admin Center → Umgebung → Einstellungen**. Bei AI
      Builder war die Verarbeitung nicht in jedem Fall auf die EU begrenzt.
- [ ] Verzeichnis von Verarbeitungstätigkeiten ergänzt
- [ ] Team informiert: Namen gehören nicht in die Freitextfelder

**Das kann ich für Ihren Tenant nicht nachsehen** – ich habe keinen Zugang.
Die Punkte sind eine Checkliste, keine Rechtsberatung.

### 3. Es kostet laufend

AI Builder rechnet über Credits ab, und alle Nutzer der App brauchen eine
Premium-Lizenz. Prüfen Sie die Kosten für Ihre Praxisgröße, bevor Sie
anfangen – bei drei Therapeuten und 20 Behandlungen am Tag summiert sich das.

---

## Lohnt es sich überhaupt?

Ehrliche Einschätzung: **Vermutlich erst als zweiter Schritt.**

V3 hat bereits die **Textbausteine** eingebaut. Der größte Teil einer
Physio-Doku besteht aus wiederkehrenden Formulierungen – was man aus einer
Liste auswählt, kann man nicht falsch schreiben. Dazu kommt, dass auf Tablet
und Handy ohnehin die Autokorrektur der Systemtastatur läuft.

Nutzen Sie erst einmal V3 im Alltag. Wenn nach ein paar Wochen noch etwas
fehlt, ist dieser Ordner hier.

---

## Was hier liegt

| Datei | Inhalt |
|---|---|
| `Flow_bauen.md` | Der Flow, Schritt für Schritt in Power Automate |
| `Prompt.md` | Der Prompttext – eng geführt, damit Fachbegriffe unangetastet bleiben |
| `Einbau_DE.md` / `_EN.md` | Die Formeln, die in der App zu setzen sind |
| `Zusatz_Controls.yaml` | Die zusätzlichen Steuerelemente zum Einfügen |

### Warum keine Importdatei für den Flow?

In `output/05_Flows/` liegen für die große Fassung fertige
`.definition.json`-Dateien. Hier bewusst nicht: Die Aktionen des
AI-Builder-Connectors haben je nach Tenant und Region unterschiedliche Namen
und Schemata, und ich kann keine davon nachsehen. Eine Importdatei, die ich
hier hinschreibe, würde mit hoher Wahrscheinlichkeit **nicht importieren** –
und Sie hätten mehr Arbeit mit der Fehlersuche als mit dem Nachbauen.

Der Flow hat vier Aktionen. Die Anleitung dauert länger als das Bauen.

---

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Die Oberflächenergänzung gegen das pa.yaml-Schema | **ausgeführt, bestanden** |
| Der Flow | **nicht gebaut, nicht ausgeführt** – kein Tenant-Zugang |
| Der Prompt gegen echte Physio-Texte | **nicht getestet** |
| Kosten, Regionen, Lizenzstände | **nicht geprüft** – siehe Checkliste oben |

Die Aktionsnamen im Flow sind aus der Erinnerung beschrieben und können in
Ihrem Tenant abweichen. Die Anleitung sagt jeweils, wonach zu suchen ist.
