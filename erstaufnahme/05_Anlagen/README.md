# Das Anlagen-Formular einbauen

Der letzte Schritt. Danach können die Therapeuten das unterschriebene
Dokument und das Rezept direkt aus der App abfotografieren.

Rechnen Sie mit **15 Minuten**.

---

## Warum dieser Teil nicht im Code steht

Das **Anlagen-Steuerelement** von Power Apps gibt es nur **innerhalb eines
Formulars**. Ein Formular besteht aus automatisch erzeugten Datenkarten, und
die von Hand als YAML zu schreiben ist die fehleranfälligste Stelle im ganzen
Projekt – Studio erzeugt sie normalerweise selbst.

Deshalb die Arbeitsteilung: **Code für alles, was Code gut kann. Die
Studio-Oberfläche für das Formular** – da sind es sechs Klicks, die
zuverlässig funktionieren.

---

## Schritt 0 – Sind Anlagen überhaupt erlaubt?

In SharePoint: Liste **Rezept** → Zahnrad → **Listeneinstellungen** →
**Erweiterte Einstellungen** → **Anlagen**.

Muss auf **Anlagen zu dieser Liste zulassen** stehen. Das ist der Standard;
prüfen Sie es trotzdem, weil sonst gleich das Feld `Anlagen` im Formular
fehlt und Sie lange suchen.

## Schritt 1 – Formular einfügen

1. Im Baum **`conAnlagenPlatz`** auswählen (der leere Kasten in Schritt 3).
2. **Einfügen → Eingabe → Formular bearbeiten**.
3. Das neue Formular heißt `Form1`. Umbenennen in **`frmAnlagen`**.

Es landet innerhalb von `conAnlagenPlatz` – genau da soll es hin.

## Schritt 2 – Datenquelle und Datensatz

Formular auswählen, rechts im Eigenschaftenbereich:

| Eigenschaft | Wert |
|---|---|
| `DataSource` | `Rezept` |
| `Item` | `gblAufnahme` |
| `DefaultMode` | `FormMode.Edit` |

`gblAufnahme` ist der Datensatz, den Schritt 2 gerade angelegt hat. Das
Formular hängt also am richtigen Rezept, ohne dass jemand etwas auswählen
muss.

> Meldet Studio hier einen Fehler an `gblAufnahme`: Sie haben den
> Oberflächencode noch nicht eingefügt. Erst der Code, dann das Formular.

## Schritt 3 – Nur das Anlagenfeld zeigen

**Felder bearbeiten** → **Feld hinzufügen** → **`Anlagen`** auswählen.

Alle anderen Felder, die das Formular von sich aus mitgebracht hat, wieder
**entfernen**. Übrig bleibt eine einzige Karte: `Anlagen`.

Diagnose, Erstbefund und Anamnese stehen bereits in der Liste – Schritt 2 hat
sie geschrieben. Sie hier noch einmal zu zeigen, würde sie doppelt
bearbeitbar machen.

## Schritt 4 – Platz geben

An der Anlagen-Datenkarte:

| Eigenschaft | Wert |
|---|---|
| `Height` | `=300` |
| `Width` | `=Parent.Width - 2 * spM` |

Und am Formular selbst `Height: =340`.

## Schritt 5 – Speichern anhängen

Die Anlagen werden erst mit dem Absenden des Formulars hochgeladen. Ergänzen
Sie deshalb an **`btnAnlagenFertig`** ganz **vorne** in `OnSelect`:

```powerfx
SubmitForm(frmAnlagen);;
```

(In einem Studio mit englischen Trennzeichen: `SubmitForm(frmAnlagen);`)

Der Rest der Formel bleibt, wie er ist.

## Schritt 6 – Platzhalter löschen

`lblAnlagenPlatzhalter` im Baum löschen. Der war nur der Wegweiser.

---

## Durchspielen

| Prüfung | Erwartet |
|---|---|
| Aufnahme speichern | Schritt 3 erscheint, das Formular zeigt „Datei anfügen" |
| Am Telefon „Datei anfügen" | Auswahl mit Kamera, Fotomediathek, Dateien |
| Kamera, Dokumentenmodus, Foto | Die Datei erscheint als Anlage in der Liste |
| Zweite Datei anfügen | Beide stehen untereinander |
| „Aufnahme abschließen" | Grüne Meldung, zurück zu Schritt 1 |
| In SharePoint die Rezept-Zeile öffnen | Beide Dateien hängen am Eintrag |

Die letzte Zeile ist die wichtige: Erst wenn die Dateien **in SharePoint**
stehen, hat der Upload wirklich funktioniert.

---

## Zum Scannen

Einen Dokumentenscanner als Steuerelement gibt es in Canvas Apps nicht –
keine Kantenerkennung, keine Entzerrung. Was die Praxis stattdessen nutzt:
den **Dokumentenmodus der Telefonkamera**. iPhone und die meisten
Android-Kameras erkennen die Blattkanten, entzerren und liefern ein gerades
Bild. Das Ergebnis ist besser als das, was eine App-eigene Lösung
hinbekommen würde.

**Praxistipp fürs Team:** Beide Seiten desselben Dokuments als **zwei
Anlagen** anfügen, nicht als ein schiefes Foto von beiden. Und das Rezept
immer flach auf den Tisch, nicht in der Hand.

---

## Wenn das Formular Ärger macht

Dann bleibt der Weg über einen Flow: ein „Bild hinzufügen"-Steuerelement in
der App, ein Power-Automate-Flow legt die Datei als Anlage ab. Mehr Teile,
aber vollständig per Code einfügbar. Sagen Sie Bescheid, dann baue ich das
als Alternative – es ist kein Neuanfang, nur Schritt 3 wird ausgetauscht.

---

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Der Oberflächencode gegen das pa.yaml-Schema | **ausgeführt, bestanden** |
| Dieses Formular | **nicht gebaut, nicht getestet** – kein Studio-Zugang |
| Anlagen-Einstellung der Liste `Rezept` | **nicht geprüft** – kein Tenant-Zugang |

Die Eigenschaftsnamen (`DataSource`, `Item`, `DefaultMode`) sind die
Standardnamen des Formular-Steuerelements. Weicht Ihre Studio-Version ab,
steht der passende Name im Eigenschaftenbereich rechts.
