# App-Eigenschaften – Anmeldung (EN)

> **For a Studio with INVARIANT / ENGLISH separators.** Arguments with `,`,
> statements with `;`. If your Studio runs in German, use
> `02_Eigenschaften_DE.md` instead.
>
> How to tell: type `If(` in the formula bar. If it reads
> `If( condition, then, else )`, this file is the right one.

Das App-Objekt lässt sich in Power Apps Studio **nicht** über die Codeansicht
einfügen. Diese Formeln werden deshalb einmal von Hand gesetzt.

**Reihenfolge:** Erst diese Datei, dann den Oberflächencode einfügen. Sonst
zeigen alle Farb-, Größen- und Textangaben einen Fehler, weil die benannten
Formeln noch fehlen.

---

## 1. Datenquellen

**Daten → Daten hinzufügen → SharePoint**, dann diese **zwei** Listen:

| Name in der App | Liste |
|---|---|
| `Patientenstamm` | Patientenstammdaten |
| `Anmeldungen` | Anmeldungen (neu anzulegen) |

`Anmeldungen` gibt es noch nicht – `04_Spalten_anlegen.ps1` legt sie an.

---

## 2. Bildschirm

Bildschirm anlegen und **`scrAnmeldung`** nennen.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `scrAnmeldung` | `Fill` | `=clrHintergrund` |

---

## 3. App-Objekt

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `App` | `StartScreen` | `=scrAnmeldung` |

### `App.Formulas`

Hier stehen **die Honorarsätze und die Praxisanschrift**. Beides steht dem
Patienten rechtsverbindlich auf dem Bildschirm – bitte vor dem ersten Einsatz
gegen das aktuelle Papier prüfen.

```powerfx
// ---------------------------------------------------------------
// Farben nach dem Auftritt von Physio Human Performance.
// Hier - und nur hier - pflegen.
// ---------------------------------------------------------------
clrDunkel      = ColorValue("#2B2B2B");   // Kopfleiste
clrDunkelTief  = ColorValue("#1C1C1C");
clrGold        = ColorValue("#C9A063");   // Hauptaktion, Zustimmung
clrGoldHell    = ColorValue("#DBBC8A");
clrGoldSanft   = ColorValue("#F6EFE3");
clrFlaeche     = ColorValue("#FFFFFF");
clrWeiss       = ColorValue("#FFFFFF");
clrHintergrund = ColorValue("#F4F3F1");
clrText        = ColorValue("#2B2B2B");
clrTextLeise   = ColorValue("#6B6B6B");
clrTextHell    = ColorValue("#C9C7C3");
clrRahmen      = ColorValue("#E3E1DD");
clrErfolg      = ColorValue("#2E6B4F");
clrErfolgSanft = ColorValue("#E8F1EC");
clrWarnung     = ColorValue("#8A5A00");
clrWarnungSanft= ColorValue("#FBF3E2");
clrFehler      = ColorValue("#A33227");
clrFehlerSanft = ColorValue("#FBECEA");

// ---------------------------------------------------------------
// Abstaende und Groessen. Alles eine Spur grosszuegiger als in den
// anderen beiden Apps: hier tippt ein Patient auf einem iPad, oft
// ohne Brille und im Stehen.
// ---------------------------------------------------------------
spS  = 8;
spM  = 16;
spL  = 24;
radM = 10;
radL = 16;
hTouch   = 48;
hEingabe = 64;

// Kopfleiste und Schrittanzeige. Aus den tatsaechlichen Breiten
// dieser App gerechnet, nicht geschaetzt:
//   Kopf mit Wortmarke  = 48 Rand + 52 Logo + 260 Datum
//                         + 2 Abstaende a 16  =  392 plus Wortmarke
//   Kopf ohne Wortmarke = 32 Rand + 40 Logo + 2 Abstaende a 8 = 88
//   Schrittanzeige      = 48 Rand + 120 + 24 + 110 + 24 + Rest
//                         + 4 Abstaende a 8   =  358 + Rest
// Dieselben Werte wie in den anderen beiden Apps, damit alle drei
// auf demselben Geraet gleich umbrechen.
bpMarke   = 760;
bpName    = 520;
bpSchritte = 560;

fsKlein  = 15;
fsNormal = 18;
fsGross  = 22;
fsTitel  = 30;

// ---------------------------------------------------------------
// Praxisangaben. Die Anschrift steht im Datenschutztext als
// Widerrufsadresse - sie MUSS stimmen.
// ---------------------------------------------------------------
praxisOrt = "München";
praxisAnschrift =
    "Physio|Human|Performance" & Char(10) &
    "Planeggerstraße 47d" & Char(10) &
    "81241 München";

// ---------------------------------------------------------------
// Fassung der Honoraraufklaerung. Wird bei JEDER Anmeldung
// mitgespeichert.
//
// Das ist kein Schmuck: Aendern sich die Saetze, muss nachweisbar
// bleiben, welcher Fassung ein Patient zugestimmt hat. Bei einer
// Preisaenderung also BEIDES aendern - die Tabelle und dieses Datum.
// ---------------------------------------------------------------
vertragsStand = "2026-09-12";

// ---------------------------------------------------------------
// Honorarsaetze. EINZIGE Pflegestelle - der Bildschirm liest sie.
// Preise als Text, damit keine Laenderformatierung dazwischenfunkt.
//
// Uebernommen aus "Honoraraufklaerung private Kassen" der Praxis.
// Bitte vor dem ersten Einsatz gegen das aktuelle Papier pruefen.
// ---------------------------------------------------------------
tblHonorar = Table(
    { Gruppe: "Physio Rezepttext 1", Leistung: "Manuelle Therapie",               Preis: "35,60 €" },
    { Gruppe: "Physio Rezepttext 1", Leistung: "Krankengymnastik",                Preis: "29,70 €" },
    { Gruppe: "Physio Rezepttext 1", Leistung: "Periostmassage",                  Preis: "21,70 €" },
    { Gruppe: "Physio Rezepttext 1", Leistung: "Moor Großpackung",                Preis: "47,80 €" },
    { Gruppe: "Physio Rezepttext 2", Leistung: "Manuelle Therapie",               Preis: "35,60 €" },
    { Gruppe: "Physio Rezepttext 2", Leistung: "Manuelle Lymphdrainage (30 min)", Preis: "36,00 €" },
    { Gruppe: "Physio Rezepttext 2", Leistung: "Periostmassage",                  Preis: "21,70 €" },
    { Gruppe: "Physio Rezepttext 2", Leistung: "Moor Großpackung",                Preis: "47,80 €" },
    { Gruppe: "Sport Rezepttext",    Leistung: "Krankengymnastik am Gerät",       Preis: "55,90 €" },
    { Gruppe: "Sport Rezepttext",    Leistung: "Chirogymnastik",                  Preis: "20,50 €" },
    { Gruppe: "Sport Rezepttext",    Leistung: "Traktion/Extension",              Preis: "8,80 €" },
    { Gruppe: "einmalig je Diagnose und Rezept, auch nach Pausen über 12 Wochen",
      Leistung: "Therapeutische Erstbefundung", Preis: "16,50 €" }
);

// Zeile 1 ist der Platzhalter und gilt als "nicht gewaehlt".
tblVersicherung = Table(
    { Value: "Bitte auswählen ..." },
    { Value: "Privat versichert" },
    { Value: "Beihilfeberechtigt" },
    { Value: "Gesetzlich versichert" },
    { Value: "Selbstzahler" }
);
```

