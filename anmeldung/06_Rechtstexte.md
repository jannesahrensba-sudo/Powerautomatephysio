# Was der Patient wörtlich zu sehen bekommt

Diese Datei ist zum **Gegenlesen**. Sie listet jeden Text auf, den die App
anzeigt, und woher er kommt. Bitte einmal mit den beiden PDFs vergleichen,
bevor der erste Patient zustimmt.

Wo ein Text steht, sagt die Spalte „Steuerelement" – so finden Sie ihn in
Studio wieder.

---

## Schritt 2 – Honoraraufklärung

Quelle: **„Honoraraufklärung private Kassen"**, zwei Seiten.

### Einleitung (`lblHonorarText1`)

> Unser Bestreben ist es, dass Ihre Krankenversicherung die anfallenden
> Behandlungskosten vollständig übernimmt.
>
> Aus diesem Grund wird Ihre Behandlung in einzelne Abrechnungspositionen
> aufgegliedert. Die einzelnen Positionen werden nach der Liste der
> beihilfefähigen Heilbehandlungen abgerechnet, sodass eine Übernahme durch
> Ihre private Krankenversicherung oder Beihilfestelle in der Regel möglich
> ist.
>
> Bitte klären Sie die Kostenübernahme mit Ihrer Krankenversicherung.
>
> Um die therapeutische Wirksamkeit zu verbessern, empfehlen wir in der
> Physiotherapie in der Regel Doppeltermine, also zwei aufeinanderfolgende
> Einheiten. Damit haben Sie eine Behandlungsdauer von 50 Minuten. Ein Termin
> in der Sporttherapie dauert 60 Minuten.

**Abweichung vom Papier:** Auf dem Papier steht „Physiotherapie und
Sporttherapie:" als Überschrift und danach ein Satz mit „(zwei
aufeinanderfolgende Einheiten)". Ich habe daraus einen durchgehenden Satz
gemacht, inhaltlich unverändert.

### Honorarsätze (`galPreise`, gespeist aus `tblHonorar`)

| Gruppe | Leistung | Preis |
|---|---|---|
| Physio Rezepttext 1 | Manuelle Therapie | 35,60 € |
| Physio Rezepttext 1 | Krankengymnastik | 29,70 € |
| Physio Rezepttext 1 | Periostmassage | 21,70 € |
| Physio Rezepttext 1 | Moor Großpackung | 47,80 € |
| Physio Rezepttext 2 | Manuelle Therapie | 35,60 € |
| Physio Rezepttext 2 | Manuelle Lymphdrainage (30 min) | 36,00 € |
| Physio Rezepttext 2 | Periostmassage | 21,70 € |
| Physio Rezepttext 2 | Moor Großpackung | 47,80 € |
| Sport Rezepttext | Krankengymnastik am Gerät | 55,90 € |
| Sport Rezepttext | Chirogymnastik | 20,50 € |
| Sport Rezepttext | Traktion/Extension | 8,80 € |
| einmalig je Diagnose und Rezept, auch nach Pausen über 12 Wochen | Therapeutische Erstbefundung | 16,50 € |

**Bitte besonders prüfen.** Die Preise stammen aus einer PDF-Textextraktion.
Die Tabelle im Original ist dreispaltig gesetzt, und dabei kann eine Zuordnung
verrutschen. Zwölf Zeilen, zwei Minuten.

**Abweichung vom Papier:** Der Satz zur Erstbefundung steht im Original als
eigener Absatz auf Seite 2. In der App ist er die letzte Zeile der Preisliste,
mit der Bedingung in der Gruppenspalte.

### Vereinbarung und Absagen (`lblHonorarText2`)

> Diese Honorarsätze gelten als vereinbart, unabhängig davon, ob Ihre private
> Krankenversicherung oder Beihilfestelle diese ganz, nicht oder teilweise
> erstattet. Abzüge von der Rechnung aufgrund unzureichender Erstattung sind
> nicht standhaft und werden nachgefordert.
>
> **Terminabsagen**
> Therapietermine, die innerhalb von 24 Stunden abgesagt werden, können von
> der Praxis in Rechnung gestellt werden (§ 615 BGB).
>
> **Sonstiges**
> Bitte bringen Sie zu allen Behandlungen ein ausreichend großes Handtuch mit.

### Zustimmung (`btnHonorarZu`, `txtHonorarName`)

> Ich habe die Honoraraufklärung gelesen und stimme zu.
>
> Bitte bestätigen Sie mit Ihrem vollständigen Namen.

Darunter: `München, [Datum] · Fassung der Honoraraufklärung: [vertragsStand]`

---

## Schritt 3 – Einwilligung in die Datenverarbeitung

Quelle: **„Einwilligungserklärung in die Datenverarbeitung"**, eine Seite.

### Haupttext (`lblDsHaupttext`)

