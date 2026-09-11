# Prüfungen und Tests

## 1. Drei Stufen - bitte nicht verwechseln

| Stufe | Was sie beweist | Status hier |
|---|---|---|
| **A – statische Prüfung** | Struktur, Control-Typen, Verweise, Feld- und Auswahlwertabgleich | **ausgeführt** (unten) |
| **B – Power-Apps-Kompilierung** | Ob jede Formel gültig ist und jede Eigenschaft zum Control-Typ passt | **nicht ausgeführt** |
| **C – Test im Tenant** | Ob Daten korrekt gelesen und geschrieben werden, auf echten Geräten | **nicht ausgeführt** |

> **Es gab in dieser Arbeitsumgebung keinen Zugang zu Power Apps Studio, zu
> einem Microsoft-365-Tenant und zu Power Automate.** Es wurde folglich keine
> App geöffnet, kein Flow importiert und kein Gerät bedient. Eine visuelle
> oder funktionale Abnahme hat **nicht** stattgefunden und wird hier auch
> nicht behauptet.
>
> Stufe A schließt eine große Klasse von Fehlern aus – falsche Control-Typen,
> kaputtes YAML, Tippfehler in Steuerelement- und Spaltennamen, undefinierte
> Farben, Auswahlwerte ohne Entsprechung. Sie beweist **nicht**, dass jede
> Power-Fx-Formel kompiliert.

## 2. Was tatsächlich ausgeführt wurde

Alle Prüfwerkzeuge liegen in `tools/` und sind wiederholbar:

```
python3 tools/validate_pa_yaml.py --fragment output/01_AppShell_einfuegen.yaml
python3 tools/validate_pa_yaml.py           output/01b_Vollstaendiger_Screen.pa.yaml
python3 tools/pruefe_referenzen.py          output/01_AppShell_einfuegen.yaml
python3 tools/pruefe_felder.py              output/01_AppShell_einfuegen.yaml output/03_Schema_Mapping.json
python3 tools/pruefe_auswahlwerte.py        output/01_AppShell_einfuegen.yaml output/04_Setup/Schema-Ergaenzungen.json
```

### A1 – Schemaprüfung gegen das offizielle Power-Apps-Schema

Geprüft gegen `pa.schema.yaml` (v3.0) aus `microsoft/PowerApps-Tooling`, die
Control-Typen zusätzlich gegen die dort hinterlegte Liste der
Erstanbieter-Controls. Beide Dateien liegen unverändert in `tools/`.

**Ergebnis:** bestanden, 217 Steuerelemente, als Fragment und als vollständiger
Bildschirm.

Zwei Befunde aus dieser Arbeit sind festzuhalten:

- Das offizielle Schema enthält in `CodeComponent-ComponentName` ein
  **ungültiges Suchmuster** (eine schließende Klammer ohne öffnende). Der
  Prüfer repariert genau dieses eine Muster, damit die übrige Prüfung laufen
  kann. Die App verwendet keine Code-Komponenten; das Ergebnis ändert sich
  dadurch nicht.
- Die Control-Liste wird im Schema nur als Platzhalter geführt. Der Prüfer
  setzt die echte Liste ein und ist dadurch **strenger** als das Schema. Zum
  Gegentest wurden Microsofts eigene Beispieldateien geprüft: `Screen1` und
  `Single-File-App` bestehen, `FormsScreen2` fällt durch – es verwendet
  `Control: Component`, das in der Control-Liste nicht enthalten ist. Der
  Prüfer arbeitet also wie beabsichtigt.

### A2 – Querverweise

| Geprüft | Anzahl | Ergebnis |
|---|---|---|
| Steuerelementverweise (`txtDokuMassnahmen.Text` …) | 53 | alle auflösbar |
| benannte Formeln (`clrAkzent`, `hTouch` …) | 38 | alle in `App.Formulas` definiert |
| globale Variablen (`gbl…`) | 28 | alle gesetzt und gelesen |

### A3 – Feldabgleich Code gegen Dokumentation

41 vom Code angesprochene SharePoint-Spalten, **alle** in
`03_Schema_Mapping.json` dokumentiert. Sieben dokumentierte Spalten werden von
der App nicht verwendet – das ist richtig so: `Erbracht`, `LetzterAppTermin`,
`ZaehlerLauf`, `Ereignisschluessel` und `MailGesendetam` schreibt Power
Automate, und das Titelfeld des Rezepts wird bewusst gemieden, weil sein
Anzeigename ungeklärt ist.

### A4 – Auswahlwerte

Geschrieben werden `Aktiv`, `Entwurf`, `Erledigt`, `Freigegeben`, `Geprüft`,
`Zurückgestellt`; verglichen zusätzlich `Durchgeführt`, `Offen`,
`Textbaustein`. **Alle** sind in `04_Setup/Schema-Ergaenzungen.json` definiert.
Ersatztexte für leere Felder (`ohne Status`, `Therapeut offen` …) werden nie
gespeichert und müssen daher nicht existieren.

