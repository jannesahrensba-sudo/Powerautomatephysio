# Power Automate einrichten

## Was diese Dateien sind - und was nicht

In diesem Ordner liegen vier **Referenzdefinitionen** im Format, das Power
Automate unter *Code anzeigen* (Peek code) verwendet.

> **Sie sind kein geprüftes Importpaket.** Sie wurden nicht in einen Tenant
> importiert und nicht ausgeführt. Es gab in dieser Arbeitsumgebung keinen
> Zugang zu einer Power-Platform-Umgebung. Ein ZIP, das man „fertiger Flow"
> nennt, ohne es je importiert zu haben, wäre eine Behauptung ohne Deckung.

Der belastbare Weg ist deshalb: **Flow nach der Anleitung unten bauen, danach
über *Code anzeigen* mit der Referenzdefinition vergleichen.** Die Ausdrücke
lassen sich von dort direkt kopieren.

## Reihenfolge

| # | Schritt | Warum zuerst |
|---|---|---|
| 1 | `04_Setup/Pruefe-Schema.ps1` | Ohne die echten **internen** Spaltennamen sind alle Filter unten Raten. |
| 2 | `04_Setup/Ergaenze-Schema.ps1` | Zählerspalten und Indizes müssen existieren. |
| 3 | `Ergaenze-Schema.ps1 -StandardwertMailGesendetamEntfernen` | Sonst verschickt Flow 4 nie etwas (siehe unten). |
| 4 | Flow 1 (Zähler) | Alle anderen Flows rechnen mit seinen Ergebnissen. |
| 5 | Flow 2 (Aufgaben) | |
| 6 | Flow 3 (Vortag), Flow 4 (Versand) | Beide sind im Auslieferungszustand aus. |

## Verbindungen

| Connector | Wofür | In welchen Flows |
|---|---|---|
| **SharePoint** | Listen lesen und schreiben | 1, 2, 3, 4 |
| **Office 365 Outlook** | Benachrichtigung senden | nur 4 |

Das Konto der SharePoint-Verbindung braucht **Bearbeiten**-Rechte auf allen
vier Listen. Verwenden Sie ein Dienstkonto, kein persönliches Konto: Sonst
stehen später sämtliche Zählerstände unter dem Namen einer einzelnen Person,
und der Flow fällt aus, sobald diese Person das Unternehmen verlässt.

Vor dem Bau in allen Definitionen ersetzen:
`https://IHRE-SHAREPOINT-ADRESSE/sites/Praxis` → Ihre tatsächliche Adresse.

---

## Flow 1 - Rezeptzähler

**Zweck:** Nach jeder Änderung an einer Dokumentationszeile die Zähler des
zugehörigen Rezepts **vollständig neu** berechnen.

**Auslöser:** SharePoint – *Wenn ein Element erstellt oder geändert wird*,
Liste `Behandlungsdokumentation`.

Danach am Auslöser **Einstellungen → Parallelitätssteuerung → Ein,
Grad der Parallelität = 1** setzen.

> Das ist der wichtigste Schalter im ganzen Aufbau. Er macht diesen Flow zum
> **einzigen Schreiber** der Rezeptzähler. Ohne ihn können zwei gleichzeitig
> laufende Instanzen denselben Zähler mit unterschiedlichen Zwischenständen
> überschreiben – und der falsche gewinnt.

**Aktionen:**

1. **Verfassen** `RezeptID_ermitteln`
   ```
   @triggerOutputs()?['body/RezeptID']
   ```
2. **Bedingung** `Nur_weiter_wenn_ein_Rezept_zugeordnet_ist` – ist keine
   RezeptID gesetzt, im *Andernfalls*-Zweig **Beenden** mit Status
   *Erfolgreich*. Eine Zeile ohne Rezept ist kein Fehler; sie kann nur nichts
   verbrauchen.
3. **Elemente abrufen** `Durchgefuehrte_Zeilen_des_Rezepts_holen`
   - Filterabfrage:
     ```
     @concat('RezeptID eq ', string(outputs('RezeptID_ermitteln')), ' and Terminstatus eq ''Durchgeführt''')
     ```
   - Sortieren nach: `Behandlungsdatum desc`
   - **Einstellungen → Paginierung → Ein, Schwellenwert 5000**

   > Ohne Paginierung liefert die Aktion höchstens 100 Zeilen. Bei einem
   > langen Rezept wäre der Zähler dann zu niedrig – und niemand würde es
   > bemerken, weil der Flow trotzdem grün durchläuft.

   Nur `Durchgeführt` zählt. Geplant, Abgesagt, Nicht erschienen und
   Storniert verbrauchen keine Einheiten.
