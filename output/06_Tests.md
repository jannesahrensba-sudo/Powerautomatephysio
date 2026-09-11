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

### A1b – Control-Varianten (nachtraeglich ergaenzt)

Beim ersten Einfuegen in Power Apps Studio kam:

```
(22,3) : error PA2109s : Unknown variant 'horizontalAutoLayoutContainer'
         for control type 'GroupContainer'.
         Possible suggestions: GridLayout, AutoLayout, ManualLayout.
(22,3) : warning PA4102 : Early Preview code detected with variant
         'horizontalAutoLayoutContainer' for control type 'GroupContainer'.
```

**Ursache:** Die Variantennamen stammten aus den Beispieldateien in
`microsoft/PowerApps-Tooling` (`Examples/Src/Screens/FormsScreen2.pa.yaml`).
Diese Beispiele sind im **Early-Preview-Format** geschrieben – jenem Format,
das die offizielle Dokumentation ausdruecklich als *retired* bezeichnet
(„The format during preview was temporary and is no longer in use."). Das
Schema `pa.schema.yaml` prueft Varianten nicht, deshalb fiel es dort nicht auf.

**Merkmal zum Unterscheiden:** Early-Preview-Varianten beginnen klein und sind
camelCase (`horizontalAutoLayoutContainer`, `galleryVertical`,
`textualEditCard`). Source-Code-Varianten sind PascalCase (`AutoLayout`,
`ManualLayout`, `GridLayout`).

**Behoben:**

| Control | vorher | jetzt |
|---|---|---|
| `GroupContainer` (55×) | `horizontalAutoLayoutContainer` / `verticalAutoLayoutContainer` | `AutoLayout` |
| `Gallery` (7×) | `galleryVertical` | *keine Variante* |
| `Classic/Icon` (1×) | `Home` | *keine Variante* |

Bei den Containern geht dabei nichts verloren: **jeder** Container setzt seine
Richtung ohnehin explizit ueber `LayoutDirection`. Bei Galerie und Symbol ist
der gueltige Source-Code-Name nicht belegt; das Schema erlaubt `Variant`
ausdruecklich wegzulassen („Not all controls require a variant"), dann gilt die
Standardvariante. Die Ausrichtung der Galerien steuert weiterhin die
Eigenschaft `Layout`, das Symbol die Eigenschaft `Icon`.

`tools/validate_pa_yaml.py` prueft Varianten seitdem mit – gegen die
Erlaubtliste fuer `GroupContainer` und gegen das Kleinschreibungs-Merkmal fuer
alle uebrigen Controls. Ein Gegentest mit der alten Fassung meldet
erwartungsgemaess 55 Fehler.

> Sollte Studio zu `Gallery` oder `Classic/Icon` doch noch eine Variante
> verlangen, nennt die Fehlermeldung – wie oben – die gueltigen Alternativen.
> Diese lassen sich dann in `ERLAUBTE_VARIANTEN` im Pruefwerkzeug eintragen.

### A1c – Controls und Eigenschaften (zweiter Tenant-Befund)

Der zweite Einfuegeversuch lieferte rund 270 Meldungen in drei Gruppen. Sie
sind alle behoben; die Auswertung ist festgehalten, weil sie die
Control-Auswahl der App begruendet.

> **Zur Zeilennummerierung:** Studio zaehlt ab der ersten Inhaltszeile, nicht
> ab dem Kommentarkopf. Beim damaligen Stand lag der Versatz bei 21 Zeilen
> (Studio-Zeile 10 = Dateizeile 31). Ohne diese Umrechnung zeigen die
> Fehlerstellen auf die falschen Steuerelemente.

**Gruppe 1 – `LayoutMode` (55x, PA2108)**

```
Unknown property 'LayoutMode' for control type 'GroupContainer'
and variant 'AutoLayout'.
```

Die Variante `AutoLayout` legt den Layoutmodus bereits fest; die Eigenschaft
ist daneben nicht zulaessig. Ersatzlos entfernt – die Richtung steht
unveraendert in `LayoutDirection`.

**Gruppe 2 – `Variant` bei Galerien (7x, PA1011)**

```
The keyword 'Variant' is required but is missing or empty.
```

Alle sieben Fundstellen waren die sieben Galerien. Im Schritt davor hatte ich
deren Variante entfernt, weil der gueltige Name nicht belegt war – fuer
`Gallery` ist sie aber **Pflicht**. `Classic/Icon` stand in derselben Liste
nicht: dort ist die Variante optional, das Entfernen war dort richtig.

**Gruppe 3 – klassische Eigenschaften an modernen Controls (ca. 210x, PA2108)**

```
Unknown property 'Fill'   for control type 'Button'.
Unknown property 'Default' for control type 'TextInput'.
Unknown property 'Text'   for control type 'CheckBox'.
```

Der entscheidende Befund. Die **blanken** Namen `Button`, `TextInput`,
`DropDown`, `DatePicker` und `CheckBox` loesen in dieser Umgebung auf die
**modernen** Controls auf. Deren Eigenschaftssatz ist ein anderer:
`Fill`, `Color`, `HoverFill`, `PressedFill`, `Size`, `Radius*`, `Default`,
`HintText`, `Reset`, `DelayOutput`, `DefaultDate`, `StartYear` existieren dort
nicht.

Nicht beanstandet wurden dagegen `Label`, `Rectangle`, `Classic/Icon`,
`GroupContainer` und die Eigenschaften der Galerien. `Label` behaelt also
`Size`, `Color` und `Fill` – die blanken Namen sind **nicht** einheitlich
modern.

**Loesung:** Die fuenf Eingabe-Controls auf den klassischen Namensraum
umgestellt. `Classic/Icon` war fehlerfrei durchgelaufen und belegt, dass es
den Namensraum gibt; die klassischen Controls haben genau den
Eigenschaftssatz, gegen den die App geschrieben ist. Es musste deshalb
**keine einzige Eigenschaft** umgeschrieben werden.

| Control | vorher | jetzt | Anzahl |
|---|---|---|---|
| Schaltflaeche | `Button` | `Classic/Button` | 31 |
| Eingabefeld | `TextInput` | `Classic/TextInput` | 25 |
| Auswahlliste | `DropDown` | `Classic/DropDown` | 5 |
| Datumsauswahl | `DatePicker` | `Classic/DatePicker` | 3 |
| Kontrollkaestchen | `CheckBox` | `Classic/CheckBox` | 3 |

> **Warum nicht die modernen Controls?** Die Microsoft-Dokumentation zu den
> modernen Controls fuehrt `Size`, `Color` und `RadiusTopLeft` als gueltige
> Eigenschaften des modernen Button – Ihre Umgebung lehnt sie ab. Die Doku
> beschreibt also eine **neuere Controlversion**, als der Tenant ausliefert.
> Ein Umschreiben auf moderne Eigenschaftsnamen waere damit gegen eine
> Version erfolgt, die hier niemand sehen kann. Die klassischen Controls sind
> versionsstabil und liefern die geplante Gestaltung (eigene Fuellfarben,
> Hover- und Pressed-Zustaende, Eckenradien) unveraendert.

**Verbleibendes Risiko:** Der Variantenname `Vertical` fuer `Gallery` ist
nicht belegt. Er ist die naheliegende Entsprechung zu
`GridLayout`/`AutoLayout`/`ManualLayout` beim Container. Ist er falsch, nennt
Studio – wie bei `GroupContainer` geschehen – die gueltigen Alternativen in
der Meldung. Moeglich ist ausserdem, dass Studio die Eigenschaften der
Galerien beim letzten Lauf gar nicht geprueft hat, weil die Variante fehlte.

**Aufgenommen in `tools/validate_pa_yaml.py`:** Variantenpflicht je
Control-Typ, verbotene Eigenschaften je Control-Variante-Kombination und die
Erkennung klassischer Eigenschaften an modernen Controls samt Hinweis auf
`Classic/<Name>`. Der Gegentest mit je einem kuenstlich eingebauten Fehler
meldet alle drei Gruppen.

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
