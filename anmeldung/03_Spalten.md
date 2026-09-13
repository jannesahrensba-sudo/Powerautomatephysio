# Spalten der Anmelde-App

Diese App **erweitert `Patientenstamm` um fuenf Kontaktspalten** und legt die
**neue Liste `Anmeldungen`** an. Die beiden anderen Apps sind davon nicht
betroffen - sie lesen aus `Patientenstamm` nur Vorname, Nachname und
Geburtsdatum, und die gibt es unveraendert.

> **Grenze:** Keine der Spalten ist gegen den Tenant geprueft. Patientenstamm existiert und wird gelesen; die Zusatzspalten und die Liste Anmeldungen sind neu.

## Legende

| Zeichen | Bedeutung |
|---|---|
| [S] | Systemspalte von SharePoint |
| [OK] | im Tenant nachweislich gelesen |
| [F] | aus dem Papierformular der Praxis uebernommen |
| [?] | plausibel, aber nicht belegt |

## Patientenstamm (bestehend, wird erweitert)

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [OK] | `Vorname` | `Vorname` | Text | Wird von allen drei Apps genutzt. |
| [OK] | `Nachname` | `Nachname` | Text | Wird von allen drei Apps genutzt. |
| [OK] | `Geburtsdatum` | `Geburtsdatum` | Datum | Unterscheidet gleiche Namen. Dient hier auch der Dublettenpruefung. |
| [F] | `Telefon` | `Telefon` | Text | Steht auf der Honoraraufklaerung. Text, nicht Zahl - fuehrende Nullen und Vorwahlen mit Klammern. |
| [F] | `EMail` | `EMail` | Text | Steht auf der Honoraraufklaerung. Ziel fuer den Rechnungsversand, sofern eingewilligt. |
| [F] | `Strasse` | `Strasse` | Text | Adressfeld der Honoraraufklaerung, aufgeteilt fuer die Abrechnung. |
| [F] | `PLZ` | `PLZ` | Text | TEXT, nicht Zahl - sonst verschwindet die fuehrende Null bei Orten wie 04103 Leipzig. |
| [F] | `Ort` | `Ort` | Text | Adressfeld der Honoraraufklaerung. |

## Anmeldungen (neue Liste)

| | Anzeigename | Interner Name | Typ | Bedeutung |
|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schluessel. |
| [?] | `PatientID` | `PatientID` | Zahl | Verbindet die Anmeldung mit dem Patienten. MUSS eine ZAHL sein, keine Nachschlagespalte: die beiden anderen Apps fuehren PatientID in Rezepte und Behandlungsdokumentation ebenfalls als Zahl. Eine Nachschlagespalte verlangt beim Patch einen Datensatz statt einer Zahl und meldet 'erwartet wird ein Record'. |
| [?] | `Anmeldedatum` | `Anmeldedatum` | Datum | Das Datum, das der Patient auf dem Bildschirm gesehen hat. Entspricht dem 'Muenchen, ___' des Papierformulars. |
| [F] | `Versicherung` | `Versicherung` | Auswahl | Auswahlwerte: Privat versichert, Beihilfeberechtigt, Gesetzlich versichert, Selbstzahler. |
| [?] | `Vertragsstand` | `Vertragsstand` | Text | WICHTIG: Fassung der Honoraraufklaerung, der zugestimmt wurde. Ohne dieses Feld laesst sich bei einer Preisaenderung nicht mehr belegen, welche Saetze vereinbart waren. |
| [F] | `Honorar_Zugestimmt` | `Honorar_x005f_Zugestimmt` | Ja/Nein | Zustimmung zur Honoraraufklaerung. Ohne sie ist keine private Abrechnung vereinbart. |
| [F] | `Honorar_Name` | `Honorar_x005f_Name` | Text | Der vom Patienten getippte Name - tritt an die Stelle der Unterschrift auf dem Papier. |
| [F] | `DS_Zugestimmt` | `DS_x005f_Zugestimmt` | Ja/Nein | Einwilligung in die Datenverarbeitung einschliesslich der drei Hinweise (Widerruf, Auskunft, Berichtigung). |
| [F] | `DS_Name` | `DS_x005f_Name` | Text | Getippter Name zur Datenschutzerklaerung. |
| [F] | `DS_Rechnung_Email` | `DS_x005f_Rechnung_x005f_Email` | Ja/Nein | Freiwillig: Rechnungen per E-Mail. |
| [F] | `DS_Kontakt_EMail` | `DS_x005f_Kontakt_x005f_EMail` | Ja/Nein | Freiwillig: Kontaktaufnahme per E-Mail. |
| [F] | `DS_Kontakt_Telefon` | `DS_x005f_Kontakt_x005f_Telefon` | Ja/Nein | Freiwillig: Kontaktaufnahme per Telefon. |
| [F] | `DS_Kontakt_Whattsapp` | `DS_x005f_Kontakt_x005f_Whattsapp` | Ja/Nein | Freiwillig: Kontaktaufnahme per WhatsApp. Schreibweise wie in der Liste angelegt (doppeltes t, kleines a) - Power Fx muss sie exakt so treffen. |
| [F] | `DS_SocialMedia` | `DS_x005f_SocialMedia` | Ja/Nein | Freiwillig: anonymisierte Inhalte fuer Social Media und Website. Ja/Nein-Spalte - Ja entspricht 'Einverstanden'. |

