# Spalten von Hand anlegen

Etwa zehn Minuten. Kein PowerShell nötig.

> **Wichtig zur Schreibweise:** Legen Sie die Spalten **genau so** an, wie sie
> hier stehen – ohne Leerzeichen, ohne Umlaute. `Massnahmen`, nicht
> „Maßnahmen". Grund: SharePoint baut aus dem Namen, den Sie beim **Anlegen**
> eingeben, den internen Namen. Ein „ß" würde dort zu `_x00df_`, ein Leerzeichen
> zu `_x0020_` – schwer lesbar und in Power Automate eine Fehlerquelle.
>
> Den **Anzeigenamen** können Sie hinterher jederzeit auf „Maßnahmen" ändern.
> Dann müssten Sie allerdings auch die Formeln anpassen, weil Power Fx den
> Anzeigenamen verwendet. Fürs Erste: so lassen.

---

## Liste „Behandlungsdokumentation"

Liste öffnen → rechts **+ Spalte hinzufügen** → Typ wählen → Name eintragen →
**Speichern**.

| Name genau so eingeben | Typ in SharePoint | Wofür |
|---|---|---|
| `PatientID` | **Zahl** | Verbindet die Dokumentation mit dem Patienten. Trägt die Terminzählung, den Verlauf und die Heute-Liste. |
| `RezeptID` | **Zahl** | Bezug zum Rezept. Bleibt leer, wenn keines hinterlegt ist. |
| `Behandlungsdatum` | **Datum und Uhrzeit** → Anzeige **Nur Datum** | Für die Heute-Liste und den Verlauf. |
| `Massnahmen` | **Mehrere Textzeilen** | Durchgeführte Maßnahmen. |
| `Reaktion` | **Mehrere Textzeilen** | Reaktion und Ergebnis. |
| `Heimuebungen` | **Mehrere Textzeilen** | Freiwillig. |

**`Therapeut` prüfen, nicht neu anlegen.** Diese Spalte gibt es bei Ihnen
vermutlich schon, als **Auswahl** mit dem Wert `Alex`. Die App liest die
hinterlegten Werte automatisch mit `Choices()` – weitere Physios tragen Sie
einfach direkt an dieser Spalte in SharePoint nach.

Fehlt sie doch: **Auswahl**, Name `Therapeut`, und die Namen der Physios als
Werte eintragen.

### Bei „Mehrere Textzeilen" beachten

SharePoint bietet dabei **„Erweiterten Text verwenden"** an. Stellen Sie das
auf **Nein** – die App schreibt reinen Text. Mit Rich-Text stünden später
HTML-Schnipsel in der Dokumentation.

---

## Liste „Rezepte"

| Name genau so eingeben | Typ in SharePoint | Wofür |
|---|---|---|
| `PatientID` | **Zahl** | Ordnet das Rezept einem Patienten zu. |
| `Erstbefund` | **Mehrere Textzeilen** | Wird in der Vorbereitung als Befund angezeigt. |
| `Anamnese` | **Mehrere Textzeilen** | Wird in der Vorbereitung angezeigt. |

**`Diagnose laut Rezept` prüfen, nicht neu anlegen.** Die gibt es laut Ihren
Unterlagen bereits – intern heißt sie `DiagnoselautRezept`. Legen Sie auf
keinen Fall eine zweite Spalte „Diagnose" an.

---

## Danach: Datenquellen aktualisieren

**Das ist der Schritt, den man leicht übersieht.**

In Power Apps Studio:

1. Links auf **Daten**.
2. Bei `Behandlungsdokumentation` auf **…** → **Aktualisieren**.
3. Dasselbe bei `Rezepte`.

Erst jetzt kennt Studio die neuen Spalten. Die roten Unterringelungen
verschwinden – ohne dass Sie eine Formel angefasst haben.

Bleiben einzelne stehen: Studio einmal schließen und die App neu öffnen. Das
Schema wird zwischengespeichert.

---

## Schnell prüfen, ob alles sitzt

| Prüfung | Erwartet |
|---|---|
| App-Prüfung öffnen | keine Fehler mehr |
| Vorschau → Patient auswählen | Vorbereitung zeigt „1." als Terminnummer |
| Befundkarte | entweder Diagnose und Befund, oder der Hinweis „kein Rezept hinterlegt" |
| „Wer behandelt?" | Auswahlliste zeigt Ihre Therapeutennamen |
| Behandlung speichern | grüne Meldung, Eintrag steht in „Heute" |
| Denselben Patienten erneut aufrufen | Terminnummer ist „2.", Eintrag steht unter „Bisherige Dokumentationen" |

---

## Warum `PatientID` und nicht die vorhandene Spalte `Patient`

In Ihrer Dokumentationsliste gibt es laut den Unterlagen bereits eine Spalte
`Patient`. Deren **Typ ist aber nicht belegt** – Einfachauswahl,
Mehrfachauswahl, Nachschlagefeld auf welche Liste? Das steht nirgends fest.

In eine Spalte zu schreiben, deren Typ man nicht kennt, ist geraten. Eine
Zahlenspalte mit der SharePoint-ID ist dagegen eindeutig und entspricht dem,
was in Ihren Unterlagen als technische Beziehung festgehalten ist.

`Patient` bleibt dabei unangetastet. Falls sich später herausstellt, dass es
ein sauberes Nachschlagefeld ist, lässt sich die App in zwei Formeln
umstellen – die Daten gehen dabei nicht verloren.
