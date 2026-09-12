# Spalten der einfachen Fassung

Diese Fassung kommt mit **16 Spalten** aus – alles andere bleibt unangetastet.

Diese Fassung kommt mit so wenigen Spalten wie moeglich aus. Bestaetigt ist bisher nur Patientenstamm: Die Patientenliste wurde im Tenant korrekt angezeigt.

> **Grenze:** Die Spalten von Rezepte und Behandlungsdokumentation sind nicht gegen die Listen geprueft. Fehlt eine, zeigt Power Apps Studio
> direkt nach dem Einfügen einen Formelfehler an der betroffenen Stelle.

## Legende

| Zeichen | Bedeutung |
|---|---|
| [S] | Systemspalte von SharePoint |
| [OK] | im Tenant nachweislich gelesen |
| [B] | im Auftrag ausdruecklich benannt |
| [?] | plausibel, aber nicht belegt |

## Patientenstamm

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [OK] | `Vorname` | `Vorname` | Text | Wird in der App korrekt angezeigt. |
| [OK] | `Nachname` | `Nachname` | Text | Wird in der App korrekt angezeigt. |
| [OK] | `Geburtsdatum` | `Geburtsdatum` | Datum | Wird in der App korrekt angezeigt. |

## Rezepte

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [?] | `PatientID` | `PatientID` | Zahl | Verbindet das Rezept mit dem Patienten ueber die SharePoint-ID. |
| [B] | `Diagnose laut Rezept` | `DiagnoselautRezept` | Text | Auftrag Befund 2. Anzeigename und interner Name weichen ab. |
| [?] | `Erstbefund` | `Erstbefund` | Mehrzeiliger Text | Wird als Befund angezeigt. |
| [?] | `Anamnese` | `Anamnese` | Mehrzeiliger Text | Wird als Anamnese angezeigt. |

## Behandlungsdokumentation

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [?] | `PatientID` | `PatientID` | Zahl | Traegt den gesamten Ablauf: Terminzaehlung, Verlauf und die Heute-Liste. |
| [?] | `RezeptID` | `RezeptID` | Zahl | Optional. Bleibt leer, wenn kein Rezept hinterlegt ist. |
| [?] | `Behandlungsdatum` | `Behandlungsdatum` | Datum | Die App filtert ueber einen Tageszeitraum, damit eine Uhrzeit nicht stoert. |
| [B] | `Therapeut` | `Therapeut` | Auswahl | Auftrag Befund 7: Auswahlfeld, KEIN Personenfeld. Die App liest die tatsaechlich hinterlegten Werte mit Choices(). |
| [?] | `Massnahmen` | `Massnahmen` | Mehrzeiliger Text | Durchgefuehrte Massnahmen. |
| [?] | `Reaktion` | `Reaktion` | Mehrzeiliger Text | Reaktion und Ergebnis. |
| [?] | `Heimuebungen` | `Heimuebungen` | Mehrzeiliger Text | Freiwillig. Bleibt leer, wenn nichts mitgegeben wurde. |

## Wenn eine Spalte fehlt

`04_Spalten_anlegen.ps1` legt die fehlenden an – es prüft zuerst und
ändert nichts Vorhandenes. Zuerst immer mit `-WhatIf` ausführen.

## Was diese Fassung bewusst nicht schreibt

Status, Freigabe, Terminstatus, Einheitenzähler und Aufgaben bleiben außen vor.
Sie behalten ihre SharePoint-Standardwerte. Das ist Absicht: Die App soll
zuerst im Alltag laufen, bevor Feinheiten dazukommen.