## Drei Spalten, die leicht falsch angelegt werden

**`PatientID` muss eine Zahl sein, keine Nachschlagespalte.** Eine
Nachschlagespalte verlangt beim Schreiben einen ganzen Datensatz statt einer
Zahl; Power Apps meldet dann sinngemaess, das Feld `PatientID` erwarte einen
Record. Die beiden anderen Apps fuehren `PatientID` ebenfalls als Zahl -
bleiben Sie dabei, sonst passen die drei Listen nicht mehr zusammen.

**`PLZ` muss Text sein, nicht Zahl.** Sonst wird aus `04103 Leipzig` die Zahl
4103. Dasselbe gilt fuer `Telefon`: Vorwahlen mit fuehrender Null, Klammern
oder Leerzeichen ueberleben kein Zahlenfeld.

**Die Unterstriche in den internen Namen.** SharePoint kodiert einen
Unterstrich als `_x005f_`. Der Anzeigename bleibt `DS_Kontakt_Telefon`, und
genau den benutzt Power Fx. Der interne Name zaehlt nur fuer Power Automate.

## Zwei Schreibweisen, die abweichen

In der angelegten Liste heissen zwei Spalten anders als urspruenglich geplant:
`DS_Rechnung_Email` (kleines m) und `DS_Kontakt_Whattsapp` (doppeltes t). Der
Code trifft sie exakt so. Wenn Sie die Anzeigenamen in SharePoint aufraeumen
wollen, geht das jederzeit - dann aber **beide Stellen** aendern, SharePoint
und die Formel in `btnAbschliessen`.

## Warum `Vertragsstand` kein Schmuck ist

Die Honorarsaetze stehen dem Patienten auf dem Bildschirm und er stimmt ihnen
zu. Aendern sich die Preise, muss **nachweisbar bleiben, welcher Fassung er
zugestimmt hat**. Deshalb schreibt die App bei jeder Anmeldung die Fassung mit,
die gerade in `App.Formulas` unter `vertragsStand` steht.

Bei einer Preisaenderung also **beides** aendern: die Tabelle `tblHonorar`
*und* das Datum in `vertragsStand`.

## Was diese App nicht schreibt

- Wer die Anmeldung entgegengenommen hat, steht automatisch in der Systemspalte `Erstellt von`. Am iPad ist das das angemeldete Praxiskonto, nicht der Patient.
- Der Zeitpunkt steht automatisch in `Erstellt` - genauer als Anmeldedatum, das nur den Tag haelt.
- Keine gezeichnete Unterschrift: Das Steuerelement PenInput steht in der offiziellen Typenliste von Power Apps nicht zur Verfuegung. Statt dessen der getippte Name plus Zeitstempel plus die einzeln erfassten Antworten.

## Anlegen

`04_Spalten_anlegen.ps1` legt die fehlenden Spalten **und die Liste**
`Anmeldungen` an - es prueft zuerst und aendert nichts Vorhandenes. Zuerst
immer mit `-WhatIf` ausfuehren.

**Eine bereits als Nachschlagespalte angelegte `PatientID` repariert das
Skript nicht** - SharePoint kann den Typ nicht umstellen. Spalte loeschen
und als Zahl neu anlegen; bei einer noch leeren Liste kostet das nichts.
