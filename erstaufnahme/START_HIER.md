# Start hier – Erstaufnahme

Die zweite App. Sie macht **eine Sache**:

```
Patient wählen  →  Befund und Anamnese  →  Unterlagen anhängen
```

Danach steht der Befund in der **Behandlungs-App** – beim nächsten Termin
unter „Vorbereitung", genau da, wo der Therapeut ohnehin hinschaut.

Rechnen Sie mit **30 bis 40 Minuten**, davon 15 für das Anlagen-Formular.

---

## Die Verbindung zur Behandlungs-App

**An der Behandlungs-App ist keine einzige Änderung nötig.** Sie liest den
Befund heute schon aus genau den Feldern, die diese App schreibt:

| Diese App schreibt in `Rezept` | Die Behandlungs-App liest |
|---|---|
| `PatientID` | `Filter(Rezept, PatientID = ThisItem.ID)` |
| `Diagnose laut Rezept` | `gblRezept.'Diagnose laut Rezept'` |
| `Erstbefund` | `gblRezept.Erstbefund` |
| `Anamnese` | `gblRezept.Anamnese` |

> **Die Datenquelle heißt `Rezept`, Einzahl.** So steht es in Ihrer laufenden
> App. Beide Apps müssen denselben Namen verwenden, sonst schreibt die
> Aufnahme woandershin, als die andere liest.

Die Behandlungs-App nimmt immer das **jüngste** Rezept eines Patienten
(`Sort(..., ID, SortOrder.Descending)`). Eine neue Aufnahme überschreibt also
nichts – sie wird die aktuelle.

---

## Der Ablauf in der App

| Schritt | Was der Therapeut sieht |
|---|---|
| **1 Patient** | Suchfeld, Trefferliste mit Name und Geburtsdatum, je Zeile „Aufnehmen". |
| **2 Befund und Anamnese** | Diagnose laut Rezept, Erstbefund, Anamnese. Liegt schon eine Aufnahme vor, bietet die App an, sie als Ausgangspunkt zu übernehmen. „Aufnahme speichern". |
| **3 Anlagen** | Unterschriebenes Dokument und Rezept anhängen – über die Kamera. „Aufnahme abschließen". |

Gespeichert wird nach Schritt 2. Die Unterlagen können auch später
nachgereicht werden, ohne dass der Befund verloren geht.

---

