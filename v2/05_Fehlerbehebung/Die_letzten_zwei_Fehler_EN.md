# Die letzten zwei Fehler

Beide haben **dieselbe Ursache**: In der Liste `Rezepte` fehlt die Spalte
`PatientID`.

## Warum aus einer Ursache zwei Meldungen werden

Im ganzen Oberflächencode gibt es **genau eine** Stelle, die die Liste
`Rezepte` anspricht – in `btnPatWaehlen`:

```powerfx
Set(
    gblRezept,
    First(Sort(Filter(Rezepte, PatientID = ThisItem.ID), ID, SortOrder.Descending))
)
```

Von dieser Zeile bekommt die Variable `gblRezept` ihren Typ. Schlägt der
Filter fehl, weiß Power Apps nicht mehr, was `gblRezept` ist – und meldet
deshalb auch an der zweiten Stelle einen Fehler:

```powerfx
RezeptID: If(IsBlank(gblRezept), Blank(), gblRezept.ID)
```

Der zweite Fehler ist also eine **Folge** des ersten. Sie müssen ihn nicht
gesondert behandeln: Ist der erste weg, verschwindet der zweite mit.

---

## Weg 1 – empfohlen: die Spalte anlegen (2 Minuten)

Liste **Rezepte** öffnen → **+ Spalte hinzufügen** → **Zahl** → Name genau
`PatientID` → **Speichern**.

Bei der Gelegenheit prüfen, ob es dort auch `Erstbefund` und `Anamnese` gibt
(jeweils **Mehrere Textzeilen**). Die braucht die Befundkarte.

Danach in Power Apps Studio: **Daten → `Rezepte` → Aktualisieren**.

> Ohne das Aktualisieren kennt Studio weiter das alte Schema, und beide
> Meldungen bleiben stehen, obwohl die Spalte da ist.

**Damit die Befundkarte auch etwas anzeigt,** muss bei mindestens einem
Rezept `PatientID` befüllt sein – also die SharePoint-ID des Patienten
eintragen. Die sehen Sie in der Patientenliste in der Spalte `ID` (falls sie
ausgeblendet ist: Ansicht bearbeiten und `ID` einblenden).

---

## Weg 2 – falls Sie erst einmal ohne Rezepte starten wollen

Dann entfällt die Befundkarte. Die App funktioniert vollständig, nur ohne
Befund und Anamnese – Terminzählung, Verlauf, Dokumentation und die
Heute-Liste bleiben unberührt.

Ersetzen Sie dafür **drei Formeln**. Sie finden das Steuerelement jeweils über
die Suche in der Strukturansicht links.

**Schneller geht es mit der fertigen Fassung:** Statt drei Formeln einzeln zu
tauschen, können Sie die Steuerelemente löschen und
**[`AppShell_ohne_Rezepte.yaml`](AppShell_ohne_Rezepte.yaml)** einfügen. Die
ist inhaltsgleich, nur ohne jeden Zugriff auf `Rezepte`, und gegen dieselben
Prüfungen gelaufen wie das Original.

> Rezepte lassen sich jederzeit nachrüsten: Sie nehmen dann einfach wieder
> `01_AppShell_einfuegen.yaml`. Die gespeicherten Behandlungen bleiben dabei
> vollständig erhalten – die Notweg-Fassung schreibt in dieselben Spalten,
> nur ohne `RezeptID`.

Wenn Sie lieber einzeln tauschen, hier die drei Formeln:


Diese Datei verwendet **invariante/englische Trennzeichen** (`,` und `;`). Die andere Fassung liegt daneben.

### `btnPatWaehlen` – Eigenschaft `OnSelect`

```powerfx
=Set(gblPatient, ThisItem);
Set(gblTherapeut, "");
Set(gblReset, true); Set(gblReset, false);
Set(gblMeldung, ""); Set(gblMeldungArt, "");
Set(gblSchritt, "Akte")
```

### `lblBefundText` – Eigenschaft `Text`

```powerfx
="Befund und Anamnese erscheinen hier, sobald zum Patienten ein Rezept hinterlegt ist."
```

### `btnDokuSpeichern` – Eigenschaft `OnSelect`

```powerfx
=Set(gblPruefen, true);
If(
    IsBlank(Trim(txtMassnahmen.Text)) Or IsBlank(Trim(txtReaktion.Text)),
    Set(gblMeldung, "Bitte Maßnahmen und Reaktion ausfüllen.");
    Set(gblMeldungArt, "Warnung"),

    Set(gblSpeichert, true);
    Set(gblFehlerText, "");
    Set(
        gblErgebnis,
        IfError(
            Patch(
                Behandlungsdokumentation,
                Defaults(Behandlungsdokumentation),
                {
                    PatientID: gblPatient.ID,
                    Behandlungsdatum: Today(),
                    Therapeut: { Value: gblTherapeut },
                    Massnahmen: Trim(txtMassnahmen.Text),
                    Reaktion: Trim(txtReaktion.Text),
                    Heimuebungen: Trim(txtHeim.Text)
                }
            ),
            Set(gblFehlerText, FirstError.Message); Blank()
        )
    );
    If(
        IsBlank(gblErgebnis) Or IsBlank(gblErgebnis.ID),
        Set(gblMeldung, "Speichern fehlgeschlagen. Ihre Eingaben bleiben stehen. " & gblFehlerText);
        Set(gblMeldungArt, "Fehler"),

        Set(gblPruefen, false);
        Set(gblReset, true); Set(gblReset, false);
        Set(gblMeldung,
            "Gespeichert für " &
            Trim(Coalesce(gblPatient.Vorname, "") & " " & Coalesce(gblPatient.Nachname, "")) & ".");
        Set(gblMeldungArt, "Erfolg");
        Set(gblSchritt, "Heute")
    );
    Set(gblSpeichert, false)
)
```

---

## Danach prüfen

| Prüfung | Erwartet |
|---|---|
| App-Prüfung | keine Fehler mehr |
| Patient auswählen | Vorbereitung öffnet sich, Terminnummer steht da |
| Behandlung speichern | grüne Meldung, Eintrag in „Heute" |
| Patient erneut aufrufen | Terminnummer eins höher, Eintrag im Verlauf |
