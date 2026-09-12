# Betroffene Formeln, Steuerelement für Steuerelement (EN)

Trennzeichen dieser Datei: Argumente mit `,`, mehrere Anweisungen mit `;`. Die andere Fassung liegt daneben.

> **Aus dem Oberflächencode erzeugt, nicht abgetippt.** Diese Liste
> kann deshalb nicht vom Code abweichen.

## Wozu diese Liste gut ist – und wozu nicht

Jede Formel hier spricht mindestens eine Spalte an, die Power Apps
Studio rot unterringelt.

**Solange die Spalte in SharePoint fehlt, hilft kein Umschreiben der
Formel.** Legen Sie zuerst die Spalten an – die Markierungen
verschwinden dann von selbst, ohne dass Sie eine Zeile anfassen.

Diese Liste brauchen Sie nur, wenn eine Spalte bei Ihnen **anders**
**heißt**. Dann tauschen Sie den Namen in der jeweiligen Formel aus
und fügen sie in die genannte Eigenschaft ein.

Betroffen: **12 Formeln** in **12 Steuerelementen**.

| Steuerelement | Eigenschaft | Spalten |
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
| `btnDokuSpeichern` | `OnSelect` | `Behandlungsdatum`, `Heimuebungen`, `Massnahmen`, `PatientID`, `Reaktion`, `Therapeut` |

---

## `galHeute` · Eigenschaft `Items`

Control `Gallery`, verwendet `Behandlungsdatum`

```powerfx
=Sort(
    Filter(
        Behandlungsdokumentation,
        Behandlungsdatum >= Today(),
        Behandlungsdatum < DateAdd(Today(), 1, TimeUnit.Days)
    ),
    ID,
    SortOrder.Descending
)
```

## `lblHeuteName` · Eigenschaft `Text`

Control `Label`, verwendet `PatientID`

```powerfx
=With(
    { p: LookUp(Patientenstamm, ID = ThisItem.PatientID) },
    If(IsBlank(p),
       "Patient nicht auffindbar",
       Trim(Coalesce(p.Vorname, "") & " " & Coalesce(p.Nachname, "")))
)
```

## `lblHeuteZeile2` · Eigenschaft `Text`

Control `Label`, verwendet `Massnahmen`, `Therapeut`

```powerfx
=Coalesce(ThisItem.Therapeut.Value, "Therapeut offen") & "   ·   " &
 Left(Coalesce(ThisItem.Massnahmen, "keine Maßnahmen erfasst"), 120)
```

## `btnPatWaehlen` · Eigenschaft `OnSelect`

Control `Classic/Button`, verwendet `PatientID`

```powerfx
=Set(gblPatient, ThisItem);
// Jüngstes Rezept des Patienten - ohne eigene Auswahl.
Set(
    gblRezept,
    First(Sort(Filter(Rezepte, PatientID = ThisItem.ID), ID, SortOrder.Descending))
);
Set(gblTherapeut, "");
Set(gblReset, true); Set(gblReset, false);
Set(gblMeldung, ""); Set(gblMeldungArt, "");
Set(gblSchritt, "Akte")
```

## `lblTerminZahl` · Eigenschaft `Text`

Control `Label`, verwendet `PatientID`

```powerfx
=Text(CountRows(Filter(Behandlungsdokumentation, PatientID = gblPatient.ID)) + 1) & "."
```

## `lblTerminUnter` · Eigenschaft `Text`

Control `Label`, verwendet `PatientID`

```powerfx
=With(
    { n: CountRows(Filter(Behandlungsdokumentation, PatientID = gblPatient.ID)) },
    If(n = 0,
       "Erste dokumentierte Behandlung für diesen Patienten.",
       "Bisher " & n & " Behandlung(en) dokumentiert.")
)
```

## `lblBefundText` · Eigenschaft `Text`

Control `Label`, verwendet `Anamnese`, `Diagnose laut Rezept`, `Erstbefund`

```powerfx
=If(
    IsBlank(gblRezept),
    "Zu diesem Patienten ist kein Rezept hinterlegt. Befund und Anamnese können deshalb nicht angezeigt werden.",
    "Diagnose" & Char(10) &
    Coalesce(gblRezept.'Diagnose laut Rezept', "nicht hinterlegt") & Char(10) & Char(10) &
    "Erstbefund" & Char(10) &
    Coalesce(gblRezept.Erstbefund, "nicht hinterlegt") & Char(10) & Char(10) &
    "Anamnese" & Char(10) &
    Coalesce(gblRezept.Anamnese, "nicht hinterlegt")
)
```

## `drpTherapeut` · Eigenschaft `Items`

Control `Classic/DropDown`, verwendet `Therapeut`

```powerfx
=Choices(Behandlungsdokumentation.Therapeut)
```

## `galVerlauf` · Eigenschaft `Items`

Control `Gallery`, verwendet `PatientID`

```powerfx
=Sort(
    Filter(Behandlungsdokumentation, PatientID = gblPatient.ID),
    ID,
    SortOrder.Descending
)
```

## `lblVerlaufKopf` · Eigenschaft `Text`

Control `Label`, verwendet `Behandlungsdatum`, `Therapeut`

```powerfx
=If(IsBlank(ThisItem.Behandlungsdatum), "ohne Datum",
    Text(ThisItem.Behandlungsdatum, DateTimeFormat.ShortDate)) &
 "   ·   " & Coalesce(ThisItem.Therapeut.Value, "Therapeut offen")
```

## `lblVerlaufText` · Eigenschaft `Text`

Control `Label`, verwendet `Heimuebungen`, `Massnahmen`, `Reaktion`

```powerfx
="Maßnahmen: " & Coalesce(ThisItem.Massnahmen, "nicht erfasst") & Char(10) &
 "Reaktion: " & Coalesce(ThisItem.Reaktion, "nicht erfasst") &
 If(IsBlank(ThisItem.Heimuebungen), "",
    Char(10) & "Heimübungen: " & ThisItem.Heimuebungen)
```

## `btnDokuSpeichern` · Eigenschaft `OnSelect`

Control `Classic/Button`, verwendet `Behandlungsdatum`, `Heimuebungen`, `Massnahmen`, `PatientID`, `Reaktion`, `Therapeut`

```powerfx
=Set(gblPruefen, true);
If(
    IsBlank(Trim(txtMassnahmen.Text)) Or IsBlank(Trim(txtReaktion.Text)),
    Set(gblMeldung, "Bitte Maßnahmen und Reaktion ausfüllen.");
    Set(gblMeldungArt, "Warnung"),

    Set(gblSpeichert, true);
    Set(gblFehlerText, "");
    // Nur der Schreibvorgang wird abgesichert,
    // nicht die ganze Befehlskette.
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
    // Geprüft wird das Ergebnis, nicht der Kettenabschluss.
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
