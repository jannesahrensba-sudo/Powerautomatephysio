# Start hier – Anmeldung am iPad

Die dritte App. Der Patient füllt sie **selbst** aus, während er wartet:

```
Start  →  1 Ihre Daten  →  2 Honorar  →  3 Datenschutz  →  Fertig
```

Am Ende steht ein Eintrag in `Patientenstamm` und ein Eintrag in `Anmeldungen`
mit allen Einwilligungen, dem Datum und der Fassung der Honoraraufklärung.

Rechnen Sie mit **30 Minuten** Einrichtung.

---

## Zur Unterschrift – bitte einmal lesen

**Die App hat kein Unterschriftenfeld zum Draufmalen.** Das Steuerelement
dafür (`PenInput`) steht in der offiziellen Steuerelementliste von Power Apps
nicht zur Verfügung; ich kann es also nicht verlässlich einbauen. Etwas
einzubauen, das ich nicht prüfen kann, hat uns in diesem Projekt schon genug
Runden gekostet.

**Stattdessen** erfasst die App bei jedem der beiden Dokumente:

| Was | Wo es landet |
|---|---|
| ausdrückliche Zustimmung (antippen) | `Honorar_Zugestimmt` / `DS_Zugestimmt` |
| der vom Patienten getippte volle Name | `Honorar_Name` / `DS_Name` |
| Datum der Anmeldung | `Anmeldedatum` |
| genauer Zeitstempel | SharePoint-Systemspalte `Erstellt` |
| Fassung der Honorarsätze | `Vertragsstand` |
| jede freiwillige Einwilligung einzeln | fünf eigene Spalten |

Das ist **mehr** Dokumentation als die Papierfassung liefert: Auf dem Papier
steht eine Unterschrift unter einem Blatt, hier steht je Punkt eine eigene,
zeitgestempelte Antwort – und welche Preise galten.

**Ich bin kein Anwalt, und das hier ist keine Rechtsberatung.** Was ich sagen
kann: Weder die Honoraraufklärung noch die Einwilligung in die
Datenverarbeitung schreibt die gesetzliche Schriftform (§ 126 BGB) vor, für
die eine eigenhändige oder qualifizierte elektronische Unterschrift nötig
wäre. Ob Ihre Praxis diese Form akzeptiert, entscheiden Sie zusammen mit Ihrem
Datenschutzbeauftragten oder Ihrer Anwältin – **bitte vor dem ersten
Echteinsatz.**

Wenn Sie eine gemalte Unterschrift brauchen, sagen Sie Bescheid: dann bleibt
der Weg über ein Foto des unterschriebenen Blattes, so wie vorher geplant.

---

## Die Texte sind Ihre

Honoraraufklärung und Einwilligungserklärung stehen **wortgleich** aus Ihren
beiden PDFs in der App. Ich habe nichts umformuliert und nichts weggelassen –
nur die Reihenfolge an den Bildschirm angepasst und beim WhatsApp-Punkt einen
erklärenden Satz ergänzt, damit die Entscheidung informiert ist.

Was in der App steht, listet **[`06_Rechtstexte.md`](06_Rechtstexte.md)** Wort
für Wort auf. Bitte einmal gegenlesen.

---

## Der Ablauf in der App

| Schritt | Was der Patient sieht |
|---|---|
| **Start** | Begrüßung, was ihn erwartet, eine große Schaltfläche. |
| **1 Ihre Daten** | Vorname, Nachname, Geburtsdatum, Telefon, E-Mail, Adresse, Versicherungsart. |
| **2 Honorar** | Die Honoraraufklärung mit allen Sätzen als Liste. Zustimmen, Namen tippen. |
| **3 Datenschutz** | Einwilligung in die Datenverarbeitung, dann fünf freiwillige Punkte einzeln mit **Ja** oder **Nein**. Namen tippen. „Anmeldung abschließen". |
| **Fertig** | Danke, iPad bitte zurückgeben. Eine Schaltfläche macht alles für den nächsten Patienten frei. |

