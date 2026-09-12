# Zusaetzlich zu setzende App- und Bildschirmeigenschaften (DE)

> **Diese Datei ist für eine Studio-Oberflaeche mit DEUTSCHEN Trennzeichen.**
> Argumente werden mit `;` getrennt, mehrere Anweisungen mit `;;`.
> Wenn Ihr Power Apps Studio auf Englisch steht, verwenden Sie stattdessen
> `02_Eigenschaften_EN.md`.
>
> Woran Sie es erkennen: Tippen Sie `If(` in die Formelleiste. Zeigt die
> Hilfe `If( Bedingung; Dann; Sonst )`, ist die deutsche Fassung richtig.

## Warum diese Datei ueberhaupt nötig ist

Das **App-Objekt lässt sich in Power Apps Studio nicht über die Codeansicht
einfügen** - das ist eine dokumentierte Einschraenkung von "Code anzeigen /
Code einfügen". `OnStart`, `Formulas`, `StartScreen` und die
Bildschirmeigenschaften müssen deshalb einmal von Hand gesetzt werden.

Ein eingefuegter YAML-Block installiert ausserdem **keine** Anmeldungen,
Datenverbindungen, Berechtigungen, SharePoint-Listen und keine Flows. Diese
Datei enthält genau die Handgriffe, die zusätzlich nötig sind - mehr nicht.

**Reihenfolge ist wichtig.** Setzen Sie Abschnitt 1 bis 3 *vor* dem Einfuegen
des Oberflaechencodes. Sonst zeigen fast alle Farb- und Groessenangaben einen
Fehler, weil die benannten Formeln noch fehlen.

---

## 1. Datenquellen (vor allem anderen)

Fuegen Sie unter **Daten > Daten hinzufuegen > SharePoint** genau diese vier
Listen hinzu. Die Namen in der App müssen exakt so lauten, weil alle Formeln
sie so ansprechen:

| Name in der App | Erwartete SharePoint-Liste |
|---|---|
| `Patientenstamm` | Patientenstammdaten |
| `Rezepte` | Rezepte |
| `Behandlungsdokumentation` | Behandlungsdokumentation |
| `AufgabenEinstellungen` | gemischte Aufgaben-/Einstellungsliste |

Weicht ein Listenname in Ihrem Tenant ab, benennen Sie die Datenquelle in der
App um - dann bleiben alle Formeln gueltig.

---

## 2. Bildschirm anlegen

Legen Sie einen leeren Bildschirm an und benennen Sie ihn **`scrPraxis`**.

> Der Oberflaechencode selbst braucht diesen Namen *nicht*: Alle
> Umbruchpunkte beziehen sich auf `conPraxisApp.Width`, nicht auf den
> Bildschirmnamen. Der Name wird nur für `StartScreen` gebraucht.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `scrPraxis` | `Fill` | `=clrHintergrund` |

### `scrPraxis.OnVisible`

```powerfx
// Nur der Ladeversuch wird abgesichert, nicht die ganze Kette.
IfError(
    Refresh(Behandlungsdokumentation);
    Set(gblLadeFehlerHeute; true);;
    Set(gblMeldung; "Die Daten konnten nicht geladen werden. Bitte Verbindung pruefen. " & FirstError.Message);;
    Set(gblMeldungArt; "Fehler")
);;
If(Not(gblLadeFehlerHeute); Set(gblLadeFehlerHeute; false))
```

---

## 3. App-Objekt

Waehlen Sie in der Strukturansicht ganz oben **App** aus.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `App` | `StartScreen` | `=scrPraxis` |
| `App` | `BackEnabled` | `=false` |

### `App.Formulas`

Das ist die zentrale Pflegestelle für Farben, Abstände, Umbruchpunkte und
Konfiguration. Aendern Sie eine Farbe hier, ändert sie sich in der ganzen App.

```powerfx
// ---------------------------------------------------------------
// Farben der Praxis-App. Hier - und nur hier - werden Farben gepflegt.
// ---------------------------------------------------------------
clrAkzent        = ColorValue("#6654C7");;
clrAkzentDunkel  = ColorValue("#24164D");;
clrAkzentSanft   = ColorValue("#EEEBF9");;
clrHintergrund   = ColorValue("#F7F8FB");;
clrFlaeche       = ColorValue("#FFFFFF");;
clrFlaecheWeiss  = ColorValue("#FFFFFF");;
clrText          = ColorValue("#1D1B20");;
clrTextLeise     = ColorValue("#5B5B6B");;
clrRahmen        = ColorValue("#E2E3EC");;
clrNavRuhe       = ColorValue("#BDB6DC");;
clrErfolg        = ColorValue("#1E7A4B");;
clrErfolgSanft   = ColorValue("#E9F5EE");;
clrWarnung       = ColorValue("#8A5A00");;
clrWarnungSanft  = ColorValue("#FBF3E2");;
clrFehler        = ColorValue("#B3261E");;
clrFehlerSanft   = ColorValue("#FCECEB");;

// ---------------------------------------------------------------
// Abstaende, Radien und Groessen.
// hTouch = 44 ist das Mindestmass fuer ein Touchziel auf dem iPad.
// ---------------------------------------------------------------
spXS = 4;;
spS  = 8;;
spM  = 16;;
spL  = 24;;
radM = 10;;
radL = 14;;
hTouch   = 44;;
hEingabe = 48;;

// ---------------------------------------------------------------
// Umbruchpunkte und Schriftgroessen.
// ---------------------------------------------------------------
bpBreit  = 900;;
bpMittel = 700;;
fsKlein  = 12;;
fsNormal = 15;;
fsGross  = 19;;
fsTitel  = 26;;

// ---------------------------------------------------------------
// Konfiguration aus der Einstellungsliste.
// Coalesce liefert einen Standardwert, solange keine Zeile gepflegt ist.
// Eine fehlende Einstellungszeile fuehrt so nie zu einem leeren Bildschirm.
// ---------------------------------------------------------------
recEinstellungen = LookUp(AufgabenEinstellungen; Typart.Value = "Einstellung");;

cfgRestschwelle        = Coalesce(recEinstellungen.Restschwelle; 1);;
cfgInaktivTage         = Coalesce(recEinstellungen.InaktivTage; 21);;
cfgAbrechnungsschwelle = Coalesce(recEinstellungen.Abrechnungsschwelle; 5);;
cfgMailIntern          = Coalesce(recEinstellungen.MailIntern; "");;
cfgVersandAktiv        = Coalesce(recEinstellungen.VersandAktiv; false);;
cfgVortagAktiv         = Coalesce(recEinstellungen.VortagAktiv; false);;

// Muss mit Einstellungen > Allgemein > Datenzeilenlimit uebereinstimmen.
// Wird nur verwendet, um eine erreichte Delegierungsgrenze ehrlich zu melden.
cfgZeilenGrenze = 500;;
```

