# Spalten der Erstaufnahme-App

Diese App schreibt in die Felder, aus denen die Behandlungs-App den Befund
bereits liest - deshalb erscheint eine Aufnahme dort ohne jede Änderung an
der anderen App. Dazu kommt seit neuem das Rezeptbild.

> **Die Datenquelle heißt in dieser App `Rezepte`, in der Behandlungs-App
> `Rezept`.** Der Name innerhalb einer App ist nur ein lokaler Alias -
> entscheidend ist, dass beide auf **dieselbe SharePoint-Liste** zeigen.

> **Grenze:** Die Spalten der Liste Rezept sind nicht gegen die Liste selbst geprueft. Fehlt eine, zeigt Studio direkt nach dem Einfuegen einen Formelfehler an der betroffenen Stelle.

## Legende

| Zeichen | Bedeutung |
|---|---|
| [S] | Systemspalte von SharePoint |
| [OK] | im Tenant nachweislich gelesen |
| [B] | im Auftrag ausdruecklich benannt |
| [?] | plausibel, aber nicht belegt |

## Patientenstamm (nur lesen)

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [OK] | `Vorname` | `Vorname` | Text | Suche und Anzeige. Wird in der Behandlungs-App korrekt angezeigt. |
| [OK] | `Nachname` | `Nachname` | Text | Suche und Anzeige. |
| [OK] | `Geburtsdatum` | `Geburtsdatum` | Datum | Unterscheidet gleiche Namen. |

## Rezepte (lesen und schreiben)

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Die Behandlungs-App sortiert danach absteigend und nimmt das juengste Rezept. |
| [?] | `PatientID` | `PatientID` | Zahl | Verbindet das Rezept mit dem Patienten. OHNE diese Spalte findet die Behandlungs-App den Befund nicht. |
| [B] | `Diagnose laut Rezept` | `DiagnoselautRezept` | Text | Anzeigename und interner Name weichen ab. Power Fx nutzt den Anzeigenamen in einfachen Anfuehrungszeichen. |
| [?] | `Erstbefund` | `Erstbefund` | Mehrzeiliger Text | Wird in der Behandlungs-App unter Befund und Anamnese angezeigt. |
| [?] | `Anamnese` | `Anamnese` | Mehrzeiliger Text | Wird in der Behandlungs-App unter Befund und Anamnese angezeigt. |
| [B] | `RezeptBild` | `RezeptBild` | Bild | Das abfotografierte Rezept. SharePoint-Spaltentyp 'Bild' - die Datei landet in SiteAssets, die Spalte haelt nur den Verweis. In der App wird sie in einem EIGENEN Schreibvorgang nach der Aufnahme gefuellt. |

## Das Rezeptbild wird getrennt geschrieben

Befund und Anamnese gehen in einem `Patch`, das Bild in einem **zweiten**:

```powerfx
Set(gblAufnahme; Patch(Rezepte; Defaults(Rezepte); { Erstbefund: ...; ... }));;
// erst danach, und nur wenn ein Foto da ist:
IfError(
    Patch(Rezepte; gblAufnahme; { RezeptBild: gblFoto });
    Set(gblFotoFehler; FirstError.Message)
)
```

**Warum nicht in einem Zug?** Das Schreiben in eine SharePoint-Bild-Spalte aus
einer Canvas-App ist die einzige Stelle dieser App, die ich nicht belegen kann.
Stünde das Bild im selben `Patch`, würde ein Fehler daran den **ganzen**
Schreibvorgang kippen - der Therapeut hätte Befund und Anamnese getippt und
alles wäre weg.

Getrennt gilt: Die Aufnahme ist gespeichert, komme was wolle. Klappt das Bild
nicht, sagt die Meldung das ausdrücklich und nennt die Zeilennummer zum
Nachtragen.

## Was diese App nicht schreibt

- Wer die Aufnahme gemacht hat, steht automatisch in der Systemspalte `Erstellt von`. Dafuer ist keine eigene Spalte noetig.
- Das Aufnahmedatum steht automatisch in `Erstellt`.
- Status, Freigabe, Terminstatus und Einheitenzaehler bleiben unangetastet.
- Anlagen: Diese App haengt keine Dateien mehr an. Der Vertrag und die Datenschutzerklaerung werden in der Anmelde-App digital erfasst.

## Wenn eine Spalte fehlt

`04_Spalten_anlegen.ps1` legt die fehlenden an - es prüft zuerst und ändert
nichts Vorhandenes. Zuerst immer mit `-WhatIf` ausführen.

**`RezeptBild` legt das Skript nicht an.** Bild-Spalten lassen sich mit
`Add-PnPField` nicht zuverlässig erzeugen; sie ist in SharePoint von Hand
angelegt: Spalte hinzufügen → Typ **Bild** → Name `RezeptBild`.
