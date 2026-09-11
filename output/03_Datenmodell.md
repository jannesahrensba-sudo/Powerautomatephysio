# Datenmodell und Feldzuordnung

## Quellenlage - bitte zuerst lesen

Das Verzeichnis referenzen/ mit den Dateien 01 bis 12 war in diesem Arbeitsstand NICHT vorhanden - das Repository war leer. Es lag ausschliesslich die Auftragsbeschreibung vor.

Alles, was unten mit **[B]** markiert ist, stammt aus Abschnitt 5 der Auftragsbeschreibung (Befunde 1 bis 10).

> **Grenze dieser Zuordnung:** Kein Zugriff auf den Tenant, keine Live-Metadaten, keine Schemaexporte. 'bestaetigt_auftrag' heißt: im Auftragstext benannt - NICHT: gegen die Liste geprüft.

Bevor die App produktiv genutzt wird, ist `04_Setup/Pruefe-Schema.ps1` auszufuehren. Das Skript liest die tatsächlichen Anzeigenamen, internen Namen und Typen aus und erzeugt einen Abgleichbericht gegen diese Datei.

## Legende

| Zeichen | Bedeutung |
|---|---|
| [S] | Systemspalte von SharePoint |
| [B] | im Auftrag ausdruecklich benannt |
| [?] | plausibel, aber nicht belegt |
| [!] | ausdruecklich ungeklaert |
| [+] | muss ergänzt werden |

## Anzeigename gegen internen Namen - die häufigste Fehlerquelle

- Power Fx spricht SharePoint-Spalten über den ANZEIGENAMEN an.
- Power Automate spricht dieselben Spalten über den INTERNEN Namen an.

Bei diesen Feldern weichen beide Namen voneinander ab:

| Liste | Anzeigename (Power Fx) | Interner Name (Power Automate) |
|---|---|---|
| Rezepte | `Diagnose laut Rezept` | `DiagnoselautRezept` |
| Behandlungsdokumentation | `AltEinheiten` | `Einheiten` |
| AufgabenEinstellungen | `VersandAktiv` | `VerandAktiv` |
| Behandlungsdokumentation | `Freigegeben am` | `Freigegebenam` |
| Behandlungsdokumentation | `Freigegeben von` | `Freigegebenvon` |
| Patientenstamm | `Patienten ID` | `PatientenID` |

> Die internen Namen in dieser Tabelle sind aus dem Auftragstext abgeleitet beziehungsweise die uebliche SharePoint-Ableitung (Leerzeichen entfallen). Vor dem Bau der Flows mit dem Bestandsskript prüfen - ein falscher interner Name lässt den Flow zur Laufzeit fehlschlagen.

## Beziehungen

Technische Beziehungen laufen über die SharePoint-Spalte ID, nicht über Namen und nicht über die fachliche 'Patienten ID' (Auftrag Befund 10).

**Umsetzung in der App:** Die App schreibt Zahlenspalten PatientID und RezeptID. Grund: Typ und Ziel der vorhandenen Spalten 'Patient' und 'Rezept' sind nicht belegt (Befund 6). Ein Schreibzugriff auf eine Spalte unbekannten Typs wäre geraten.

**Alternative:** Ergibt die Bestandspruefung ein echtes Lookup-Feld mit Einfachauswahl, kann statt PatientID geschrieben werden: Patient: { Id: gblPatient.ID, Value: gblPatient.Nachname }. Erst nach Bestaetigung umstellen.

## Feldmatrix

### Patientenstamm

| | Anzeigename | Interner Name | Typ | Befund | Erforderliche Änderung |
|---|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schlüssel von SharePoint. Alle Beziehungen laufen hierueber. | keine |
| [?] | `Vorname` | `Vorname` | Text | Wird im Auftrag als Suchfeld genannt, der Anzeigename ist aber nirgends belegt. | Anzeigenamen mit dem Bestandsskript prüfen. |
| [?] | `Nachname` | `Nachname` | Text | Wie Vorname. | Anzeigenamen mit dem Bestandsskript prüfen. |
| [?] | `Geburtsdatum` | `Geburtsdatum` | Datum | Im Auftrag als Unterscheidungsmerkmal bei gleichen Namen genannt. | Anzeigenamen und Uhrzeitanteil prüfen. |
| [B] | `Patienten ID` | `PatientenID` | Text | Auftrag Befund 10: fachliche Patientennummer, ausdruecklich NICHT der technische Schlüssel. | Nicht für Beziehungen verwenden. |

### Rezepte

