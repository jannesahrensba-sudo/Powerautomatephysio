# Die roten Unterringelungen – was sie bedeuten

**Kurz: Das sind keine Fehler im Code. Die Spalten gibt es in SharePoint noch
nicht.**

Power Apps prüft jeden Spaltennamen gegen die verbundene Liste. Findet es
`Massnahmen` dort nicht, unterringelt es die Stelle – völlig unabhängig davon,
ob die Formel richtig geschrieben ist.

Deshalb hilft **kein Umschreiben der Formel**. Sobald die Spalte existiert und
die Datenquelle aktualisiert ist, verschwinden die Markierungen von selbst,
ohne dass Sie eine Zeile anfassen.

## Woran man es erkennt

Zwei Beobachtungen aus Ihren Screenshots bestätigen das:

- Im `Patch` ist der **gesamte Datensatz** `{ … }` unterringelt, einschließlich
  der schließenden Klammer. So markiert Power Apps einen unbekannten
  Spaltennamen, nicht einen Syntaxfehler.
- `Vorname`, `Nachname` und `Geburtsdatum` sind **nicht** markiert. Genau diese
  drei Spalten funktionieren bei Ihnen ja bereits – die Patientenliste wird
  korrekt angezeigt.

## Was zu tun ist

**Entweder** die Spalten von Hand in SharePoint anlegen – das ist der
verlässlichste Weg und dauert etwa zehn Minuten:

→ **[`Spalten_manuell_anlegen.md`](Spalten_manuell_anlegen.md)**

**Oder** mit dem Skript, wenn PnP.PowerShell bei Ihnen läuft:

```powershell
cd v2
.\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
.\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis"
```

> **Danach unbedingt:** In Power Apps Studio **Daten → die Liste auswählen →
> Aktualisieren**. Ohne diesen Schritt kennt Studio weiterhin nur das alte
> Schema, und die Markierungen bleiben stehen, obwohl die Spalten da sind.

## Wenn eine Spalte bei Ihnen anders heißt

Dann – und nur dann – brauchen Sie die Formelliste:

→ **[`Formeln_je_Steuerelement_DE.md`](Formeln_je_Steuerelement_DE.md)**
  (oder `_EN.md`, falls Ihr Studio auf Englisch läuft)

Dort steht jede betroffene Formel einzeln, mit Steuerelement und Eigenschaft,
fertig zum Einfügen. Sie tauschen darin nur den Spaltennamen aus.

Die Liste ist **aus dem Oberflächencode erzeugt**, nicht abgetippt – sie kann
also nicht vom Code abweichen.

## Nebenbei behoben: Gedankenstriche

In der Formelleiste erschienen `–` (Gedankenstrich) und `…`
(Auslassungspunkte) als leere Kästchen. Die Schrift der Formelleiste kennt
diese Zeichen nicht. Sie sind jetzt durch `-` und `...` ersetzt.

Umlaute und der Mittelpunkt `·` sind davon **nicht** betroffen – die werden
korrekt dargestellt, wie in Ihren Screenshots zu sehen.

## Betroffen sind 12 Formeln

| Steuerelement | Eigenschaft | Fragliche Spalten |
|---|---|---|
| `galHeute` | `Items` | `Behandlungsdatum` |
| `lblHeuteName` | `Text` | `PatientID` |
| `lblHeuteZeile2` | `Text` | `Massnahmen`, `Therapeut` |
| `btnPatWaehlen` | `OnSelect` | `PatientID` |
| `lblTerminZahl` | `Text` | `PatientID` |
| `lblTerminUnter` | `Text` | `PatientID` |
| `lblBefundText` | `Text` | `Anamnese`, `Diagnose laut Rezept`, `Erstbefund` |
| `drpTherapeut` | `Items` | `Therapeut` |
| `galVerlauf` | `Items` | `PatientID` |
| `lblVerlaufKopf` | `Text` | `Behandlungsdatum`, `Therapeut` |
| `lblVerlaufText` | `Text` | `Heimuebungen`, `Massnahmen`, `Reaktion` |
| `btnDokuSpeichern` | `OnSelect` | alle sieben der Dokumentation |

Alle zwölf werden von denselben neun Spalten verursacht. Legen Sie die an, und
alle zwölf sind erledigt.
