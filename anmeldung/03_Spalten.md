# Spalten der Anmelde-App

Diese App **erweitert `Patientenstamm` um fünf Kontaktspalten** und legt die
**neue Liste `Anmeldungen`** an. Die beiden anderen Apps sind davon nicht
betroffen – sie lesen aus `Patientenstamm` nur Vorname, Nachname und
Geburtsdatum, und die gibt es unverändert.

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
| [?] | `PatientID` | `PatientID` | Zahl | Verbindet die Anmeldung mit dem Patienten. |
| [?] | `Anmeldedatum` | `Anmeldedatum` | Datum | Das Datum, das der Patient auf dem Bildschirm gesehen hat. Entspricht dem 'Muenchen, ___' des Papierformulars. |
| [F] | `Versicherung` | `Versicherung` | Auswahl | Auswahlwerte: Privat versichert, Beihilfeberechtigt, Gesetzlich versichert, Selbstzahler. |
| [?] | `Vertragsstand` | `Vertragsstand` | Text | WICHTIG: Fassung der Honoraraufklaerung, der zugestimmt wurde. Ohne dieses Feld laesst sich bei einer Preisaenderung nicht mehr belegen, welche Saetze vereinbart waren. |
| [F] | `Honorar_Zugestimmt` | `Honorar_x005f_Zugestimmt` | Ja/Nein | Zustimmung zur Honoraraufklaerung. Ohne sie ist keine private Abrechnung vereinbart. |
| [F] | `Honorar_Name` | `Honorar_x005f_Name` | Text | Der vom Patienten getippte Name - tritt an die Stelle der Unterschrift auf dem Papier. |
| [F] | `DS_Zugestimmt` | `DS_x005f_Zugestimmt` | Ja/Nein | Einwilligung in die Datenverarbeitung einschliesslich der drei Hinweise (Widerruf, Auskunft, Berichtigung). |
| [F] | `DS_Name` | `DS_x005f_Name` | Text | Getippter Name zur Datenschutzerklaerung. |
| [F] | `DS_Rechnung_EMail` | `DS_x005f_Rechnung_x005f_EMail` | Ja/Nein | Freiwillig: Rechnungen per E-Mail. |
| [F] | `DS_Kontakt_EMail` | `DS_x005f_Kontakt_x005f_EMail` | Ja/Nein | Freiwillig: Kontaktaufnahme per E-Mail. |
| [F] | `DS_Kontakt_Telefon` | `DS_x005f_Kontakt_x005f_Telefon` | Ja/Nein | Freiwillig: Kontaktaufnahme per Telefon. |
| [F] | `DS_Kontakt_WhatsApp` | `DS_x005f_Kontakt_x005f_WhatsApp` | Ja/Nein | Freiwillig: Kontaktaufnahme per WhatsApp. |
| [F] | `DS_SocialMedia` | `DS_x005f_SocialMedia` | Auswahl | Freiwillig: anonymisierte Inhalte fuer Social Media und Website. Auswahlwerte: Einverstanden, Nicht einverstanden. |

## Zwei Spalten, die leicht falsch angelegt werden

**`PLZ` muss Text sein, nicht Zahl.** Sonst wird aus `04103 Leipzig` die
Zahl 4103, und die Rechnung geht an eine nicht existierende Postleitzahl.
Dasselbe gilt für `Telefon`: Vorwahlen mit führender Null, Klammern oder
Leerzeichen überleben kein Zahlenfeld.

**Die Unterstriche in den internen Namen.** SharePoint kodiert einen
Unterstrich im internen Namen als `_x005f_`. Der Anzeigename bleibt
`DS_Kontakt_EMail`, und genau den benutzt Power Fx. Der interne Name ist nur
für Power Automate wichtig. Wer die Spalten mit dem Skript anlegt, bekommt
beides automatisch richtig.

## Warum `Vertragsstand` kein Schmuck ist

Die Honorarsätze stehen dem Patienten auf dem Bildschirm und er stimmt ihnen
zu. Ändern sich die Preise, muss **nachweisbar bleiben, welcher Fassung er
zugestimmt hat**. Deshalb schreibt die App bei jeder Anmeldung die Fassung
mit, die gerade in `App.Formulas` unter `vertragsStand` steht.

Bei einer Preisänderung also **beides** ändern: die Tabelle `tblHonorar`
*und* das Datum in `vertragsStand`.

## Was diese App nicht schreibt

- Wer die Anmeldung entgegengenommen hat, steht automatisch in der Systemspalte `Erstellt von`. Am iPad ist das das angemeldete Praxiskonto, nicht der Patient.
- Der Zeitpunkt steht automatisch in `Erstellt` - genauer als Anmeldedatum, das nur den Tag haelt.
- Keine gezeichnete Unterschrift: Das Steuerelement PenInput steht in der offiziellen Typenliste von Power Apps nicht zur Verfuegung. Statt dessen der getippte Name plus Zeitstempel plus die einzeln erfassten Antworten.

## Anlegen

`04_Spalten_anlegen.ps1` legt die fehlenden Spalten **und die Liste**
`Anmeldungen` an – es prüft zuerst und ändert nichts Vorhandenes. Zuerst
immer mit `-WhatIf` ausführen.