| | Anzeigename | Interner Name | Typ | Befund | Erforderliche Änderung |
|---|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schlüssel. Ziel aller Verweise aus der Dokumentation. | keine |
| [B] | `Behandlungseinheiten` | `Behandlungseinheiten` | Zahl | Auftrag Befund 2: So heißt die verordnete Rezeptmenge. | Kein zweites Feld EinheitenSoll anlegen. |
| [B] | `Diagnose laut Rezept` | `DiagnoselautRezept` | Text | Auftrag Befund 2. Anzeigename und interner Name weichen voneinander ab. | Kein zweites Feld Diagnose anlegen. In Flows den internen Namen verwenden. |
| [!] | `Title / Titel / Rezeptname` | `Title` | Text | Auftrag Befund 5: Im Feld-XML steht Title/Titel, in der Übersicht Rezeptname. Der tatsächliche Anzeigename ist nicht belegt. | OFFEN. Die App liest dieses Feld bewusst NICHT und bildet die Rezeptbezeichnung aus ID und Diagnose. Erst nach einem Metadatenabzug entscheiden. |
| [!] | `Patient` | `Patient` | unbekannt (Ziel: unbekannt) | Auftrag Befund 6: Erscheint nur in Spaltenuebersichten. Einzel- oder Mehrfachauswahl, Ziel-Liste und Lookup-Ziel-ID sind nicht belegt. | OFFEN. Vor einem Schreibzugriff mit dem Bestandsskript klaeren. Die App schreibt stattdessen PatientID. |
| [+] | `PatientID` | `PatientID` | Zahl | Die App verbindet Rezept und Patient über die technische SharePoint-ID (Befund 10). Eine Zahlenspalte ist eindeutig schreibbar, ohne den Typ von Patient zu kennen. | ANLEGEN (Zahl). Alternative mit echtem Lookup siehe Abschnitt Beziehungen. |
| [+] | `Rezeptstatus` | `Rezeptstatus` | Auswahl | Der Auftrag verlangt aktive, pausierte, abgeschlossene und abgebrochene Rezepte. | ANLEGEN (Auswahl: Entwurf, Aktiv, Pausiert, Abgeschlossen, Abgebrochen). |
| [?] | `Verordner` | `Verordner` | Text | Im Auftrag als vorhandenes Rezeptdatum genannt, Anzeigename nicht belegt. | Anzeigenamen prüfen. |
| [?] | `Frequenz` | `Frequenz` | Text | Wie Verordner. | Anzeigenamen prüfen. |
| [?] | `Beschwerden` | `Beschwerden` | Mehrzeiliger Text | Wie Verordner. | Anzeigenamen prüfen. |
| [?] | `Anamnese` | `Anamnese` | Mehrzeiliger Text | Wie Verordner. | Anzeigenamen prüfen. |
| [?] | `Erstbefund` | `Erstbefund` | Mehrzeiliger Text | Dient zugleich als Aufnahmebefund. Es wird keine zweite Kopie gepflegt. | Anzeigenamen prüfen. |
| [?] | `Therapieziele` | `Therapieziele` | Mehrzeiliger Text | Wie Verordner. | Anzeigenamen prüfen. |
| [+] | `AltEinheiten` | `AltEinheiten` | Zahl | Bereits außerhalb der App erbrachte Einheiten DIESES Rezepts. Auftrag Abschnitt 6. Nicht zu verwechseln mit der gleichnamigen Doku-Spalte (Befund 3). | ANLEGEN (Zahl, Standard 0). |
| [+] | `EinheitenApp` | `EinheitenApp` | Zahl | Auftrag Befund 4: Liegt teilweise in der Dokumentation. Gemeinsame Zähler gehören an das Rezept. | ANLEGEN (Zahl). Bestandswerte nicht blind verschieben - Umzugsschritt siehe unten. |
| [+] | `Erbracht` | `Erbracht` | Zahl | Wie EinheitenApp. | ANLEGEN (Zahl). |
| [+] | `Offen` | `Offen` | Zahl | Wie EinheitenApp. | ANLEGEN (Zahl). |
| [+] | `LetzterAppTermin` | `LetzterAppTermin` | Datum und Uhrzeit | Wie EinheitenApp. | ANLEGEN (Datum und Uhrzeit). |
| [+] | `InaktivTage` | `InaktivTage` | Zahl | Wie EinheitenApp. | ANLEGEN (Zahl). |
| [+] | `ZaehlerStand` | `ZaehlerStand` | Datum und Uhrzeit | Zeitpunkt der letzten Zaehlerberechnung. Ist das Feld leer, zeigt die App ausdruecklich 'noch nicht berechnet' statt '0 offen'. | ANLEGEN (Datum und Uhrzeit). Ohne dieses Feld ist der Zaehlerstand nicht bewertbar. |
| [+] | `ZaehlerLauf` | `ZaehlerLauf` | Text | Kennung des gerade laufenden Zaehlerdurchgangs. Verhindert, dass zwei gleichzeitige Flow-Laeufe sich gegenseitig überschreiben. | ANLEGEN (Text). |