### A5 – Konsistenz der Ausgabedateien

`01_AppShell_einfuegen.yaml`, die `.txt`-Fassung und der Steuerelementteil von
`01b_Vollstaendiger_Screen.pa.yaml` sind zeichengleich (4161 Zeilen
Steuerelementcode). Die drei Dateien können nicht auseinanderlaufen.

### A6 – Flow-Definitionen

Alle vier Dateien sind gültiges JSON mit auflösbarem Aktionsbaum (12 / 26 /
18 / 16 Aktionen). **Das ist eine reine Formprüfung.** Kein Flow wurde
importiert oder ausgeführt.

### Nicht ausgeführt

- **PowerShell:** In dieser Umgebung ist keine PowerShell installiert. Die
  drei Skripte in `04_Setup/` wurden **nicht ausgeführt und nicht getestet.**
  Deshalb gilt: `-WhatIf` zuerst, immer.
- Power Apps Studio, Tenant, Endgeräte – siehe Stufe B und C.

---

## 3. Tests in Power Apps Studio (Stufe B)

Nach dem Einfügen zeigt Studio jeden Formelfehler an. Reihenfolge der Prüfung:

| # | Prüfung | Erwartet |
|---|---|---|
| B1 | Nach dem Einfügen: **App-Prüfung** öffnen | Keine Fehler. Fehler an Spaltennamen sind der erwartete Fall, wenn `Pruefe-Schema.ps1` noch nicht abgearbeitet wurde. |
| B2 | Baumansicht | `conPraxisApp` mit 216 untergeordneten Steuerelementen |
| B3 | Fenster auf ~1400 px | Navigation links, 248 px breit |
| B4 | Fenster auf ~600 px | Navigation oben, waagerecht, Beschriftungen unter den Symbolen |
| B5 | Vorschau ohne Patient | Kopf zeigt „Kein Patient ausgewählt", die Akte den Hinweistext – keine leeren Flächen |
| B6 | Rezept ohne `ZaehlerStand` | „Einheiten noch nicht berechnet" in Warnfarbe – **niemals** „0 offen" |

> **B6 ist die wichtigste Prüfung.** Wenn hier „0 offen" steht, ist etwas
> falsch: Ein nicht berechneter Zähler darf nicht wie ein berechnetes Ergebnis
> aussehen.

---

## 4. Tests im Tenant und auf den Praxisgeräten (Stufe C)

Für alle Tests **ausschließlich klar gekennzeichnete Testdatensätze**
verwenden – etwa Nachname `ZZ-Test`. Keine Tests an echten Patientendaten.
Die Diagnosen in Testrezepten sollen erkennbar Testtexte sein, keine
erfundenen Befunde.

### C1 – Mehrere Rezepte je Patient
Zwei Rezepte für denselben Testpatienten anlegen, abwechselnd auswählen.
**Erwartet:** Der Kopf zeigt immer das gewählte Rezept. Eine Dokumentation
landet an dem Rezept, das beim Speichern ausgewählt war.

### C2 – Patientenwechsel
Patient A öffnen, Rezept wählen, zu Patient B wechseln.
**Erwartet:** `gblRezept` bleibt nicht stehen – Rezept und Dokumentation
werden beim Öffnen einer Akte geleert. Es darf **keine** fremde Rezept-ID in
eine neue Dokumentation geraten.

### C3 – Ungespeicherte Eingaben
In der Akte einen Namen ändern, ohne zu speichern, dann in der Navigation
einen anderen Bereich anklicken.
**Erwartet:** Die Rückfrageleiste erscheint. „Hier bleiben" behält die
Eingaben, „Eingaben verwerfen" setzt die Felder zurück und wechselt.

### C4 – Entwurf und Freigabe
Dokumentation speichern → Status `Entwurf`. Freigeben.
**Erwartet:** Alle Eingabefelder gehen auf „nur lesen", die grüne Leiste
erscheint, `Freigegeben von` enthält den angemeldeten Benutzer,
`Freigegeben am` das heutige Datum. Speichern und Freigeben sind danach
gesperrt.

### C5 – Korrektur eines freigegebenen Eintrags
Auf der grünen Leiste „Korrektur erfassen".
**Erwartet:** Ein **neuer** Eintrag mit `KorrekturZu` = ID des Originals. Der
ursprüngliche Eintrag bleibt unverändert.

### C6 – Doppelklick
Bei „Entwurf speichern" zweimal schnell klicken.
**Erwartet:** Beim ersten Klick wechselt die Beschriftung auf „Speichert …"
und der Schalter ist gesperrt. **Genau ein** neuer Listeneintrag.

