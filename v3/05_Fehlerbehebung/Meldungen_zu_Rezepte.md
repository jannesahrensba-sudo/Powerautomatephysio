# Meldungen rund um die Liste „Rezepte"

## Was sich geändert hat

Die Meldung an dieser Zeile ist **weg – die Zeile gibt es nicht mehr**:

```powerfx
RezeptID: If(IsBlank(gblRezept); Blank(); gblRezept.ID)
```

Bei der Suche nach der Ursache ist aufgefallen: `RezeptID` wurde
**geschrieben, aber nirgends gelesen**. In der einfachen Fassung hängt alles
am Patienten – die Terminzählung, der Verlauf und die Heute-Liste laufen über
`PatientID`. Das Feld stammte aus der ausführlichen Fassung in `output/`, wo
Einheiten je Rezept gezählt werden und der Bezug deshalb gebraucht wird.

Ein Feld zu schreiben, das niemand liest, und dafür eine Fehlermeldung in Kauf
zu nehmen – das war schlicht falsch. Die Zeile ist entfernt, damit auch die
Spalte `RezeptID` und die Abhängigkeit von `gblRezept` beim Speichern.

Ziehen Sie dafür `01_AppShell_einfuegen.yaml` neu und fügen Sie es erneut ein.

---

## Falls noch eine Meldung an `Rezepte` hängt

Es bleibt genau **eine** Stelle, die die Liste `Rezepte` anspricht – der
Nachschlag in `btnPatWaehlen`:

```powerfx
Set(
    gblRezept,
    First(Sort(Filter(Rezepte, PatientID = ThisItem.ID), ID, SortOrder.Descending))
)
```

Von ihr bekommt `gblRezept` seinen Typ, und daraus speist sich die Befundkarte.

### Weg 1 – die Spalte anlegen (2 Minuten)

Liste **Rezepte** öffnen → **+ Spalte hinzufügen** → **Zahl** → Name genau
`PatientID` → **Speichern**.

Dabei prüfen, ob es dort auch `Erstbefund` und `Anamnese` gibt (jeweils
**Mehrere Textzeilen**).

Danach in Studio: **Daten → `Rezepte` → Aktualisieren**.

> Ohne das Aktualisieren kennt Studio weiter das alte Schema, und die Meldung
> bleibt stehen, obwohl die Spalte da ist.

**Damit die Befundkarte auch etwas anzeigt,** muss bei mindestens einem Rezept
`PatientID` befüllt sein – also die SharePoint-`ID` des Patienten eintragen.

### Weg 2 – ohne Rezepte starten

**[`AppShell_ohne_Rezepte.yaml`](AppShell_ohne_Rezepte.yaml)** ist
inhaltsgleich, nur ohne jeden Zugriff auf `Rezepte`. Es entfällt allein die
Befundkarte – Terminzählung, Verlauf, Dokumentation und Heute-Liste bleiben.

Sie schreibt in dieselben Spalten. Ein späterer Wechsel zurück auf
`01_AppShell_einfuegen.yaml` verliert also keine Daten.

---

## Gelbe Dreiecke statt roter Wellen

Gelb ist eine **Warnung**, kein Fehler. An der Terminnummer steht eine:

```powerfx
CountRows(Filter(Behandlungsdokumentation, PatientID = gblPatient.ID))
```

Power Apps kann `CountRows` über eine gefilterte SharePoint-Liste nicht an den
Server abgeben und warnt deshalb vor unvollständigen Ergebnissen ab dem
Datenzeilenlimit (Standard 500).

**Hier ist das unkritisch:** Gezählt werden die Behandlungen **eines**
Patienten. 500 Behandlungen bei einer Person wären ein sehr langes
Physio-Leben. Die Warnung darf stehen bleiben.