### Behandlungsdokumentation

| | Anzeigename | Interner Name | Typ | Befund | Erforderliche Änderung |
|---|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schlüssel. | keine |
| [B] | `AltEinheiten` | `Einheiten` | Zahl (Standard 1) | Auftrag Befund 3: Anzeigename AltEinheiten, interner Name Einheiten, Standard 1. Der Standardwert 1 spricht dafür, dass fachlich die Behandlungsmenge EINER Zeile gemeint ist - der Anzeigename legt dagegen einen Rezeptaltbestand nahe. | VORSCHLAG (bestaetigungspflichtig): Anzeigename zu 'Behandlungsmenge' korrigieren. Der Rezeptaltbestand bekommt eine eigene Spalte am Rezept. Vorher Bestandsdaten prüfen - Skript in 04_Setup. Bis zur Korrektur schreibt die App auf den Anzeigenamen AltEinheiten. |
| [B] | `Therapeut` | `Therapeut` | Auswahl | Auftrag Befund 7: Auswahlfeld, derzeit Wert 'Alex'. KEIN Microsoft-365-Personenfeld. | Kein Zugriff auf .Email oder .DisplayName. Keine Ableitung aus dem angemeldeten Benutzer. Eine echte Zuordnung wäre ein eigener Einrichtungsschritt. |
| [B] | `Status` | `Status` | Auswahl | Auftrag Befund 8: Entwurf, Geprüft, Freigegeben. Standard Entwurf. | keine |
| [B] | `Freigegeben am` | `Freigegebenam` | Datum (ohne Uhrzeit) | Auftrag Befund 8: bisher ohne Uhrzeit. | Optional auf 'Datum und Uhrzeit' erweitern. Solange nicht erweitert, schreibt die App nur das Datum - eine Uhrzeit wäre sonst frei erfunden. |
| [B] | `Freigegeben von` | `Freigegebenvon` | Person | Auftrag Befund 8: echtes Personenfeld - im Unterschied zu Therapeut. | keine. Die App schreibt den angemeldeten Benutzer als Personeneintrag. |
| [B] | `Dokumentenlink` | `Dokumentenlink` | Hyperlink oder Text | Wird vom bestehenden Exportprozess gesetzt. | Die App schreibt dieses Feld NICHT, um vorhandene Ablaeufe nicht zu doppeln. |
| [B] | `Terminstatus` | `Terminstatus` | Auswahl | Auftrag Abschnitt 6: Nur 'Durchgeführt' verbraucht Einheiten. | Werte sicherstellen: Geplant, Durchgeführt, Abgesagt, Nicht erschienen, Storniert. |
| [!] | `Patient` | `Patient` | unbekannt (Ziel: unbekannt) | Auftrag Befund 6: Typ und Ziel nicht belegt. | OFFEN. Die App schreibt stattdessen PatientID. |
| [!] | `Rezept` | `Rezept` | unbekannt (Ziel: unbekannt) | Auftrag Befund 6: Typ und Ziel nicht belegt. | OFFEN. Die App schreibt stattdessen RezeptID. |
| [+] | `PatientID` | `PatientID` | Zahl | Verweis auf Patientenstamm.ID. | ANLEGEN (Zahl) und indizieren. |
| [+] | `RezeptID` | `RezeptID` | Zahl | Verweis auf Rezepte.ID. Der Zähler-Flow filtert hierauf. | ANLEGEN (Zahl) und indizieren - sonst läuft der Flow in Listenansichtsgrenzen. |
| [?] | `Behandlungsdatum` | `Behandlungsdatum` | Datum | Auftrag Abschnitt 4: Datumsfelder enthalten teilweise noch keine Uhrzeiten. Die App filtert deshalb über einen Tageszeitraum statt auf Gleichheit. | Anzeigenamen prüfen. |
| [?] | `Situation` | `Situation` | Mehrzeiliger Text | Inhaltsfeld der Dokumentation. | Anzeigenamen prüfen. |
| [?] | `Massnahmen` | `Massnahmen` | Mehrzeiliger Text | Inhaltsfeld. | Anzeigenamen prüfen. |
| [?] | `Reaktion` | `Reaktion` | Mehrzeiliger Text | Inhaltsfeld (Reaktion/Ergebnis). | Anzeigenamen prüfen. |
| [?] | `Heimuebungen` | `Heimuebungen` | Mehrzeiliger Text | Selten benötigt, in der App eingeklappt. | Anzeigenamen prüfen. |
| [?] | `WeiteresVorgehen` | `WeiteresVorgehen` | Mehrzeiliger Text | Wie Heimübungen. | Anzeigenamen prüfen. |
| [+] | `KorrekturZu` | `KorrekturZu` | Zahl | ID des urspruenglichen Eintrags. Eine Korrektur an einem freigegebenen Eintrag entsteht als neue Zeile, damit der Vorgang nachvollziehbar bleibt. | ANLEGEN (Zahl). |