4. **Auswählen** `Behandlungsmengen_auswaehlen`
   - Von: `@body('Durchgefuehrte_Zeilen_des_Rezepts_holen')?['value']`
   - Zuordnen (Textmodus, einspaltig):
     ```
     @float(coalesce(item()?['Einheiten'], 0))
     ```
   > `Einheiten` ist der **interne** Name. In der App heißt dieselbe Spalte
   > `AltEinheiten`. Siehe `03_Datenmodell.md`, Befund 3.
5. **Verfassen** `EinheitenApp_summieren`
   ```
   @if(empty(body('Behandlungsmengen_auswaehlen')), 0, float(xpath(xml(json(concat('{"root":{"w":', string(body('Behandlungsmengen_auswaehlen')), '}}'))), 'sum(/root/w)')))
   ```
   > Power Automate kennt keine Summenfunktion. Die Zahlenliste wird deshalb
   > kurz als XML dargestellt, weil XPath ein `sum()` hat. Das ist schneller
   > und robuster als eine Schleife mit Variablen.
6. **Element abrufen** `Rezept_holen` – Liste `Rezepte`, ID =
   `@outputs('RezeptID_ermitteln')`
7. **Verfassen** `Letzter_durchgefuehrter_Termin`,
   `Inaktive_Tage_berechnen`, `Offene_Einheiten_berechnen` – Ausdrücke
   wörtlich aus `01_Zaehler_Rezept.definition.json`.
8. **HTTP-Anforderung an SharePoint senden**
   `Nur_die_Zaehlerfelder_des_Rezepts_aktualisieren`

   > Hier **nicht** die Aktion *Element aktualisieren* verwenden. Die schreibt
   > alle Felder zurück. Ändert eine Kollegin im selben Moment die Diagnose,
   > wäre diese Änderung weg. `MERGE` schreibt ausschließlich die aufgeführten
   > Felder.

   - Methode `POST`
   - URI: `@concat('_api/web/lists/getByTitle(''Rezepte'')/items(', string(outputs('RezeptID_ermitteln')), ')')`
   - Header: `Content-Type: application/json;odata=nometadata`,
     `Accept: application/json;odata=nometadata`, `IF-MATCH: *`,
     `X-HTTP-Method: MERGE`
   - Body: Ausdruck aus der Definitionsdatei.

   > `odata=nometadata` erspart den `__metadata`-Typnamen der Liste. Der wäre
   > sonst zu erraten und bricht bei umbenannten Listen.

---

## Flow 2 - Aufgaben täglich

**Zweck:** Erinnerungen als Aufgaben anlegen. Dieser Flow verschickt nichts.

**Auslöser:** Wiederholung, täglich 06:00, Zeitzone
**`W. Europe Standard Time`** (= Europe/Berlin). Die Sommerzeitumstellung
erledigt die Zeitzone selbst.

**Die drei Regeln:**

| Regel | Bedingung | Ereignisschlüssel |
|---|---|---|
| Restschwelle | `Offen <= Restschwelle` und `Offen > 0` | `Rest-<RezeptID>-<Schwelle>` |
| Inaktivität | `InaktivTage >= InaktivTage-Schwelle` und `Offen > 0` | `Inaktiv-<RezeptID>-<Schwelle>` |
| Abrechnung | `Erbracht >= Abrechnungsschwelle` | `Abrechnung-<RezeptID>-<Erbracht div Schwelle>` |

Jede Regel sucht **vor** dem Anlegen nach ihrem Ereignisschlüssel und legt
nur an, wenn es keinen Treffer gibt. Dadurch entsteht je Ereignis genau eine
Aufgabe, egal wie oft der Flow läuft. Die Suche ignoriert den
Aufgabenstatus – eine bereits **erledigte** Aufgabe wird deshalb nicht erneut
angelegt.

Wichtige Eigenschaften dieses Flows:

- **Pausierte Rezepte** werden gar nicht erst geladen (`Rezeptstatus eq 'Aktiv'`).
- **Rezepte ohne `ZaehlerStand`** werden übersprungen. Ein nicht berechneter
  Zähler darf nicht wie „0 offen" behandelt werden – sonst entstünden
  Erinnerungen aus dem Nichts.
- Die Schleife läuft mit **Parallelität 1**. Sonst könnten zwei Durchläufe
  denselben Ereignisschlüssel gleichzeitig als „noch nicht vorhanden"
  bewerten und zwei Aufgaben anlegen.
- Am Ende werden **hinfällige Restschwellen-Aufgaben** als `NichtAktuell`
  gekennzeichnet – nicht gelöscht. So bleibt nachvollziehbar, dass es sie gab.
- Fehlt die Einstellungszeile, greifen die Standardwerte 1 / 21 / 5. Der Flow
  fällt deshalb nicht aus.

---

## Flow 3 - Vortagserinnerung

**Zweck:** Einen Tag vor der voraussichtlich letzten geplanten Behandlung
erinnern.

**Im Auslieferungszustand aus** (`VortagAktiv` = nein).

> **Diese Regel braucht eine gepflegte Terminplanung.** Sie wertet
> Dokumentationszeilen mit `Terminstatus = Geplant` und künftigem
> `Behandlungsdatum` aus. Solange die Praxis keine Termine im Voraus erfasst,
> findet der Flow nichts und legt nichts an. Das ist beabsichtigt: Ohne
> belastbare Planung wäre jede Vorhersage geraten.

So rechnet er:

1. Geplante Termine des Rezepts aufsteigend nach Datum laden.
2. Zu jedem Termin die **Laufsumme** der Einheiten bis einschließlich dieses
   Termins bilden – ein Termin kann mehrere Einheiten umfassen.
3. Der erste Termin, dessen Laufsumme die offenen Einheiten erreicht, ist die
   voraussichtlich letzte Behandlung.
4. Ist das **morgen**, entsteht eine Aufgabe.

Der Ereignisschlüssel enthält dieses Datum (`Vortag-<RezeptID>-<Datum>`).
Wird der Termin **verschoben**, ergibt der nächste Lauf ein anderes Datum und
damit einen neuen Schlüssel – die Erinnerung kommt dann zum richtigen neuen
Termin, und die alte bleibt als Historie stehen.

> Das ist eine **Schätzung aus der aktuellen Planung**, kein berechnetes
> rechtliches Ablaufdatum eines Rezepts. Der Aufgabentext sagt das auch so.

Die Laufsumme kommt ohne Variablen und ohne verschachtelte Schleife aus
(`range` + `take` + XPath-`sum`). Variablen in verschachtelten Schleifen sind
in Power Automate eine bekannte Fehlerquelle, weil sie flowweit gelten und
nicht je Durchlauf.

---

## Flow 4 - Versand

**Zweck:** Die offenen, noch nicht zugestellten Aufgaben als **eine**
Sammel-Mail an die interne Adresse schicken.

**Im Auslieferungszustand aus** (`VerandAktiv` = nein).

> **Achtung, interner Name:** Der Schalter heißt intern **`VerandAktiv`** –
> mit dem Tippfehler aus dem Bestand. Angezeigt wird `VersandAktiv`. In
> Power Automate zwingend `VerandAktiv` verwenden.

> **Voraussetzung:** `MailGesendetam` hat laut Befund 9 fälschlich einen
> heutigen Standardwert. Solange der gesetzt ist, sieht **jede neu angelegte
> Aufgabe aus wie bereits verschickt**, und es geht nie eine Mail hinaus.
> Einmalig ausführen:
> ```powershell
> .\Ergaenze-Schema.ps1 -SiteUrl "<...>" -StandardwertMailGesendetamEntfernen
> ```
> Der Flow erkennt diesen Zustand und bricht mit einer klaren Meldung ab,
> statt stillzuschweigen.

Reihenfolge im Flow – und warum sie so ist:

1. Versandschalter prüfen, sonst beenden (Erfolg, kein Fehler).
2. Empfängeradresse prüfen, sonst Fehler.
   > Eine hinterlegte Adresse allein ist **kein** Nachweis einer aktiven
   > Versandverbindung. Beides muss stimmen.