## Schritt 1 – Spalten prüfen (5 Minuten, ändert nichts)

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
cd erstaufnahme
.\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
```

Die Vorschau lesen, dann ohne `-WhatIf` ausführen. Das Skript legt nur
**Fehlendes** an und fasst Vorhandenes nicht an. Haben Sie das Skript der
Behandlungs-App schon laufen lassen, meldet dieses hier nur noch „vorhanden".

Es prüft außerdem, ob **Anlagen** an der Liste `Rezept` erlaubt sind – ohne
das funktioniert Schritt 3 nicht. Geändert wird die Einstellung nicht; das
ist eine bewusste Entscheidung.

Welche Spalten gebraucht werden, steht in `03_Spalten.md`.

## Schritt 2 – Leere App anlegen (2 Minuten)

1. **Erstellen → Leere App → Canvas-App (leer)**, Format **Tablet**.
2. **Einstellungen → Anzeige**: „An Bildschirmgröße anpassen" **aus**,
   „Seitenverhältnis sperren" **aus**.

## Schritt 3 – Datenquellen und App-Formeln (8 Minuten)

Alles in **`02_Eigenschaften_DE.md`** – oder `_EN.md`, falls Ihr Studio auf
Englisch läuft.

> Woran Sie es erkennen: Tippen Sie `If(` in die Formelleiste. Steht dort
> `If( Bedingung; Dann; Sonst )`, nehmen Sie die DE-Datei.

**Zwei** Listen verbinden (`Patientenstamm` und `Rezept`), Bildschirm
`scrAufnahme` anlegen, dann `App.Formulas` und `App.OnStart` setzen. **Vor**
dem Einfügen des Oberflächencodes – sonst fehlen die Farben und alles zeigt
Fehler.

## Schritt 4 – Oberfläche einfügen (1 Minute)

Rechtsklick auf `scrAufnahme` → **Code einfügen** → vollständigen Inhalt von
`01_AppShell_einfuegen.yaml` einfügen.

Danach steht `conApp` mit 53 untergeordneten Steuerelementen im Baum.

## Schritt 5 – Anlagen-Formular (15 Minuten)

→ **[`05_Anlagen/README.md`](05_Anlagen/README.md)**

Dieser eine Teil wird **nicht per Code eingefügt**, sondern über die
Studio-Oberfläche angelegt. Grund: Das Anlagen-Steuerelement gibt es nur
innerhalb eines Formulars, und Formular-Datenkarten von Hand als YAML zu
schreiben ist die fehleranfälligste Stelle im ganzen Projekt. Sechs Klicks
in Studio sind zuverlässiger.

Bis dahin ist die App **voll benutzbar** – nur Schritt 3 zeigt einen
Platzhalter statt des Anhang-Feldes.

## Schritt 6 – Durchspielen (8 Minuten)

Legen Sie einen Testpatienten mit erkennbarem Namen an, etwa `ZZ-Test`.

| Prüfung | Erwartet |
|---|---|
| Vorschau starten | Anthrazitfarbene Kopfleiste, darunter die Patientensuche |
| Patient suchen und „Aufnehmen" | Schritt 2 mit Namen und Geburtsdatum im dunklen Kopf |
| Ohne Text speichern | Hinweis „Bitte Erstbefund und Anamnese ausfüllen.", beide Felder rot umrandet |
| Beides ausfüllen, speichern | Grüne Meldung, Schritt 3 erscheint |
| Unterlage anhängen, abschließen | Zurück zu Schritt 1 mit grüner Meldung |
| **In der Behandlungs-App denselben Patienten aufrufen** | **Diagnose, Erstbefund und Anamnese stehen unter „Befund und Anamnese"** |
| Denselben Patienten nochmal aufnehmen | Der goldene Kasten „Vorherige übernehmen" erscheint |
| „Vorherige übernehmen" | Alle drei Felder gefüllt, Meldung „Übernommen" |

Die fett markierte Zeile ist der eigentliche Test. Erst wenn der Befund in
der anderen App auftaucht, arbeiten die beiden zusammen.

---

## Folgerezept: warum „Vorherige übernehmen"

Die Behandlungs-App zeigt immer das jüngste Rezept. Legt jemand ein
Folgerezept ohne Befund an, stünde dort plötzlich nichts mehr – obwohl der
alte Befund noch in der Liste liegt.

Deshalb bietet Schritt 2 an, die vorherige Aufnahme zu übernehmen. Der
Therapeut geht sie durch und aktualisiert, was sich geändert hat. Das ist
weniger Tipparbeit als von vorn und ehrlicher als automatisches Kopieren –
ein Befund, den niemand angesehen hat, sollte nicht als aktuell gelten.

## Wer die Aufnahme gemacht hat

Steht automatisch in der SharePoint-Systemspalte **„Erstellt von"**. Dafür
braucht es keine eigene Spalte und keine Auswahl in der App – der Therapeut
ist ohnehin angemeldet. Das Aufnahmedatum steht ebenso automatisch in
**„Erstellt"**.

## Farben und Logo

Identisch zur Behandlungs-App: dieselbe Palette in `App.Formulas`, dasselbe
eingebettete SVG-Logo, dieselben Haltepunkte für schmale Bildschirme. Wer
zwischen den Apps wechselt, soll nicht merken, dass es zwei sind.

Im Kopf steht statt „physio / HUMAN PERFORMANCE" der Titel **„Erstaufnahme"**
– damit auf einen Blick klar ist, in welcher App man gerade tippt.

---

## Was diese App bewusst nicht tut

- **Keine Patientenneuanlage.** Der Patient muss in `Patientenstamm` stehen.
  Wer neu ist, wird zuerst dort angelegt.
- **Kein Bearbeiten bestehender Aufnahmen.** Jede Aufnahme ist ein neuer
  Eintrag. Korrekturen macht man in SharePoint.
- **Keine Behandlungsdokumentation.** Dafür ist die andere App da.
- **Kein Dokumentenscanner.** Den gibt es in Canvas Apps nicht – die App
  nutzt die Kamera des Geräts, deren Dokumentenmodus das Entzerren
  übernimmt.

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Struktur, Control-Typen, Varianten, Verweise, Spaltenabgleich | **ausgeführt, bestanden** |
| Power-Apps-Kompilierung | **nicht ausgeführt** – kein Studio-Zugang |
| Test im Tenant, auf Geräten | **nicht ausgeführt** – kein Tenant-Zugang |
| Das Anlagen-Formular | **nicht gebaut, nicht getestet** |
| `04_Spalten_anlegen.ps1` | **nicht ausgeführt** – keine PowerShell verfügbar; deshalb `-WhatIf` zuerst |

Die Control-Typen und Varianten sind dieselben, die in Ihrer laufenden
Behandlungs-App durchgelaufen sind – `Classic/Button`, `Classic/TextInput`,
`Gallery`/`Vertical`, `GroupContainer`/`AutoLayout`, `Label`, `Rectangle`,
`Image`. Es ist bewusst kein Steuerelement dazugekommen, das Ihr Studio noch
nie gesehen hat. Das Formular in Schritt 5 ist die einzige Ausnahme – und
das legt Studio selbst an.
