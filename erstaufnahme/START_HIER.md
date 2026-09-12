# Start hier – Erstaufnahme

Die zweite App. Sie macht **eine Sache**:

```
Patient wählen  →  Befund und Anamnese
```

Danach steht der Befund in der **Behandlungs-App** – beim nächsten Termin
unter „Vorbereitung", genau da, wo der Therapeut ohnehin hinschaut.

Rechnen Sie mit **20 bis 25 Minuten**.

---

## Die Verbindung zur Behandlungs-App

**An der Behandlungs-App ist keine einzige Änderung nötig.** Sie liest den
Befund heute schon aus genau den Feldern, die diese App schreibt:

| Diese App schreibt in `Rezepte` | Die Behandlungs-App liest |
|---|---|
| `PatientID` | `Filter(Rezept, PatientID = ThisItem.ID)` |
| `Diagnose laut Rezept` | `gblRezept.'Diagnose laut Rezept'` |
| `Erstbefund` | `gblRezept.Erstbefund` |
| `Anamnese` | `gblRezept.Anamnese` |

> **Die beiden Apps nennen die Datenquelle unterschiedlich:** hier `Rezepte`,
> in der Behandlungs-App `Rezept`. Der Name innerhalb einer App ist nur ein
> lokaler Alias – entscheidend ist, dass **beide auf dieselbe SharePoint-Liste
> zeigen**. Tun sie das nicht, erscheint der Befund nie in der Behandlungs-App.
>
> Kontrolle in 30 Sekunden: in beiden Apps **Daten** öffnen und den Eintrag
> anklicken – dort steht die Liste dahinter.

Die Behandlungs-App nimmt immer das **jüngste** Rezept eines Patienten
(`Sort(..., ID, SortOrder.Descending)`). Eine neue Aufnahme überschreibt also
nichts – sie wird die aktuelle.

---

## Der Ablauf in der App

| Schritt | Was der Therapeut sieht |
|---|---|
| **1 Patient** | Suchfeld, Trefferliste mit Name und Geburtsdatum, je Zeile „Aufnehmen". |
| **2 Befund und Anamnese** | Diagnose laut Rezept, Erstbefund, Anamnese. Liegt schon eine Aufnahme vor, bietet die App an, sie als Ausgangspunkt zu übernehmen. „Aufnahme speichern". |

Nach dem Speichern springt die App zurück zu Schritt 1 und ist bereit für den
nächsten Patienten.

> **Anlagen gibt es hier nicht mehr.** Behandlungsvertrag und
> Datenschutzerklärung erfasst die **Anmelde-App** digital – dort füllt der
> Patient am iPad aus und unterschreibt auf dem Bildschirm, kein Papier, kein
> Abfotografieren. Das Rezeptfoto liegt ebenfalls dort. Siehe
> [`../anmeldung/START_HIER.md`](../anmeldung/START_HIER.md).

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

**Zwei** Listen verbinden (`Patientenstamm` und `Rezepte`), Bildschirm
`scrAufnahme` anlegen, dann `App.Formulas` und `App.OnStart` setzen. **Vor**
dem Einfügen des Oberflächencodes – sonst fehlen die Farben und alles zeigt
Fehler.

## Schritt 4 – Oberfläche einfügen (1 Minute)

Rechtsklick auf `scrAufnahme` → **Code einfügen** → vollständigen Inhalt von
`01_AppShell_einfuegen.yaml` einfügen.

Danach steht `conApp` mit 41 untergeordneten Steuerelementen im Baum.

## Schritt 5 – Durchspielen (8 Minuten)

Legen Sie einen Testpatienten mit erkennbarem Namen an, etwa `ZZ-Test`.

| Prüfung | Erwartet |
|---|---|
| Vorschau starten | Anthrazitfarbene Kopfleiste, darunter die Patientensuche |
| Patient suchen und „Aufnehmen" | Schritt 2 mit Namen und Geburtsdatum im dunklen Kopf |
| Ohne Text speichern | Hinweis „Bitte Erstbefund und Anamnese ausfüllen.", beide Felder rot umrandet |
| Beides ausfüllen, speichern | Grüne Meldung mit der Nummer, zurück zu Schritt 1 |
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
- **Keine Anlagen.** Vertrag und Datenschutzerklärung laufen digital über die
  Anmelde-App, das Rezeptfoto ebenfalls dort.

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Struktur, Control-Typen, Varianten, Verweise, Spaltenabgleich | **ausgeführt, bestanden** |
| Power-Apps-Kompilierung | **nicht ausgeführt** – kein Studio-Zugang |
| Test im Tenant, auf Geräten | **nicht ausgeführt** – kein Tenant-Zugang |
| `04_Spalten_anlegen.ps1` | **nicht ausgeführt** – keine PowerShell verfügbar; deshalb `-WhatIf` zuerst |

Die Control-Typen und Varianten sind dieselben, die in Ihrer laufenden
Behandlungs-App durchgelaufen sind – `Classic/Button`, `Classic/TextInput`,
`Gallery`/`Vertical`, `GroupContainer`/`AutoLayout`, `Label`, `Rectangle`,
`Image`. Es ist kein Steuerelement dabei, das Ihr Studio noch nie gesehen hat.
