# Den Flow bauen

Vier Aktionen, etwa 20 Minuten. Name des Flows: **`Doku_Korrektur`**
(genau so – die App ruft ihn unter diesem Namen auf).

> Die Aktionsnamen unten sind aus der Erinnerung beschrieben. Microsoft
> benennt die AI-Builder-Aktionen gelegentlich um, und je nach Region und
> Lizenz steht eine andere Auswahl bereit. Wo der Name abweicht, steht
> daneben, wonach Sie suchen.

---

## Schritt 1 – Flow anlegen

**make.powerautomate.com → Erstellen → Sofortiger Cloud-Flow**

- Name: `Doku_Korrektur`
- Trigger: **PowerApps (V2)**

Nicht „PowerApps" ohne V2 nehmen – nur V2 erlaubt benannte Eingaben.

## Schritt 2 – Drei Texteingaben am Trigger

Am Trigger **+ Eingabe hinzufügen → Text**, dreimal:

| Reihenfolge | Name |
|---|---|
| 1 | `Massnahmen` |
| 2 | `Reaktion` |
| 3 | `Heimuebungen` |

**Die Reihenfolge ist bindend.** Die App übergibt die drei Texte in genau
dieser Folge; vertauscht man sie, landet die Reaktion im Maßnahmenfeld.

## Schritt 3 – Die KI-Aktion

**Neuer Schritt** → suchen Sie nach **`AI Builder`**.

Sie brauchen eine Aktion, die einen frei formulierten Auftrag entgegennimmt.
Je nach Tenant heißt sie:

- **„Text mit GPT erstellen"** / „Create text with GPT" – nimmt die
  Anweisung direkt im Flow entgegen. **Nehmen Sie diese, wenn vorhanden.**
- **„Prompt ausführen"** / „Run a prompt" – verlangt, dass der Prompt vorher
  im **AI Hub → Prompts** angelegt wurde. Dann legen Sie ihn dort mit dem
  Text aus `Prompt.md` an und wählen ihn hier aus.

In das Anweisungsfeld kommt der komplette Text aus **`Prompt.md`**. Für die
drei Platzhalter am Ende setzen Sie über den Inhaltsauswahldialog rechts die
Trigger-Eingaben `Massnahmen`, `Reaktion` und `Heimuebungen` ein.

> Erscheint keine AI-Builder-Aktion, fehlt die Lizenz oder AI Builder ist in
> dieser Region nicht verfügbar. Das ist kein Fehler im Flow.

## Schritt 4 – Antwort lesen, aber vorsichtig

**Neuer Schritt → Variable initialisieren**

| Feld | Wert |
|---|---|
| Name | `Ergebnis` |
| Typ | Objekt |
| Wert | `{"massnahmen":"","reaktion":"","heim":""}` |

**Neuer Schritt → Bereich (Scope)**, darin **Variable festlegen**:

| Feld | Wert |
|---|---|
| Name | `Ergebnis` |
| Wert | `json(outputs('Text_mit_GPT_erstellen')?['body/responsev2/predictionOutput/text'])` |

Den Ausdruck in den Aktionsnamen Ihres Schritts 3 anpassen – am einfachsten
über den Inhaltsauswahldialog die Textausgabe wählen und `json(...)`
darumlegen.

**Am Bereich dann:** „…" → **Konfigurieren nach Ausführung** → zusätzlich
**„ist fehlgeschlagen"** ankreuzen und den nachfolgenden Schritt trotzdem
laufen lassen.

Das ist der eigentliche Zweck dieses Schrittes: **Antwortet das Modell
einmal kein sauberes JSON, bleibt `Ergebnis` leer, statt den ganzen Flow
scheitern zu lassen.** Die App zeigt dann „kein Vorschlag" – und der
Therapeut arbeitet normal weiter.

## Schritt 5 – Antwort an die App

**Neuer Schritt → „Auf eine PowerApp oder einen Flow antworten"**

Drei Textausgaben, wieder in fester Reihenfolge:

| Reihenfolge | Name | Wert |
|---|---|---|
| 1 | `massnahmen` | `variables('Ergebnis')?['massnahmen']` |
| 2 | `reaktion` | `variables('Ergebnis')?['reaktion']` |
| 3 | `heim` | `variables('Ergebnis')?['heim']` |

Speichern.

---

## Testen, bevor die App drankommt

In Power Automate **Testen → Manuell** und diese drei Texte eingeben:

| Eingabe | Text |
|---|---|
| Massnahmen | `Manuele Terapie HWS, Traktion li. 3x15` |
| Reaktion | `gut vertragn, Bewglichkeit besser` |
| Heimuebungen | *(leer lassen)* |

**Erwartet:** Tippfehler korrigiert (`Manuelle Therapie`, `vertragen`,
`Beweglichkeit`), aber `HWS`, `li.` und `3x15` **unverändert**, und `heim`
kommt leer zurück.

Verändert der Flow `li.` oder `3x15`, schärfen Sie den Prompt nach, bevor Sie
ihn an die App hängen. Ein Flow, der Messwerte umschreibt, gehört nicht an
eine Behandlungsdokumentation.

---

## Erst dann: die App verbinden

Weiter mit **`Einbau_DE.md`** (oder `_EN.md`).
