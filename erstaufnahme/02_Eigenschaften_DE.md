# App-Eigenschaften – Erstaufnahme (DE)

> **Für ein Studio mit DEUTSCHEN Trennzeichen.** Argumente mit `;`,
> Anweisungen mit `;;`. Läuft Ihr Studio auf Englisch, nehmen Sie
> `02_Eigenschaften_EN.md`.
>
> Woran Sie es erkennen: Tippen Sie `If(` in die Formelleiste. Steht dort
> `If( Bedingung; Dann; Sonst )`, ist diese Datei die richtige.

Das App-Objekt lässt sich in Power Apps Studio **nicht** über die Codeansicht
einfügen. Diese wenigen Formeln werden deshalb einmal von Hand gesetzt.

**Reihenfolge:** Erst diese Datei, dann den Oberflächencode einfügen. Sonst
zeigen alle Farb- und Größenangaben einen Fehler, weil die benannten Formeln
noch fehlen.

---

## 1. Datenquellen

**Daten → Daten hinzufügen → SharePoint**, dann diese **zwei** Listen:

| Name in der App | Liste |
|---|---|
| `Patientenstamm` | Patientenstammdaten |
| `Rezept` | Rezepte |

> **Achtung, Einzahl.** Ihre laufende Behandlungs-App greift auf `Rezept` zu,
> nicht auf `Rezepte`. Beide Apps müssen denselben Namen verwenden, sonst
> schreibt die Aufnahme in eine andere Quelle als die andere App liest.
> Heißt die Datenquelle bei Ihnen anders, benennen Sie **die Datenquelle in
> der App** um – dann bleiben alle Formeln gültig.

Die Liste `Behandlungsdokumentation` wird hier **nicht** gebraucht.

---

## 2. Bildschirm

Bildschirm anlegen und **`scrAufnahme`** nennen.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `scrAufnahme` | `Fill` | `=clrHintergrund` |

---

## 3. App-Objekt

In der Strukturansicht ganz oben **App** auswählen.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `App` | `StartScreen` | `=scrAufnahme` |

### `App.Formulas`

```powerfx
// ---------------------------------------------------------------
// Farben nach dem Auftritt von Physio Human Performance:
// Anthrazit, Gold, weisse Flaechen. Hier - und nur hier - pflegen.
// ---------------------------------------------------------------
clrDunkel      = ColorValue("#2B2B2B");;   // Kopfleiste
clrDunkelTief  = ColorValue("#1C1C1C");;   // oberer Streifen
clrGold        = ColorValue("#C9A063");;   // Hauptaktion
clrGoldHell    = ColorValue("#DBBC8A");;   // Hover
clrGoldSanft   = ColorValue("#F6EFE3");;   // hinterlegte Flaechen
clrFlaeche     = ColorValue("#FFFFFF");;
clrWeiss       = ColorValue("#FFFFFF");;
clrHintergrund = ColorValue("#F4F3F1");;
clrText        = ColorValue("#2B2B2B");;
clrTextLeise   = ColorValue("#6B6B6B");;
clrTextHell    = ColorValue("#C9C7C3");;   // Text auf Anthrazit
clrRahmen      = ColorValue("#E3E1DD");;
clrErfolg      = ColorValue("#2E6B4F");;
clrErfolgSanft = ColorValue("#E8F1EC");;
clrWarnung     = ColorValue("#8A5A00");;
clrWarnungSanft= ColorValue("#FBF3E2");;
clrFehler      = ColorValue("#A33227");;
clrFehlerSanft = ColorValue("#FBECEA");;

// ---------------------------------------------------------------
// Abstaende und Groessen. hTouch = 48 ist bewusst grosszuegig -
// die App wird am iPad im Stehen bedient.
// ---------------------------------------------------------------
spS  = 8;;
spM  = 16;;
spL  = 24;;
radM = 10;;
radL = 16;;
hTouch   = 48;;

// Ab dieser Breite steht der Inhalt zweispaltig.
bpBreit = 900;;

// Kopfleiste und Schrittanzeige. Aus den tatsaechlichen Breiten
// dieser App gerechnet, nicht geschaetzt:
//   Kopf mit Wortmarke  = 48 Rand + 52 Logo + 240 Marke + 160 Knopf
//                         + 3 Abstaende a 16  =  548
//   Kopf ohne Wortmarke = 32 Rand + 40 Logo + 128 Knopf
//                         + 2 Abstaende a  8  =  216
//   Schrittanzeige      = 48 Rand + 100 + 24 + 200 + 24 + Rest
//                         + 4 Abstaende a  8  =  428 + Rest
// Die Werte sind bewusst dieselben wie in der Behandlungs-App: die
// beiden Apps sollen auf demselben Geraet gleich umbrechen.
bpMarke   = 760;;
bpName    = 520;;
bpSchritte = 560;;

fsKlein  = 13;;
fsNormal = 16;;
fsGross  = 20;;
fsTitel  = 28;;
```

### `App.OnStart`

```powerfx
// Nur Oberflaechenzustand.
//
// gblPatient, gblLetztesRezept und gblAufnahme stehen hier ABSICHTLICH
// nicht: Eine Variable, die nie gesetzt wurde, ist in Power Apps bereits
// leer. Es sind Datensaetze, keine Texte - ihren Typ bekommen sie von
// der Stelle, an der sie tatsaechlich befuellt werden. Ein Set(..., "")
// wuerde sie zu Text machen und jeden Zugriff wie gblPatient.Vorname
// unmoeglich machen.
Set(gblSchritt; "Patienten");;
Set(gblSpeichert; false);;
Set(gblPruefen; false);;
Set(gblReset; false);;
Set(gblMeldung; "");;
Set(gblMeldungArt; "");;
Set(gblFehlerText; "");;
// Nummer der gerade gespeicherten Aufnahme. Eine Zahl, kein
// Datensatz - das Anlagen-Formular bindet ueber LookUp darauf.
Set(gblAufnahmeID; 0);;
// Textpuffer der drei Eingabefelder. Sie sind Text, kein Datensatz -
// "" ist hier also richtig und noetig, weil Default darauf zeigt.
Set(gblTxtD; "");;
Set(gblTxtB; "");;
Set(gblTxtA; "");;
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

Rechtsklick auf `scrAufnahme` → **Code einfügen**, dann den vollständigen
Inhalt von `01_AppShell_einfuegen.yaml` einfügen.

Zum Schluss das Anlagen-Formular ergänzen: **[`05_Anlagen/README.md`](05_Anlagen/README.md)**.