3. Aufgaben mit leerem `MailGesendetam` laden.
4. Mail senden.
5. **Erst danach** `MailGesendetam` setzen – gezielt per `MERGE`, nur dieses
   eine Feld.

   > Schlägt der Versand fehl, wird `MailGesendetam` **nicht** gesetzt. Die
   > Aufgaben bleiben damit in der Warteschlange und werden beim nächsten Lauf
   > erneut zugestellt. Genau deshalb steht das Kennzeichnen nach dem Senden
   > und nicht davor.

---

## Rezeptfoto und Anlagen - ehrlicher Stand

**Dieses Modul ist nicht gebaut.** Die App weist an der entsprechenden Stelle
ausdrücklich darauf hin, statt ein wirkungsloses Feld anzuzeigen.

Der Grund ist keine Bequemlichkeit, sondern eine Eigenschaft der Plattform:
Das **Anlagen**-Steuerelement in Canvas Apps funktioniert nur innerhalb eines
**Formulars**, das an eine Datenquelle gebunden ist. Ein Formular mit
Datenkarten setzt jedoch die exakten internen Feldnamen der Liste `Rezepte`
voraus – und die sind bisher nicht belegt (siehe `03_Datenmodell.md`). Ein
geratenes Formular hätte nach dem Einfügen fehlerhafte Datenkarten.

Zwei tragfähige Wege, sobald der Schemabericht vorliegt:

**Weg A – Formular mit Anlagen-Datenkarte (ohne Flow).**
Ein `Form`-Steuerelement auf `Rezepte` einfügen, alle Datenkarten bis auf die
Anlagen-Karte ausblenden, `Item` auf `gblRezept` setzen. Das ist der
einfachste Weg und braucht keinen Flow. Einschränkungen der
Anlagensteuerung auf Mobilgeräten vorher prüfen.

**Weg B – Bild aufnehmen und per Flow anhängen.**
Ein `AddMedia`-Steuerelement liefert das Bild; ein Flow mit
*Anlage hinzufügen* hängt es an das Rezept. Dafür ist in der App eine Zeile
nötig, die erst nach dem Hinzufügen des Flows eingetragen werden kann:

```powerfx
'Rezeptfoto-anhaengen'.Run(gblRezept.ID, JSON(addMediaRezeptfoto.Image, JSONFormat.IncludeBinaryData))
```

> Diese Zeile steht bewusst **nicht** im ausgelieferten Code: Ein Verweis auf
> einen Flow, der in der App noch nicht hinzugefügt ist, erzeugt beim
> Einfügen einen Formelfehler.

Empfehlung: **Weg A**, sobald die Feldnamen bestätigt sind. Er hat weniger
bewegliche Teile.

---

## Was diese Flows bewusst nicht tun

- **Keine Rechnung und keine Zahlung auslösen.** Der Abrechnungshinweis ist
  ein Hinweis an die Praxis, mehr nicht.
- **Keine Einheit wegen Abwesenheit abziehen.** Inaktivität erhöht nur
  `InaktivTage`.
- **Kein rechtliches Ablaufdatum eines Rezepts berechnen.**
- **Keine Zähler hochzählen.** Es wird bei jedem Lauf vollständig neu aus den
  tatsächlichen Zeilen gerechnet. Deshalb erzeugt wiederholtes Speichern
  derselben Zeile auch keine zusätzliche Einheit.
- **Keine Aufgaben löschen.** Hinfällige Aufgaben werden gekennzeichnet.
- **Den Dokumentenlink nicht schreiben.** Den setzt der bestehende
  Exportprozess. Doppelte Ablage wird so vermieden.

## Verbleibende Transaktionsgrenzen

Zwischen „Doku-Zeile gespeichert" und „Rezeptzähler aktualisiert" liegt der
Flow-Lauf. In dieser Spanne ist der angezeigte Stand **veraltet, nicht
falsch** – die App kennzeichnet ihn als „wird neu berechnet".

Es gibt keine Transaktion über beide Listen hinweg. Bricht der Flow beim
Schreiben ab, bleibt der letzte gültige `ZaehlerStand` stehen; die App zeigt
ihn weiterhin als veraltet an und behauptet an keiner Stelle „0 offen".
Genau das ist die gewünschte Eigenschaft: **Eine fehlende Berechnung darf
nicht wie ein berechnetes Ergebnis aussehen.**