### AufgabenEinstellungen

| | Anzeigename | Interner Name | Typ | Befund | Erforderliche Änderung |
|---|---|---|---|---|---|
| [S] | `ID` | `ID` | Zahl (System) | Technischer Schlüssel. | keine |
| [B] | `Typart` | `Typart` | Auswahl | Auftrag Befund 9: vorhandener Typname. Die Liste mischt Aufgaben und Einstellungen. | Werte ergaenzen: Einstellung, Textbaustein, Restschwelle, Inaktivität, Abrechnung. |
| [B] | `VersandAktiv` | `VerandAktiv` | Ja/Nein | Auftrag Befund 9: Der interne Name enthält einen Tippfehler (VerandAktiv ohne s). Power Fx spricht den Anzeigenamen an, Power Automate den INTERNEN Namen. | Internen Namen NICHT ändern - das wuerde bestehende Verweise brechen. In Flows zwingend VerandAktiv schreiben. |
| [B] | `MailGesendetam` | `MailGesendetam` | Datum | Auftrag Befund 9: Hat faelschlich einen heutigen Standardwert. Ein vorhandener Wert ist daher KEIN Versandnachweis. | Standardwert entfernen. Feld erst nach erfolgreichem Versand setzen. |
| [B] | `MailIntern` | `MailIntern` | Text | Auftrag Befund 9: enthält info@physio-humanperformance.de. Daraus folgt KEINE aktive Versandverbindung. | keine. |
| [+] | `Aufgabenstatus` | `Aufgabenstatus` | Auswahl | Trennt Aufgabenzeilen von Einstellungszeilen und steuert die Filter der App. | ANLEGEN (Auswahl: Offen, Zurückgestellt, Erledigt). Einstellungszeilen bleiben leer. |
| [+] | `Beschreibung` | `Beschreibung` | Mehrzeiliger Text | Aufgabentext, zugleich Inhalt eines Textbausteins. | ANLEGEN (mehrzeiliger Text). |
| [+] | `Wiedervorlage` | `Wiedervorlage` | Datum | Für das Zurueckstellen. | ANLEGEN (Datum). |
| [+] | `ErledigtAm` | `ErledigtAm` | Datum und Uhrzeit | Zeitpunkt der Erledigung. | ANLEGEN (Datum und Uhrzeit). |
| [+] | `NichtAktuell` | `NichtAktuell` | Ja/Nein | Nicht mehr zutreffende Aufgaben werden gekennzeichnet statt geloescht. | ANLEGEN (Ja/Nein, Standard Nein). |
| [+] | `Ereignisschluessel` | `Ereignisschluessel` | Text | Einmaliger Schlüssel je Ereignis, damit ein erneuter Flow-Lauf keine zweite Aufgabe zur selben Sache anlegt. | ANLEGEN (Text), eindeutig erzwingen. |
| [+] | `RezeptID` | `RezeptID` | Zahl | Bezug der Aufgabe zum Rezept. | ANLEGEN (Zahl). |
| [+] | `PatientID` | `PatientID` | Zahl | Bezug der Aufgabe zum Patienten. | ANLEGEN (Zahl). |
| [+] | `Restschwelle` | `Restschwelle` | Zahl | Einstellung: ab wie vielen Resteinheiten erinnert wird. | ANLEGEN (Zahl, Standard 1). |
| [+] | `InaktivTage` | `InaktivTage` | Zahl | Einstellung: Hinweis nach so vielen Tagen ohne Behandlung. | ANLEGEN (Zahl, Standard 21). |
| [+] | `Abrechnungsschwelle` | `Abrechnungsschwelle` | Zahl | Einstellung: Abrechnungshinweis nach so vielen erbrachten Einheiten. | ANLEGEN (Zahl, Standard 5). |
| [+] | `VortagAktiv` | `VortagAktiv` | Ja/Nein | Einstellung: Vortagserinnerung ein/aus. | ANLEGEN (Ja/Nein, Standard Nein). |
