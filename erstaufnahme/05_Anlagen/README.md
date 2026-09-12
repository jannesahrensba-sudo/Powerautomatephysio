# Das Anlagen-Formular

Seit der aktuellen Fassung steckt das Formular **im Oberflächencode** – Sie
müssen es nicht mehr von Hand anlegen. `01_AppShell_einfuegen.yaml` enthält
`frmAnlagen` samt Datenkarte, fertig verdrahtet.

Diese Datei erklärt, **wie es funktioniert** und **woran es hängt**, wenn es
nicht tut.

---

## Die Falle, in die ich Sie geschickt habe

In einer früheren Fassung stand hier, Sie sollten bei `Item` eintragen:

```
=LookUp(Rezepte; ID = gblAufnahmeID)
```

**Das führende `=` ist falsch.** In der Formelleiste von Studio steht das
Gleichheitszeichen **schon davor**. Tippen Sie es mit, entsteht

```
==LookUp(Rezepte; ID = gblAufnahmeID)
```

und Power Apps meldet einen Fehler an `LookUp` – nicht am Namen, sondern an
der **Funktion**, weil `=LookUp(...)` kein gültiger Ausdruck ist. Genau
deshalb sah es aus, als wäre `LookUp` das Problem.

Richtig ist in der Formelleiste **ohne** `=`:

```
LookUp(Rezepte; ID = gblAufnahme.ID)
```

In YAML-Dateien steht das `=` dagegen mit – dort ist es Teil der Schreibweise
(`Item: =LookUp(...)`). Diese doppelte Konvention ist die häufigste
Verwechslung beim Abtippen aus Dokumentation.

---

## Wie die Bindung arbeitet

```powerfx
DataSource   = Rezepte
Item         = LookUp(Rezepte; ID = gblAufnahme.ID)
DefaultMode  = FormMode.Edit
```

Nach dem Speichern in Schritt 2 steht in `gblAufnahme` die gerade angelegte
Zeile. Das Formular nimmt daraus nur die **Nummer** und holt sich die Zeile
frisch aus der Liste. Das ist verlässlicher, als den Rückgabewert von `Patch`
direkt zu binden: ein Formular will eine echte Zeile der Datenquelle, nicht
ein Abbild aus dem Moment des Schreibens.

## Warum das Aufräumen im Formular steht, nicht in der Schaltfläche

`SubmitForm` arbeitet **asynchron**. In der vorigen Fassung stand in
`btnAnlagenFertig`:

```powerfx
SubmitForm(frmAnlagen);;
Set(gblAufnahme; Blank());;      // <- Problem
...
```

Die zweite Zeile läuft los, während noch hochgeladen wird. Damit wird
`gblAufnahme` leer, `Item` findet keine Zeile mehr – und das Formular verliert
mitten im Senden seinen Datensatz. Die Datei kommt dann möglicherweise nie an.

Deshalb jetzt:

| Wo | Was |
|---|---|
| `btnAnlagenFertig.OnSelect` | nur `SubmitForm(frmAnlagen)` |
| `frmAnlagen.OnSuccess` | aufräumen, Meldung, zurück zu Schritt 1 |
| `frmAnlagen.OnFailure` | Fehlermeldung, **bleibt** auf Schritt 3 |

Bei Misserfolg bleibt der Therapeut also stehen und kann es erneut versuchen.
Die Aufnahme selbst ist längst gespeichert – das sagt die Meldung auch.

`OnSelect` hat zusätzlich einen Notzweig für den Fall, dass keine Zeile offen
ist: `SubmitForm` täte dann nämlich nichts, `OnSuccess` würde nicht feuern,
und die Schaltfläche wäre wirkungslos.

---

## Schritt 0 – Sind Anlagen erlaubt?

Das ist die einzige Voraussetzung, die außerhalb der App liegt.

In SharePoint: Liste **Rezepte** → Zahnrad → **Listeneinstellungen** →
**Erweiterte Einstellungen** → **Anlagen**.

Muss auf **Anlagen zu dieser Liste zulassen** stehen. Das ist der Standard.
Nach einer Änderung in Power Apps Studio **Daten → Rezepte → Aktualisieren**,
sonst kennt die App die neue Einstellung nicht.

---

## Fehlersuche

### Der Kopf von Schritt 3 sagt Ihnen, wo es hängt

> Max Mustermann · **gespeichert als Nr. 42**

| Was dort steht | Bedeutung | Wo suchen |
|---|---|---|
| „gespeichert als Nr. **42**" | Die Zeile existiert. | im Formular |
| „**noch nicht gespeichert**" | `gblAufnahme` ist leer. | in Schritt 2 |