### `App.OnStart`

```powerfx
// Nur Oberflaechenzustand.
//
// gblPatient, gblVorhandenerPatient, gblAnmeldung und gblGeburtsdatum
// stehen hier ABSICHTLICH nicht: Eine Variable, die nie gesetzt wurde,
// ist in Power Apps bereits leer. Es sind Datensaetze beziehungsweise
// ein Datum, keine Texte - ihren Typ bekommen sie von der Stelle, an
// der sie tatsaechlich befuellt werden.
Set(gblSchritt, "Start");
Set(gblSpeichert, false);
Set(gblPruefen, false);
Set(gblReset, false);
Set(gblMeldung, "");
Set(gblMeldungArt, "");
Set(gblFehlerText, "");

// Textpuffer der Eingabefelder. Sie sind Text - "" ist hier also
// richtig und noetig, weil Default darauf zeigt.
Set(gblTxtVorname, "");
Set(gblTxtNachname, "");
Set(gblTxtGeburt, "");
Set(gblTxtTelefon, "");
Set(gblTxtEMail, "");
Set(gblTxtStrasse, "");
Set(gblTxtPLZ, "");
Set(gblTxtOrt, "");
Set(gblTxtHonorarName, "");
Set(gblTxtDsName, "");

// Zustimmungen. Die vier Kontaktwege und Social Media sind bewusst
// TEXT und nicht Ja/Nein: "" bedeutet unbeantwortet, und das ist
// etwas anderes als ein Nein. Die App verlangt eine Antwort.
Set(gblHonorarOk, false);
Set(gblDsOk, false);
Set(gblDsRechnung, "");
Set(gblDsEMail, "");
Set(gblDsTelefon, "");
Set(gblDsWhatsApp, "");
Set(gblDsSocial, "");
```

---

## 4. App-Einstellungen

| Einstellung | Wert | Warum |
|---|---|---|
| Anzeige → An Bildschirmgröße anpassen | **Aus** | Sonst wird die Oberfläche skaliert statt umgebrochen. |
| Anzeige → Seitenverhältnis sperren | **Aus** | Gleicher Grund. |
| Anzeige → Ausrichtung | Beliebig | Die Oberfläche ist auf jede Breite ausgelegt. |

---

## 5. Danach

Rechtsklick auf `scrAnmeldung` → **Code einfügen**, dann den vollständigen
Inhalt von `01_AppShell_einfuegen.yaml` einfügen.