> Ich bin damit einverstanden, dass meine Daten durch die Praxis zum Zweck der
> Kontaktaufnahme, Behandlungsdurchführung, Dokumentation sowie Abrechnung
> verarbeitet und genutzt werden.
>
> Dazu zählen insbesondere: die Pflege der Kontaktdaten, die Terminorganisation,
> die Abrechnung mit Kostenträgern (Krankenkassen, Beihilfestellen), sowie die
> therapeutische Dokumentation und ggf. notwendige Weitergabe an Ärzt:innen
> oder andere medizinische Partner:innen.

Wortgleich übernommen.

### Hinweise und Widerruf (`lblDsHinweise`)

> Ich bin darauf hingewiesen worden, dass ich
> - diese Einwilligung jederzeit mit Wirkung für die Zukunft widerrufen kann,
> - jederzeit Auskunft über die zu meiner Person gespeicherten Daten verlangen kann,
> - jederzeit Berichtigung, Löschung oder Sperrung meiner personenbezogenen Daten verlangen kann.
>
> Der Widerruf ist zu richten an:
> Physio|Human|Performance
> Planeggerstraße 47d
> 81241 München
>
> Im Fall des Widerrufs werden meine Daten nach Ablauf gesetzlicher Fristen
> gelöscht, sofern dem keine andere gesetzliche Regelung entgegensteht.

**Abweichung vom Papier:** Die drei Punkte stehen im Original als Kästchen zum
Ankreuzen. Das ist inhaltlich seltsam – man kreuzt nicht an, ob man
*hingewiesen wurde*. In der App sind es Aufzählungspunkte, und die Zustimmung
darunter deckt sie mit ab.

**Die Anschrift** kommt aus `praxisAnschrift` in `App.Formulas`. Sie ist die
Widerrufsadresse – wenn sie falsch ist, läuft ein Widerruf ins Leere. Bitte
prüfen.

### Zustimmung (`btnDsZu`, `txtDsName`)

> Ich habe den Text gelesen und willige in die Datenverarbeitung ein.
>
> Bitte bestätigen Sie mit Ihrem vollständigen Namen.

### Die fünf freiwilligen Punkte

Jeder einzeln mit **Ja** oder **Nein** zu beantworten. Keine Vorauswahl.

| Steuerelement | Text | Spalte |
|---|---|---|
| `lblDsRechnung` | Rechnungen dürfen an meine E-Mail-Adresse versandt werden. | `DS_Rechnung_EMail` |
| `lblDsEMail` | Die Praxis darf mich per E-Mail kontaktieren. | `DS_Kontakt_EMail` |
| `lblDsTelefon` | Die Praxis darf mich telefonisch kontaktieren. | `DS_Kontakt_Telefon` |
| `lblDsWhatsApp` | Die Praxis darf mich per WhatsApp kontaktieren. | `DS_Kontakt_WhatsApp` |
| `lblDsSocial` | Anonymisierte Bild- oder Videoaufnahmen … Social Media oder der Website | `DS_SocialMedia` |

**Ergänzung von mir beim WhatsApp-Punkt:**

> Hinweis: WhatsApp gehört zu Meta. Nachrichten laufen über deren Server. Wenn
> Sie das nicht möchten, wählen Sie Nein – wir erreichen Sie dann anders.

Der Satz steht nicht auf dem Papier. Ich habe ihn ergänzt, weil eine
Einwilligung nur wirksam ist, wenn sie informiert erfolgt, und weil bei
WhatsApp eine Übermittlung an einen Dritten stattfindet, die man kennen
sollte. **Wenn Sie ihn nicht wollen, löschen Sie ihn** – er steht in
`lblDsWhatsApp` und sonst nirgends.

**Social Media, Abweichung vom Papier:** Das Original hat dort drei Kästchen
(einwilligen / einverstanden / nicht einverstanden), was sich überschneidet. In
der App ist es eine Frage mit Ja oder Nein.

---

## Was die App zusätzlich anzeigt

Texte, die **nicht** aus den PDFs stammen, sondern Bedienführung sind:

- die Begrüßung auf der Startseite
- die Feldbeschriftungen und Eingabehilfen in Schritt 1
- alle Hinweismeldungen („Bitte Vorname, Nachname und Telefonnummer ausfüllen")
- die Dankeseite

Diese Texte haben keine rechtliche Wirkung, sollten aber trotzdem klingen wie
Ihre Praxis. Ändern Sie sie gern.

---

## Was ich nicht beurteilen kann

Ob diese Umsetzung für Ihre Praxis rechtlich trägt. **Ich bin kein Anwalt.**
Die Punkte, die ich Ihrem Datenschutzbeauftragten oder Ihrer Anwältin vorlegen
würde:

1. Ersetzt die getippte Namensbestätigung bei Ihnen die Unterschrift?
   (Siehe `START_HIER.md`, Abschnitt „Zur Unterschrift".)
2. Ist die Aufteilung der Einwilligungen in fünf einzelne Ja/Nein-Fragen so
   gewollt?
3. Sind die Hinweispunkte als Aufzählung statt als Kästchen in Ordnung?
4. Genügt der ergänzte WhatsApp-Hinweis, oder braucht es mehr?
5. Reicht die Speicherung in SharePoint für Ihre Aufbewahrungspflichten, und
   wie wird ein Widerruf dokumentiert?