### „Keine anzuzeigenden Elemente"

Der Leerzustand eines Formulars im Bearbeiten-Modus, dessen `Item` nichts
findet. Der Reihe nach:

1. **`==` in `Item`.** Siehe oben – das führende `=` in der Formelleiste
   weglassen.
2. **Falscher Datenquellenname.** In dieser App heißt sie `Rezepte`. Ein
   `Rezept` hier macht `LookUp` rot. Umgekehrt gilt in der Behandlungs-App
   `Rezept`. Maßgeblich ist jeweils der Name im Bereich **Daten** *dieser*
   App, nicht der Listenname.
3. **`DefaultMode` steht auf `FormMode.New`.** Dann ignoriert das Formular
   `Item` und legt eine zweite Zeile an. Muss `FormMode.Edit` sein.
4. **Sie testen in der Vorschau, ohne vorher gespeichert zu haben.**
   `gblAufnahme` ist leer, `LookUp` findet nichts – richtig so. Spielen Sie
   Schritt 1 bis 3 einmal durch.

### Das Feld `Anlagen` bleibt leer oder fehlt

Anlagen sind an der Liste abgeschaltet – zurück zu **Schritt 0**, danach in
Studio **Daten → Rezepte → Aktualisieren**.

### Anhängen geht, in SharePoint kommt nichts an

`SubmitForm(frmAnlagen)` fehlt in `btnAnlagenFertig`, oder das Aufräumen steht
noch **hinter** `SubmitForm` statt in `OnSuccess` – siehe oben.

### Die Schaltfläche „Aufnahme abschließen" tut nichts

Dann feuert weder `OnSuccess` noch `OnFailure`. Prüfen Sie, ob `OnSuccess` am
**Formular** hängt und nicht an der Datenkarte.

---

## Durchspielen

| Prüfung | Erwartet |
|---|---|
| Aufnahme speichern | Schritt 3, im Kopf „gespeichert als Nr. …" |
| Das Formular | „Datei anfügen", **nicht** „Keine anzuzeigenden Elemente" |
| Am Telefon „Datei anfügen" | Auswahl mit Kamera, Fotomediathek, Dateien |
| Kamera, Dokumentenmodus, Foto | Die Datei erscheint in der Liste im Formular |
| Zweite Datei anfügen | Beide stehen untereinander |
| „Aufnahme abschließen" | Grüne Meldung, zurück zu Schritt 1 |
| **In SharePoint die Zeile mit dieser Nummer öffnen** | **Beide Dateien hängen am Eintrag** |

Die letzte Zeile ist die entscheidende. Erst wenn die Dateien **in
SharePoint** stehen, hat der Upload funktioniert.

---

## Zum Scannen

Einen Dokumentenscanner als Steuerelement gibt es in Canvas Apps nicht –
keine Kantenerkennung, keine Entzerrung. Was die Praxis stattdessen nutzt:
den **Dokumentenmodus der Telefonkamera**. iPhone und die meisten
Android-Kameras erkennen die Blattkanten, entzerren und liefern ein gerades
Bild – besser als das, was eine App-eigene Lösung hinbekäme.

**Praxistipp fürs Team:** Beide Seiten desselben Dokuments als **zwei
Anlagen** anfügen, nicht als ein schiefes Foto von beiden. Und das Rezept
flach auf den Tisch, nicht in der Hand.

---

## Wenn das Formular weiter Ärger macht

Dann bleibt der Weg über einen Flow: ein „Bild hinzufügen"-Steuerelement in
der App, ein Power-Automate-Flow legt die Datei als Anlage ab. Mehr Teile,
aber ohne Formular. Sagen Sie Bescheid – es ist kein Neuanfang, nur Schritt 3
wird ausgetauscht.

---

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Der Oberflächencode gegen das pa.yaml-Schema, Formular inbegriffen | **ausgeführt, bestanden** |
| Formular, Upload, `OnSuccess`/`OnFailure` | **nicht ausgeführt** – kein Studio-Zugang |
| Anlagen-Einstellung der Liste `Rezepte` | **nicht geprüft** – kein Tenant-Zugang |

Die Datenkarte im Code stammt aus **Ihrem** Studio-Export – sie ist also in
Ihrem Tenant erzeugt worden, nicht von mir erfunden. Geändert habe ich daran
nur die feste Breite von 1272 Punkten (läuft am Handy aus dem Bild) und die
Farben, damit die Karte zum Rest passt.
