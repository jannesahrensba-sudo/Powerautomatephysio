# Start hier – einfache Fassung

Diese Fassung macht **eine Sache**, und die richtig:

```
Heute  →  Patient aufrufen  →  Vorbereitung  →  Dokumentation  →  zurück zu Heute
```

Kein Aufnahme-Assistent, keine Rezeptverwaltung, keine Aufgaben, keine
Einheitenzähler, keine Flows. Das kann später dazukommen – die ausführliche
Fassung liegt unverändert im Ordner `output/`.

Rechnen Sie mit **20 bis 30 Minuten**.

---

## Der Ablauf in der App

| Schritt | Was der Physio sieht |
|---|---|
| **Heute** | Was heute schon dokumentiert wurde, und eine große Schaltfläche „Patient aufrufen". |
| **Patient aufrufen** | Suchfeld, Trefferliste mit Name und Geburtsdatum, je Zeile „Auswählen". |
| **Vorbereitung** | Der wievielte Termin das ist, Befund und Anamnese aus dem Rezept, die bisherigen Dokumentationen – und die Auswahl, wer behandelt. Dann „Bestätigen und dokumentieren". |
| **Dokumentation** | Durchgeführte Maßnahmen, Reaktion und Ergebnis, freiwillig Heimübungen. „Behandlung speichern". |

Nach dem Speichern landet der Eintrag **in „Heute"** und ist zugleich in der
**Vorbereitung desselben Patienten** unter „Bisherige Dokumentationen" zu
sehen – also genau dort, wo man beim nächsten Termin nachschaut.

---

