# Den Flow `Rezept_Ablegen` bauen

Vier Aktionen, etwa 15 Minuten. Name: **`Rezept_Ablegen`** (genau so – die App
ruft ihn unter diesem Namen auf).

> Die Aktionsnamen sind aus der Erinnerung beschrieben. Microsoft benennt sie
> gelegentlich um. Wo der Name abweicht, steht daneben, wonach zu suchen ist.

---

## Schritt 0 – Wohin die Dateien sollen

Legen Sie in SharePoint eine **Dokumentbibliothek** an, zum Beispiel
`Rezeptbilder`. Eine Bibliothek, keine Liste – Bibliotheken sind für Dateien
gemacht.

Berechtigungen: mindestens so eng wie die Patientenlisten. Es sind
Gesundheitsdaten.

## Schritt 1 – Flow anlegen

**make.powerautomate.com → Erstellen → Sofortiger Cloud-Flow**

- Name: `Rezept_Ablegen`
- Trigger: **PowerApps (V2)**

Nicht „PowerApps" ohne V2 – nur V2 erlaubt benannte Eingaben.

## Schritt 2 – Drei Eingaben am Trigger

**+ Eingabe hinzufügen**, dreimal, **in dieser Reihenfolge**:

| Reihenfolge | Typ | Name |
|---|---|---|
| 1 | Zahl | `PatientID` |
| 2 | Text | `Dateiname` |
| 3 | Text | `Inhalt` |

**Die Reihenfolge ist bindend.** Die App übergibt genau so; vertauscht landet
der Dateiname im Inhalt.

## Schritt 3 – Das Bild aus dem Text herausholen

Die App schickt das Foto als **Daten-URI**, also so:

```
"data:image/jpeg;base64,/9j/4AAQSkZJRg..."
```

Davor stehen Anführungszeichen (die kommen von `JSON`), und vor den eigentlichen
Bilddaten steht der Präfix bis zum Komma. Beides muss weg.

**Neuer Schritt → Variable initialisieren**

| Feld | Wert |
|---|---|
| Name | `Bild` |
| Typ | Zeichenfolge |
| Wert | `@{last(split(replace(triggerBody()['text_1'], '"', ''), ','))}` |

Was der Ausdruck macht, von innen nach außen:

1. `replace(..., '"', '')` – entfernt die Anführungszeichen
2. `split(..., ',')` – zerlegt am Komma
3. `last(...)` – nimmt den Teil hinter dem Komma, also die reinen Bilddaten

> `triggerBody()['text_1']` ist die **dritte** Eingabe. Power Automate zählt
> Textfelder ab 0: `text` ist `Dateiname`, `text_1` ist `Inhalt`. `PatientID`
> ist eine Zahl und heißt `number`. Am sichersten setzen Sie die Felder über
> den Inhaltsauswahldialog ein und legen die Funktionen darum.

## Schritt 4 – Datei schreiben

**Neuer Schritt → SharePoint → „Datei erstellen"**

| Feld | Wert |
|---|---|
| Websiteadresse | Ihre Praxis-Website |
| Ordnerpfad | `/Rezeptbilder` |
| Dateiname | die Trigger-Eingabe `Dateiname` |
| Dateiinhalt | `@{base64ToBinary(variables('Bild'))}` |

`base64ToBinary` macht aus dem Text wieder Bytes. Ohne das landet eine
Textdatei in der Bibliothek, die kein Bildbetrachter öffnet.

## Schritt 5 – Antwort an die App

**Neuer Schritt → „Auf eine PowerApp oder einen Flow antworten"**

Eine Textausgabe:

| Name | Wert |
|---|---|
| `Pfad` | der Dateipfad aus Schritt 4 |

Die App prüft nur, ob der Flow ohne Fehler zurückkam – sie liest den Pfad
derzeit nicht aus. Die Ausgabe ist für später gedacht (etwa um die Datei in der
Akte zu verlinken).

Speichern.

---

## Testen, bevor die App drankommt

In Power Automate **Testen → Manuell**. Als `Inhalt` brauchen Sie einen echten
Daten-URI. Am schnellsten: ein kleines Bild bei einem Base64-Konverter
hochladen und das Ergebnis mit `data:image/jpeg;base64,` davor einfügen.

**Erwartet:** Die Datei liegt in `Rezeptbilder` und öffnet als Bild.

Öffnet sie nicht: Schritt 3 oder `base64ToBinary` stimmt nicht. Sehen Sie im
Flow-Verlauf nach, was in `Bild` stand – beginnt es mit `data:` oder `"`, hat
das Zerlegen nicht gegriffen.

---

## Erst dann: die App verbinden

Weiter mit **[`README.md`](README.md)**, Abschnitt „Einbau".

---

## Warum keine Importdatei

Wie bei den anderen Flows in diesem Projekt: Eine
`.definition.json`, die ich hier hinschreibe, ohne sie importieren zu können,
würde mit hoher Wahrscheinlichkeit **nicht importieren** – und Sie hätten mehr
Arbeit mit der Fehlersuche als mit dem Nachbauen. Vier Aktionen sind schneller
geklickt als eine kaputte Importdatei repariert.
