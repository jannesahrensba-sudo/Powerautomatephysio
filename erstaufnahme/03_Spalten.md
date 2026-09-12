# Spalten der Erstaufnahme-App

Diese App legt **keine neue Spalte** an. Sie schreibt genau die Felder, aus
denen die Behandlungs-App den Befund bereits liest – deshalb erscheint eine
Aufnahme dort ohne jede Änderung an der anderen App.

> **Die Datenquelle heißt in dieser App `Rezepte`, in der Behandlungs-App
> `Rezept`.** Der Name innerhalb einer App ist nur ein lokaler Alias –
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

## Was diese App nicht schreibt

- Wer die Aufnahme gemacht hat, steht automatisch in der Systemspalte `Erstellt von`. Dafuer ist keine eigene Spalte noetig.
- Das Aufnahmedatum steht automatisch in `Erstellt`.
- Status, Freigabe, Terminstatus und Einheitenzaehler bleiben unangetastet.
- Anlagen: Diese App haengt keine Dateien mehr an. Der Vertrag und die Datenschutzerklaerung werden in der Anmelde-App digital erfasst.

## Wenn eine Spalte fehlt

`04_Spalten_anlegen.ps1` legt die fehlenden an – es prüft zuerst und ändert
nichts Vorhandenes. Zuerst immer mit `-WhatIf` ausführen.
