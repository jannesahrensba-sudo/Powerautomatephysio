# Das Anlagen-Formular einbauen

Danach können die Therapeuten das unterschriebene Dokument und das Rezept
direkt aus der App abfotografieren.

> **Sehen Sie „Keine anzuzeigenden Elemente"?**
> → Direkt zu **[Fehlersuche](#fehlersuche)**. Das Formular steht, findet aber
> keinen Datensatz. Häufigste Ursache ist eine fehlende oder falsche
> `Item`-Eigenschaft.

---

## Warum dieser Teil nicht im Code steht

Das **Anlagen-Steuerelement** von Power Apps gibt es nur **innerhalb eines
Formulars**. Ein Formular besteht aus automatisch erzeugten Datenkarten, und
die von Hand als YAML zu schreiben ist die fehleranfälligste Stelle im ganzen
Projekt – Studio erzeugt sie normalerweise selbst.

Deshalb die Arbeitsteilung: **Code für alles, was Code gut kann. Die
Studio-Oberfläche für das Formular.**

---

## Schritt 0 – Sind Anlagen überhaupt erlaubt?

In SharePoint: Liste **Rezept** → Zahnrad → **Listeneinstellungen** →
**Erweiterte Einstellungen** → **Anlagen**.

Muss auf **Anlagen zu dieser Liste zulassen** stehen. Das ist der Standard;
prüfen Sie es trotzdem, sonst fehlt gleich das Feld `Anlagen` im Formular und
Sie suchen an der falschen Stelle.

Nach einer Änderung in SharePoint: in Power Apps Studio **Daten → Rezept →
Aktualisieren**. Sonst kennt die App die neue Einstellung nicht.

## Schritt 1 – Formular einfügen

1. Im Baum **`conAnlagenPlatz`** auswählen (der Kasten in Schritt 3).
2. **Einfügen → Eingabe → Formular bearbeiten**.
3. Das neue Formular heißt `Form1`. Umbenennen in **`frmAnlagen`**.

## Schritt 2 – Die drei Eigenschaften, auf die es ankommt

Formular auswählen, rechts im Eigenschaftenbereich:

| Eigenschaft | Wert |
|---|---|
| `DataSource` | `Rezept` |
| `Item` | `=LookUp(Rezept; ID = gblAufnahmeID)` |
| `DefaultMode` | `FormMode.Edit` |

In einem Studio mit englischen Trennzeichen: `=LookUp(Rezept, ID = gblAufnahmeID)`

> **`Rezept`, Einzahl.** Die SharePoint-Liste heißt vielleicht „Rezepte" –
> maßgeblich ist der Name im Bereich **Daten** dieser App. Ein `Rezepte`
> hier macht `LookUp` rot.

**`Item` ist die Eigenschaft, an der es fast immer scheitert.** Bleibt sie
leer, zeigt das Formular im Bearbeiten-Modus „Keine anzuzeigenden Elemente" –
und zwar völlig unabhängig davon, ob die Aufnahme gespeichert wurde.

> **Warum `LookUp` und nicht direkt der gespeicherte Datensatz?**
> Die App merkt sich nach dem Speichern nur die **Nummer** der Zeile
> (`gblAufnahmeID`), nicht den Datensatz selbst. Das Formular holt sich die
> Zeile damit frisch aus der Liste. Das ist verlässlicher, als den
> Rückgabewert von `Patch` an ein Formular zu binden – der ist ein Abbild aus
> dem Moment des Schreibens, und ein Formular will eine echte Zeile der
> Datenquelle.

## Schritt 3 – Nur das Anlagenfeld zeigen

**Felder bearbeiten** → **Feld hinzufügen** → **`Anlagen`** auswählen.

Alle anderen Felder, die das Formular mitgebracht hat, wieder **entfernen**.
Übrig bleibt eine einzige Karte: `Anlagen`.

Diagnose, Erstbefund und Anamnese stehen bereits in der Liste – Schritt 2 der
App hat sie geschrieben. Sie hier noch einmal zu zeigen, würde sie doppelt
bearbeitbar machen.

## Schritt 4 – Platz geben

An der Anlagen-Datenkarte:

| Eigenschaft | Wert |
|---|---|
| `Height` | `=300` |
| `Width` | `=Parent.Width - 2 * spM` |

Am Formular selbst: `Height: =340`.

## Schritt 5 – Speichern anhängen

Die Anlagen werden erst beim Absenden des Formulars hochgeladen. Ergänzen Sie
an **`btnAnlagenFertig`** ganz **vorne** in `OnSelect`:

```powerfx
SubmitForm(frmAnlagen);;
```

(Englische Trennzeichen: `SubmitForm(frmAnlagen);`)

Der Rest der Formel bleibt, wie er ist.

## Schritt 6 – Platzhalter löschen

`lblAnlagenPlatzhalter` im Baum löschen. Der war nur der Wegweiser.

---

## Fehlersuche

### Der Kopf von Schritt 3 sagt Ihnen, woran es liegt

Die App zeigt dort seit der letzten Fassung die Nummer der gespeicherten
Zeile:

> Max Mustermann · **gespeichert als Nr. 42**

Das ist keine Deko, sondern die Diagnose. Lesen Sie sie zuerst:

| Was dort steht | Bedeutung | Was zu tun ist |
|---|---|---|
| „gespeichert als Nr. **42**" | Die Zeile existiert, `gblAufnahmeID` ist gefüllt. Das Problem liegt **im Formular**. | Weiter unten bei „Formular findet nichts" |
| „**noch nicht gespeichert**" | `gblAufnahmeID` ist 0. Die App ist schuld, nicht das Formular. | Weiter unten bei „Nummer bleibt 0" |

Steht dort noch gar keine Nummer, haben Sie eine ältere Fassung des
Oberflächencodes eingefügt – dann `01_AppShell_einfuegen.yaml` noch einmal
einfügen.

### „Keine anzuzeigenden Elemente" – Formular findet nichts

Der Reihe nach, die häufigste Ursache zuerst:

0. **`Rezepte` statt `Rezept` getippt.** Ein Buchstabe, und `LookUp` wird
   rot – nicht der Name, sondern die **Funktion**: Power Apps meldet einen
   ungültigen Parameter, wenn das erste Argument keine gültige Tabelle ist.

   Die Datenquelle heißt in beiden Apps **`Rezept`**, Einzahl. Die
   SharePoint-Liste dahinter mag „Rezepte" heißen – maßgeblich ist der Name
   im Bereich **Daten** dieser App, nicht der Listenname.

   Gegenprobe, falls Sie unsicher sind: Wenn Ihr Speichern in Schritt 2
   funktioniert hat, ist `Rezept` der richtige Name. Die Formel dahinter
   lautet `Patch(Rezept; Defaults(Rezept); …)` – hieße die Datenquelle
   anders, wäre schon die gescheitert.

1. **`Item` ist leer.** Die mit Abstand häufigste Ursache. Formular
   auswählen, in der Eigenschaftenliste links oben `Item` wählen und
   `=LookUp(Rezept; ID = gblAufnahmeID)` eintragen. Achtung: Studio zeigt
   `Item` nicht im bequemen rechten Bereich, sondern nur in der Auswahlliste
   über der Formelleiste.
2. **`DataSource` ist leer oder eine andere Liste.** Muss `Rezept` sein –
   dieselbe Datenquelle, aus der `LookUp` liest.
3. **`DefaultMode` steht auf `FormMode.New`.** Dann ignoriert das Formular
   `Item` und legt eine zweite Zeile an. Muss `FormMode.Edit` sein.
4. **Die Datenquelle `Rezept` fehlt in der App.** Daten → Daten hinzufügen.
5. **Sie testen in der Vorschau, ohne vorher gespeichert zu haben.**
   `gblAufnahmeID` ist dann 0 und `LookUp` findet nichts – richtig so. Spielen
   Sie Schritt 1 bis 3 einmal durch.

### Nummer bleibt 0 – die App speichert nicht

Dann hat `Patch` keine Zeile angelegt. Das würde aber eine **rote**
Fehlermeldung erzeugen, keine grüne. Kommt trotzdem die grüne Meldung und die
Nummer bleibt 0, fehlt `Set(gblAufnahmeID; 0)` in `App.OnStart` – dann ist die
Variable nirgends angelegt. Nachtragen aus `02_Eigenschaften_DE.md`.

### Das Feld `Anlagen` taucht bei „Feld hinzufügen" nicht auf

Anlagen sind an der Liste abgeschaltet – zurück zu **Schritt 0**. Danach in
Studio **Daten → Rezept → Aktualisieren**, sonst bleibt das Feld weg.

### Anhängen geht, aber in SharePoint kommt nichts an

`SubmitForm(frmAnlagen)` fehlt in `btnAnlagenFertig` – siehe **Schritt 5**.
Ohne Absenden bleibt die Datei nur im Formular stehen.

---

## Durchspielen

| Prüfung | Erwartet |
|---|---|
| Aufnahme speichern | Schritt 3 erscheint, im Kopf steht „gespeichert als Nr. …" |
| Das Formular | Zeigt „Datei anfügen", **nicht** „Keine anzuzeigenden Elemente" |
| Am Telefon „Datei anfügen" | Auswahl mit Kamera, Fotomediathek, Dateien |
| Kamera, Dokumentenmodus, Foto | Die Datei erscheint in der Liste im Formular |
| Zweite Datei anfügen | Beide stehen untereinander |
| „Aufnahme abschließen" | Grüne Meldung, zurück zu Schritt 1 |
| **In SharePoint die Zeile mit dieser Nummer öffnen** | **Beide Dateien hängen am Eintrag** |

Die letzte Zeile ist die entscheidende. Erst wenn die Dateien **in
SharePoint** stehen, hat der Upload wirklich funktioniert.

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
aber vollständig per Code einfügbar und ohne Formular. Sagen Sie Bescheid –
es ist kein Neuanfang, nur Schritt 3 wird ausgetauscht.

---

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Der Oberflächencode gegen das pa.yaml-Schema | **ausgeführt, bestanden** |
| Dieses Formular | **nicht gebaut, nicht getestet** – kein Studio-Zugang |
| Anlagen-Einstellung der Liste `Rezept` | **nicht geprüft** – kein Tenant-Zugang |

Die Eigenschaftsnamen (`DataSource`, `Item`, `DefaultMode`) sind die
Standardnamen des Formular-Steuerelements. Weicht Ihre Studio-Version ab,
steht der passende Name in der Auswahlliste über der Formelleiste.