**Ja und Nein statt Häkchen.** Ein leeres Kästchen sagt nicht, ob jemand
abgelehnt oder die Frage übersehen hat. Die App verlangt zu jedem freiwilligen
Punkt eine ausdrückliche Antwort – und „Nein" ist völlig in Ordnung, das sagt
der Text auch. Für eine Einwilligung ist das die sauberere Form.

**Bereits bekannte Patienten.** Findet die App zu Name und Geburtsdatum einen
vorhandenen Eintrag, wird dieser **aktualisiert** statt ein zweiter angelegt.
Der Patient sieht einen Hinweis. Das verhindert Dubletten, die sonst die
Terminzählung und den Verlauf in der Behandlungs-App durcheinanderbrächten.

---

## Schritt 1 – Liste und Spalten anlegen (8 Minuten)

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
cd anmeldung
.\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
```

Die Vorschau lesen, dann ohne `-WhatIf` ausführen. Das Skript legt die **neue
Liste `Anmeldungen`** an und ergänzt `Patientenstamm` um fünf Kontaktspalten.
Vorhandenes fasst es nicht an.

An den beiden bestehenden Apps ändert sich dadurch nichts – sie lesen aus
`Patientenstamm` nur Vorname, Nachname und Geburtsdatum.

Welche Spalten das sind und warum `PLZ` unbedingt **Text** sein muss, steht in
`03_Spalten.md`.

## Schritt 2 – Leere App anlegen (2 Minuten)

1. **Erstellen → Leere App → Canvas-App (leer)**, Format **Tablet**.
2. **Einstellungen → Anzeige**: „An Bildschirmgröße anpassen" **aus**,
   „Seitenverhältnis sperren" **aus**.

## Schritt 3 – Datenquellen und App-Formeln (10 Minuten)

Alles in **`02_Eigenschaften_DE.md`** – oder `_EN.md`, falls Ihr Studio auf
Englisch läuft.

Dort stehen auch die **Honorarsätze** und die **Praxisanschrift**. Beides
bekommt der Patient rechtsverbindlich zu sehen. Bitte gegen das aktuelle
Papier prüfen, bevor jemand zustimmt.

## Schritt 4 – Oberfläche einfügen (1 Minute)

Rechtsklick auf `scrAnmeldung` → **Code einfügen** → vollständigen Inhalt von
`01_AppShell_einfuegen.yaml` einfügen.

Danach steht `conApp` mit 103 untergeordneten Steuerelementen im Baum.

## Schritt 5 – Durchspielen (10 Minuten)

| Prüfung | Erwartet |
|---|---|
| Vorschau starten | Begrüßungsseite, große goldene Schaltfläche |
| Weiter ohne Eingaben | Hinweis auf die Pflichtfelder, rote Rahmen |
| Geburtsdatum `31.02.1990` | Hinweis, dass das Datum nicht lesbar ist |
| E-Mail ohne `@` | Hinweis auf eine gültige E-Mail-Adresse |
| Alles ausfüllen, weiter | Honorarseite mit der vollständigen Preisliste |
| Weiter ohne Zustimmung | Hinweis, Zustimmung rot umrandet |
| Zustimmen, Namen tippen, weiter | Datenschutzseite |
| Abschließen ohne Antwort auf die fünf Punkte | Hinweis, die offenen Zeilen rot |
| Alles beantworten, abschließen | Dankeseite |
| **In SharePoint nachsehen** | **Ein Eintrag in `Patientenstamm` und einer in `Anmeldungen` mit allen Antworten** |
| Denselben Patienten nochmal anmelden | Hinweis „bereits im System", kein zweiter Eintrag |
| „Für den nächsten Patienten bereitmachen" | Alle Felder leer, zurück zum Start |

Die fett markierte Zeile ist der eigentliche Test.

---

## Das iPad für den Wartebereich

Die Kopfleiste hat **bewusst keine Navigation**. Der Patient kann nicht in
fremde Daten springen – er kommt nur vor und zurück durch seine eigene
Anmeldung.

Was Sie am Gerät zusätzlich einstellen sollten:

- **Geführter Zugriff** (iOS: Einstellungen → Bedienungshilfen → Geführter
  Zugriff). Dreimal die Seitentaste drücken sperrt das iPad auf die App. Ohne
  das kann jeder aus der App heraus in die Fotos oder den Browser.
- **Automatische Sperre aus**, solange das Gerät im Einsatz ist.
- **Ein eigenes Praxiskonto** für das iPad, nicht das persönliche Konto einer
  Mitarbeiterin. In `Erstellt von` steht sonst deren Name unter jeder
  Patienteneinwilligung.

---

## Rezeptfoto – bewusst nicht in dieser App

Naheliegend wäre: der Patient meldet sich hier an, die Rezeption fotografiert
im selben Gerät das Rezept. **Das habe ich nicht gebaut, und zwar aus
Datenschutzgründen.**

Zum Ablegen eines Fotos braucht man einen Patienten. Hier ist noch keiner
gewählt – es müsste also eine Patientensuche hinein. Und dieses iPad liegt im
Wartebereich in der Hand von Patienten. Eine Suche darin heißt: jeder kann die
Namen aller anderen lesen.

Das Rezeptfoto liegt deshalb als Zusatz in der **Erstaufnahme-App**, wo der
Patient in Schritt 1 ohnehin schon gewählt ist und nur Mitarbeiter
hineinkommen: **[`../erstaufnahme/05_Rezeptfoto/README.md`](../erstaufnahme/05_Rezeptfoto/README.md)**

---

## Was diese App bewusst nicht tut

- **Keine gemalte Unterschrift.** Siehe oben.
- **Keine Krankenkassendaten, keine Versichertennummer.** Was nicht gebraucht
  wird, wird nicht erhoben – das ist Datenminimierung nach Art. 5 DSGVO und
  spart Ihnen Ärger.
- **Keine Diagnose, keine Beschwerden.** Das erhebt der Therapeut in der
  Erstaufnahme-App, fachlich und im Gespräch.
- **Kein Ändern bestehender Einwilligungen.** Jede Anmeldung ist ein neuer
  Eintrag mit Datum. Ein Widerruf wird als neue Anmeldung erfasst oder direkt
  in SharePoint vermerkt – die Historie bleibt damit lückenlos.

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Struktur, Control-Typen, Varianten, Verweise, Spaltenabgleich | **ausgeführt, bestanden** |
| Breitenprobe von 320 bis 1280 Punkten | **ausgeführt, kein Überlauf** |
| Power-Apps-Kompilierung | **nicht ausgeführt** – kein Studio-Zugang |
| Test im Tenant, auf dem iPad | **nicht ausgeführt** – kein Tenant-Zugang |
| `04_Spalten_anlegen.ps1` | **nicht ausgeführt** – keine PowerShell verfügbar; deshalb `-WhatIf` zuerst |
| Rechtliche Tragfähigkeit der getippten Bestätigung | **nicht geprüft** – keine Rechtsberatung, siehe oben |

Es sind **ausschließlich Steuerelemente verwendet, die in Ihrem Tenant bereits
durchgelaufen sind**: `Classic/Button`, `Classic/TextInput`,
`Classic/DropDown`, `Gallery`/`Vertical`, `GroupContainer`/`AutoLayout`,
`Label`, `Rectangle`, `Image`. Kein Formular, keine Anlagen, kein
Datumsauswähler, keine Kontrollkästchen – alles Dinge, die in diesem Projekt
schon Ärger gemacht haben oder unbelegt sind.

> **Falls das Euro-Zeichen als Kästchen erscheint:** in `App.Formulas` unter
> `tblHonorar` das `€` durch `EUR` ersetzen. Eine Stelle, alle Preise.
