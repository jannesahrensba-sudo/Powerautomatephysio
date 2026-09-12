# App-Eigenschaften (DE)

> **Für ein Studio mit DEUTSCHEN Trennzeichen.** Argumente mit `;`,
> mehrere Anweisungen mit `;;`. Läuft Ihr Studio auf Englisch, nehmen Sie
> `02_Eigenschaften_EN.md`.
>
> Erkennen: Tippen Sie `If(` in die Formelleiste. Steht dort
> `If( Bedingung; Dann; Sonst )`, ist diese Datei richtig.

Das App-Objekt lässt sich in Power Apps Studio **nicht** über die Codeansicht
einfügen. Diese wenigen Formeln werden deshalb einmal von Hand gesetzt.

**Reihenfolge:** Erst diese Datei, dann den Oberflächencode einfügen. Sonst
zeigen alle Farb- und Größenangaben einen Fehler, weil die benannten Formeln
noch fehlen.

---

## 1. Datenquellen

**Daten → Daten hinzufügen → SharePoint**, dann diese drei Listen. Die Namen in
der App müssen exakt so lauten:

| Name in der App | Liste |
|---|---|
| `Patientenstamm` | Patientenstammdaten |
| `Rezepte` | Rezepte |
| `Behandlungsdokumentation` | Behandlungsdokumentation |

Heißt eine Liste bei Ihnen anders, benennen Sie **die Datenquelle in der App**
um – dann bleiben alle Formeln gültig.

---

## 2. Bildschirm

Bildschirm anlegen und **`scrPraxis`** nennen.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `scrPraxis` | `Fill` | `=clrHintergrund` |

### `scrPraxis.OnVisible`

```powerfx
// Beim Oeffnen den aktuellen Stand holen. Nur der Ladeversuch
// wird abgesichert, nicht die ganze Kette.
IfError(
    Refresh(Behandlungsdokumentation);
    Set(gblMeldung; "Die Daten konnten nicht geladen werden. Bitte Verbindung pruefen. " & FirstError.Message);;
    Set(gblMeldungArt; "Fehler")
)
```

---

## 3. App-Objekt

In der Strukturansicht ganz oben **App** auswählen.

| Objekt | Eigenschaft | Wert |
|---|---|---|
| `App` | `StartScreen` | `=scrPraxis` |

### `App.Formulas`

Zentrale Pflegestelle für Farben und Größen. Eine Farbänderung hier wirkt in
der ganzen App.

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
spXS = 4;;
spS  = 8;;
spM  = 16;;
spL  = 24;;
radM = 10;;
radL = 16;;
hTouch   = 48;;
hEingabe = 52;;

// Ab dieser Breite steht der Inhalt zweispaltig.
bpBreit = 900;;

fsKlein  = 13;;
fsNormal = 16;;
fsGross  = 20;;
fsTitel  = 28;;
fsRiesig = 40;;
```

### `App.OnStart`

```powerfx
// Nur Oberflaechenzustand. Es werden bewusst keine Listen in
// lokale Sammlungen geladen.
Set(gblSchritt; "Heute");;
Set(gblPatient; Blank());;
Set(gblRezept; Blank());;
Set(gblTherapeut; Blank());;
Set(gblSpeichert; false);;
Set(gblMeldung; "");;
Set(gblMeldungArt; "");;
Set(gblFehlerText; "");;
Set(gblErgebnis; Blank());;
Set(gblReset; false);;
Set(gblPruefen; false);;
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

Rechtsklick auf `scrPraxis` → **Code einfügen**, dann den vollständigen Inhalt
von `01_AppShell_einfuegen.yaml` einfügen.