### `App.OnStart`

```powerfx
// Nur Oberflaechenzustand. Es werden bewusst KEINE Listen in lokale
// Sammlungen geladen: eine auf 500/2000 Zeilen begrenzte Kopie wäre
// unvollstaendig und wuerde wie ein vollstaendiger Bestand aussehen.
Set(gblAnsicht; "Heute");;
Set(gblPatient; Blank());;
Set(gblRezept; Blank());;
Set(gblDoku; Blank());;
Set(gblAufgabe; Blank());;
Set(gblSchreibErgebnis; Blank());;
Set(gblSpeichert; false);;
Set(gblUngespeichert; false);;
Set(gblFrageWechsel; false);;
Set(gblWechselZiel; "");;
Set(gblMeldung; "");;
Set(gblMeldungArt; "");;
Set(gblFehlerText; "");;
Set(gblAufnahmeSchritt; 1);;
Set(gblAufnahmePatientNeu; false);;
Set(gblFormularReset; false);;
Set(gblResetMassnahmen; false);;
Set(gblDokuMassnahmenText; Blank());;
Set(gblDokuMehr; false);;
Set(gblZeigeVorherige; false);;
Set(gblKorrekturZu; 0);;
Set(gblZaehlerAngefordert; Blank());;
Set(gblPruefeAkte; false);;
Set(gblPruefeAufn1; false);;
Set(gblPruefeAufn2; false);;
Set(gblPruefeDoku; false);;
Set(gblLadeFehlerHeute; false);;
// Vorauswahl des Terminstatus, wenn ein Termin im Voraus erfasst wird.
Set(gblTerminVorauswahl; Blank());;
// Bewusst leer: "Therapeut" ist ein Auswahlfeld (Choice) und KEINE
// Benutzerzuordnung. Der angemeldete Benutzer darf daraus nicht
// abgeleitet werden. Eine echte Zuordnung wird separat eingerichtet
// (siehe 03_Datenmodell.md, Befund 7).
Set(gblTherapeutVorauswahl; Blank());;
```

---

## 4. Danach: Oberflaechencode einfügen

Rechtsklick auf `scrPraxis` in der Strukturansicht > **Code einfügen**, dann
den vollständigen Inhalt von `01_AppShell_einfuegen.yaml` einfügen.

---

## 5. App-Einstellungen

| Einstellung | Wert | Warum |
|---|---|---|
| Einstellungen > Anzeige > Ausrichtung | Beliebig / Querformat | Die Oberflaeche ist auf jede Breite ausgelegt. |
| Einstellungen > Anzeige > An Bildschirmgroesse anpassen | **Aus** | Sonst wird die Oberflaeche skaliert statt umgebrochen. |
| Einstellungen > Anzeige > Seitenverhaeltnis sperren | **Aus** | Gleicher Grund. |
| Einstellungen > Allgemein > Datenzeilenlimit | **500** | Muss zu `cfgZeilenGrenze` in `App.Formulas` passen, damit die Meldung zur Delegierungsgrenze stimmt. Wenn Sie hier 2000 einstellen, setzen Sie `cfgZeilenGrenze = 2000`. |

---

## 6. Was danach noch offen ist

Diese Punkte werden durch das Einfuegen **nicht** miterledigt:

1. **Spalten, die noch fehlen** - siehe `03_Datenmodell.md` und das
   Bestandsskript in `04_Setup/`. Solange eine Spalte fehlt, zeigt die
   zugehörige Formel in Studio einen Fehler.
2. **Auswahlwerte (Choices)** - `Rezeptstatus`, `Aufgabenstatus` und die
   Terminstatuswerte müssen in SharePoint vorhanden sein.
3. **Flows** - Zaehlung und Erinnerungen laufen in Power Automate, nicht in
   der App. Ohne diese Flows bleibt der Rezeptstand dauerhaft als
   "noch nicht berechnet" gekennzeichnet. Das ist Absicht: Eine fehlende
   Berechnung darf nicht wie "0 offen" aussehen.
4. **Berechtigungen** - Wer Einstellungen ändern darf, wird über die
   SharePoint-Berechtigungen gesteuert. Ein ausgeblendetes Steuerelement ist
   keine Berechtigung.