### C7 – Wiederholtes Speichern
Denselben Eintrag drei Mal speichern.
**Erwartet:** Weiterhin **eine** Zeile, `EinheitenApp` am Rezept unverändert.
Der Zähler rechnet neu, er zählt nicht hoch.

### C8 – Stornierung
Eine dokumentierte Behandlung von `Durchgeführt` auf `Storniert` setzen und
speichern.
**Erwartet:** Nach dem Flow-Lauf sinkt `EinheitenApp` um die Menge dieser
Zeile, `Offen` steigt entsprechend. Der Eintrag bleibt erhalten.

### C9 – Fehlende Verbindung
Gerät in den Flugmodus, dann speichern.
**Erwartet:** Rote Fehlerleiste mit der Meldung des Systems. **Die Eingaben
bleiben in den Feldern.** Nach Wiederherstellen der Verbindung führt ein
erneuter Klick zum Erfolg.

### C10 – Große Listen und Delegierung
Über 2000 Testpatienten, dann nach einem Nachnamen suchen.
**Erwartet:** Treffer erscheinen auch dann, wenn sie jenseits der ersten 500
Zeilen liegen – die Suche läuft über `StartsWith` auf dem Server. Werden genau
so viele Zeilen angezeigt wie das Datenzeilenlimit, erscheint der Hinweis zur
Delegierungsgrenze in Warnfarbe.

### C11 – Verspäteter Zähler
Dokumentation speichern und sofort auf den Kopfbereich schauen.
**Erwartet:** „Wird neu berechnet – Stand von …". Nach dem Flow-Lauf und
„Stand aktualisieren" der neue Wert. Zu keinem Zeitpunkt eine erfundene Zahl.

### C12 – Verschobener Termin (nur mit gepflegter Planung)
Geplanten Termin um eine Woche verschieben.
**Erwartet:** Die alte Vortagserinnerung bleibt als Historie stehen, eine neue
entsteht zum neuen Datum – der Ereignisschlüssel enthält das Datum.

### C13 – Gleichzeitige Änderung
Physio A öffnet die Dokumentation, Physio B ändert währenddessen die Diagnose
am Rezept. A speichert.
**Erwartet:** Die Diagnose bleibt die von B. Die App schreibt nur die
Dokumentation; der Zähler-Flow aktualisiert per `MERGE` ausschließlich die
Zählerfelder.

### C14 – Aufgaben werden nicht doppelt angelegt
Flow 2 zwei Mal hintereinander manuell starten.
**Erwartet:** Beim zweiten Lauf entsteht keine einzige neue Aufgabe – der
Ereignisschlüssel greift.

### C15 – Versand aus
Flow 4 bei `VersandAktiv` = nein starten.
**Erwartet:** Lauf endet erfolgreich ohne Mail. `MailGesendetam` bleibt leer.

### C16 – Versand scheitert
Flow 4 bei eingeschaltetem Versand mit ungültiger Empfängeradresse.
**Erwartet:** Lauf schlägt fehl, `MailGesendetam` bleibt **leer**, und der
nächste Lauf nimmt dieselben Aufgaben erneut mit.

### C17 – Geräte
iPad quer und hoch, ein schmales Telefon, ein Desktop-Browser.
**Erwartet:** Kein waagerechtes Scrollen durch Formulare. Alle Schaltflächen
mindestens 44 px hoch. Umbruchpunkte bei 900 px und 700 px.

---

## 5. Nach einer Umbenennung von `AltEinheiten`

Wird der Anzeigename der **Doku**-Spalte auf `Behandlungsmenge` geändert
(siehe `04_Setup/README.md`), sind in `01_AppShell_einfuegen.yaml` genau
**drei** Stellen anzupassen – sie erkennen Sie daran, dass dort `gblDoku`
steht:

| Zeile | Steuerelement | Fundstelle |
|---|---|---|
| 3027 | `chkDokuAbweichend` | `Default: =Coalesce(gblDoku.AltEinheiten, 1) <> 1` |
| 3042 | `txtDokuMenge` | `Default: =Text(Coalesce(gblDoku.AltEinheiten, 1))` |
| 3486 | `btnDokuEntwurf` | `AltEinheiten:` im Patch-Datensatz |

> **Die übrigen vier Fundstellen dürfen nicht geändert werden.** Sie
> beginnen mit `gblRezept` und meinen die neue Rezeptspalte `AltEinheiten`
> – also den Altbestand des Rezepts. Genau diese beiden Dinge auseinander zu
> halten, ist der Kern von Befund 3.

Der **interne** Name `Einheiten` bleibt in jedem Fall unverändert. Die Flows
sind deshalb von der Umbenennung **nicht** betroffen.

Nach der Änderung erneut prüfen:

```
python3 tools/pruefe_felder.py output/01_AppShell_einfuegen.yaml output/03_Schema_Mapping.json
```
