# Rezept fotografieren – optionaler Zusatz

> **Nicht Teil der App.** Die Erstaufnahme funktioniert vollständig ohne
> diesen Ordner. Er braucht einen Power-Automate-Flow.

Was er ergänzt: in Schritt 2 der Erstaufnahme-App eine Kamera. Ein Tipp löst
aus, die Aufnahme erscheint als Vorschau, „Foto ablegen" schickt sie in eine
SharePoint-Dokumentbibliothek – benannt nach Patient und Zeitpunkt.

---

## Warum hier und nicht in der Anmelde-App

Naheliegend wäre: der Patient meldet sich am iPad an, die Rezeption
fotografiert im selben Gerät das Rezept. **Das wäre ein Datenschutzproblem.**

Zum Ablegen eines Fotos braucht man einen Patienten. In der Anmelde-App ist
noch keiner ausgewählt – es müsste also eine Patientensuche hinein. Und diese
App liegt im Wartebereich in der Hand von Patienten. Eine Suche darin heißt:
jeder kann die Namen aller anderen Patienten lesen.

In der **Erstaufnahme-App** ist der Patient in Schritt 1 ohnehin schon
gewählt, und die App ist Mitarbeitersache. Es braucht dort gar keine Auswahl –
die Kamera weiß aus `gblPatient`, zu wem das Rezept gehört.

---

## Warum ein Flow nötig ist

Ein Bild aus einer Canvas-App in SharePoint zu bekommen, geht zuverlässig nur
über Power Automate. Die App hat das Foto als Bildwert im Speicher; sie kann
es einem Flow als Text übergeben, und der Flow schreibt daraus eine Datei.

Die Wege ohne Flow sind alle unzuverlässig: Anlagen brauchen ein Formular (das
haben wir aus gutem Grund wieder ausgebaut), und ein Foto als Text in eine
Spalte zu schreiben sprengt die Feldlänge.

Der Flow hat **vier Aktionen**. Anleitung: **[`Flow_bauen.md`](Flow_bauen.md)**

---

## Einbau

**Voraussetzung:** Der Flow `Rezept_Ablegen` ist gebaut und getestet.

### 1. Flow verbinden

In Power Apps Studio: **Power Automate → Flow hinzufügen → `Rezept_Ablegen`**.

Erscheint er nicht, liegt er in einer anderen Umgebung als die App.

### 2. Drei Zeilen in `App.OnStart`

```powerfx
Set(gblFotoLaeuft; false);;
Set(gblFotoFehler; "");;
```

(Englische Trennzeichen: `Set(gblFotoLaeuft, false);` usw.)

`gblFoto` und `gblFotoErgebnis` gehören **nicht** dazu. Das eine ist ein Bild,
das andere ein Flow-Ergebnis – ein `Set(..., "")` würde sie zu Text machen.
Eine nie gesetzte Variable ist in Power Apps bereits leer.

### 3. Steuerelemente einfügen

1. Im Baum **`conBefund`** auswählen.
2. Rechtsklick → **Code einfügen**.
3. Vollständigen Inhalt von **`Zusatz_Controls.yaml`** einfügen.
4. **`conBefundAktionen`** im Baum wieder ganz nach unten ziehen, damit
   „Aufnahme speichern" unter der Kamera steht.

Die neun Elemente hängen an `gblPatient` und `gblMeldung` – beides ist in der
App schon vorhanden.

---

## Durchspielen

| Prüfung | Erwartet |
|---|---|
| Schritt 2 ohne Aufnahme | Kamerabild sichtbar, „Foto ablegen" grau |
| Auf das Kamerabild tippen | Vorschau erscheint darunter |
| „Verwerfen" | Vorschau weg, Kamera wieder allein |
| Erneut tippen, „Foto ablegen" | „Legt ab …", dann grüne Meldung |
| **In der Dokumentbibliothek nachsehen** | **Datei `Rezept_<ID>_<Datum>.jpg` liegt da** |
| Flow deaktivieren, „Foto ablegen" | Rote Meldung, **Aufnahme bleibt stehen** |
| Danach normal speichern | Funktioniert, unabhängig vom Foto |

Die letzten zwei Zeilen sind die wichtigen: Ein ausgefallener Foto-Upload darf
niemanden daran hindern, den Befund zu dokumentieren – und die Aufnahme darf
nicht verloren gehen, sonst muss der Patient das Rezept nochmal hervorholen.

---

## Zur Bildqualität

Einen Dokumentenscanner als Steuerelement gibt es in Canvas Apps nicht – keine
Kantenerkennung, keine Entzerrung. Das `Camera`-Steuerelement liefert ein
gerades Kamerabild, nicht mehr.

**Für die Praxis heißt das:** Rezept flach auf den Tisch, gutes Licht, von oben
fotografieren. Das steht auch als Hinweis in der App.

Wenn die Qualität nicht reicht, ist der bessere Weg: mit der **Kamera-App des
iPads** im Dokumentenmodus fotografieren (die entzerrt) und die Datei danach in
SharePoint hochladen. Weniger elegant, deutlich besseres Ergebnis.

---

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Die Oberflächenergänzung gegen das pa.yaml-Schema | **ausgeführt, bestanden** |
| Der Flow | **nicht gebaut, nicht ausgeführt** – kein Tenant-Zugang |
| Das `Camera`-Steuerelement in Ihrem Tenant | **nicht geprüft** – es steht in der offiziellen Typenliste, ist aber in Ihrem Studio noch nie gelaufen |
| `JSON(..., JSONFormat.IncludeBinaryData)` | **nicht geprüft** |

`Camera` ist das einzige Steuerelement in diesem Projekt, das ich einbaue, ohne
dass es in Ihrem Tenant schon durchgelaufen ist. Es steht in der
veröffentlichten Typenliste von Power Apps – anders als `PenInput`, weshalb es
in der Anmelde-App keine gemalte Unterschrift gibt. Sollte es beim Einfügen
Ärger machen, ist es ein einzelnes Element und schnell ersetzt.