## Schritt 1 – Spalten prüfen (5 Minuten, ändert nichts)

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
cd v2
.\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
```

Die Vorschau lesen, dann ohne `-WhatIf` ausführen. Das Skript legt nur
**Fehlendes** an und fasst Vorhandenes nicht an.

Welche 16 Spalten gebraucht werden, steht in `03_Spalten.md`. Bestätigt ist
bisher nur `Patientenstamm` – die Patientenliste wurde im Tenant korrekt
angezeigt. Die übrigen Namen sind plausibel, aber nicht geprüft; fehlt eine,
meldet Power Apps das direkt nach dem Einfügen an der betroffenen Stelle.

> **Wenn Power Apps Spaltennamen rot unterringelt:** Das sind keine Fehler im
> Code, sondern fehlende Spalten in SharePoint. Diagnose und beide Lösungswege
> stehen in **[`05_Fehlerbehebung/`](05_Fehlerbehebung/README.md)** – inklusive
> einer Klick-für-Klick-Anleitung ohne PowerShell.

## Schritt 2 – Leere App anlegen (2 Minuten)

1. **Erstellen → Leere App → Canvas-App (leer)**, Format **Tablet**.
2. **Einstellungen → Anzeige**: „An Bildschirmgröße anpassen" **aus**,
   „Seitenverhältnis sperren" **aus**.

## Schritt 3 – Datenquellen und App-Formeln (8 Minuten)

Alles in **`02_Eigenschaften_DE.md`** – oder `_EN.md`, falls Ihr Studio auf
Englisch läuft.

> Woran Sie es erkennen: Tippen Sie `If(` in die Formelleiste. Steht dort
> `If( Bedingung; Dann; Sonst )`, nehmen Sie die DE-Datei.

Drei Listen verbinden, Bildschirm `scrPraxis` anlegen, dann `App.Formulas`
und `App.OnStart` setzen. **Vor** dem Einfügen des Oberflächencodes – sonst
fehlen die Farben und alles zeigt Fehler.

## Schritt 4 – Oberfläche einfügen (1 Minute)

Rechtsklick auf `scrPraxis` → **Code einfügen** → vollständigen Inhalt von
`01_AppShell_einfuegen.yaml` einfügen.

Danach steht `conApp` mit 76 untergeordneten Steuerelementen im Baum.

> Erscheint beim Einfügen nichts: Zwischenablage-Berechtigung des Browsers
> für `make.powerapps.com` prüfen.

## Schritt 5 – Durchspielen (5 Minuten)

Legen Sie einen Testpatienten mit erkennbarem Namen an, etwa `ZZ-Test`.

| Prüfung | Erwartet |
|---|---|
| Vorschau starten | Anthrazitfarbene Kopfleiste mit Logo, darunter „Heute" |
| „Patient aufrufen" | Suchfeld und Trefferliste |
| Patient auswählen | Vorbereitung mit Terminnummer, Befund, Therapeutenwahl |
| Ohne Therapeut „Bestätigen" | Hinweis „Bitte zuerst auswählen, wer behandelt." |
| Therapeut wählen, bestätigen | Dokumentationsformular |
| Ohne Text speichern | Hinweis „Bitte Maßnahmen und Reaktion ausfüllen." |
| Beides ausfüllen, speichern | Grüne Meldung, Eintrag steht in „Heute" |
| Denselben Patienten erneut aufrufen | Termin ist jetzt Nr. 2, der Eintrag steht unter „Bisherige Dokumentationen" |

---

## Wenn etwas rot markiert ist

`05_Fehlerbehebung/` erklärt die häufigste Ursache (fehlende Spalten) und
enthält:

- `README.md` – was die Markierungen bedeuten und was zu tun ist
- `Spalten_manuell_anlegen.md` – Klick für Klick in SharePoint, ohne PowerShell
- `Formeln_je_Steuerelement_DE.md` / `_EN.md` – jede betroffene Formel einzeln,
  falls eine Spalte bei Ihnen anders heißt

## Logo

Die Knotengrafik in der Kopfleiste ist als **SVG direkt in der App
hinterlegt** – kein Medien-Upload, keine externe Datei, funktioniert sofort.

> **Ehrlich dazu:** Das ist eine **Nachzeichnung** Ihres Logos, keine Kopie
> der Originaldatei. Die Knoten und Verbindungen sind dem Original
> nachempfunden, aber nicht pixelgenau.

**Wenn Sie das Originallogo verwenden möchten** – zwei Handgriffe:

1. In Power Apps Studio: **Medien → Hochladen**, Ihre Logodatei hochladen
   (PNG oder SVG), zum Beispiel als `LogoPHP`.
2. Am Steuerelement `imgLogo` die Eigenschaft `Image` ersetzen durch:
   ```powerfx
   =LogoPHP
   ```

Der Schriftzug „physio / HUMAN PERFORMANCE" daneben besteht aus zwei normalen
Beschriftungen. Enthält Ihre hochgeladene Datei den Schriftzug bereits,
blenden Sie `conWortmarke` aus (`Visible` auf `=false`) und geben `imgLogo`
mehr Breite.

## Farben

Alle Farben stehen an **einer** Stelle: `App.Formulas` in
`02_Eigenschaften_DE.md`. Sie folgen dem Auftritt der Website:

| Name | Wert | Verwendung |
|---|---|---|
| `clrDunkel` | `#2B2B2B` | Kopfleiste, dunkle Karten |
| `clrDunkelTief` | `#1C1C1C` | Schrittanzeige |
| `clrGold` | `#C9A063` | Hauptaktionen |
| `clrGoldSanft` | `#F6EFE3` | hinterlegte Flächen |
| `clrHintergrund` | `#F4F3F1` | Seitenhintergrund |

Eine Änderung dort wirkt sofort in der ganzen App.

---

## Was diese Fassung bewusst nicht tut

- **Keine Rezeptauswahl.** Es wird automatisch das jüngste Rezept des
  Patienten gelesen. Ist keines da, sagt die App das und lässt die Behandlung
  trotzdem dokumentieren.
- **Keine Einheitenzählung, keine Erinnerungen, keine E-Mails.** Dafür
  bräuchte es Power Automate – siehe `output/05_Flows/`.
- **Keine Freigabe, kein Entwurfsstatus.** Gespeichert ist gespeichert.
- **Kein Bearbeiten bestehender Einträge.** Jede Behandlung ist ein neuer
  Eintrag.

Das ist Absicht: erst im Alltag ankommen, dann erweitern.

## Geprüft und nicht geprüft

| Stufe | Status |
|---|---|
| Struktur, Control-Typen, Varianten, Verweise, Spaltenabgleich | **ausgeführt, bestanden** |
| Power-Apps-Kompilierung | **nicht ausgeführt** – kein Studio-Zugang |
| Test im Tenant, auf Geräten | **nicht ausgeführt** – kein Tenant-Zugang |
| `04_Spalten_anlegen.ps1` | **nicht ausgeführt** – keine PowerShell verfügbar; deshalb `-WhatIf` zuerst |

Die Control-Typen und Varianten stammen aus Ihren vier Einfügeversuchen vom
11. September – sie sind also an Ihrem Tenant belegt, nicht geraten.
