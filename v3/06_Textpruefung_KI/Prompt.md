# Der Prompt

Der Prompt ist die eigentliche Arbeit an diesem Zusatz. Ein allgemein
gehaltener „korrigiere diesen Text" macht bei Fachsprache mehr kaputt als er
repariert: Er schreibt `Flex 90°` zu „Flexion von etwa 90 Grad" um, glättet
`li.` weg oder macht aus einer knappen Notiz einen ausformulierten Absatz.

In einer Behandlungsdokumentation ist das kein Stilgewinn, sondern eine
Veränderung am Rechtsdokument.

Deshalb ist der Prompt eng geführt:

```text
Du korrigierst Texte aus einer physiotherapeutischen
Behandlungsdokumentation.

Korrigiere ausschliesslich:
- Rechtschreibung
- Grammatik
- Zeichensetzung
- offensichtliche Tippfehler

Aendere NICHT:
- Fachbegriffe und Abkuerzungen (KG, MT, MLD, ISG, HWS, LWS, Flex, Ext)
- Zahlen, Gradangaben, Messwerte, Wiederholungszahlen
- Seitenangaben (links, rechts, li., re., bds.)
- den Stil, die Laenge oder den Satzbau
- die Reihenfolge der Angaben

Ergaenze nichts. Erfinde nichts. Wenn ein Text bereits korrekt ist,
gib ihn unveraendert zurueck. Wenn ein Text leer ist, gib einen
leeren String zurueck.

Antworte ausschliesslich mit diesem JSON, ohne Erklaerung und ohne
Codeblock:
{"massnahmen":"...","reaktion":"...","heim":"..."}

Zu korrigieren:
massnahmen: @{triggerBody()['text']}
reaktion: @{triggerBody()['text_1']}
heim: @{triggerBody()['text_2']}
```

Die `@{triggerBody()...}`-Ausdrücke sind Platzhalter. In Power Automate fügen
Sie an diesen Stellen über den Inhaltsauswahldialog die drei Eingaben des
Triggers ein – tippen Sie die Ausdrücke nicht ab, die Indizes stimmen sonst
nicht.

---

## Warum JSON als Antwortformat

Weil so **ein** Aufruf alle drei Felder abdeckt. Drei getrennte Aufrufe
wären dreimal Wartezeit und dreimal Credits.

Modelle halten sich nicht immer an „nur JSON". Der Flow ist deshalb so
gebaut, dass er bei unlesbarer Antwort einen leeren Vorschlag zurückgibt,
statt den Fehler in die App zu tragen – siehe `Flow_bauen.md`, Schritt 4.

---

## Wenn die Vorschläge zu stark eingreifen

Verschärfen Sie die Verbotsliste um die Begriffe, die bei Ihnen vorkommen.
Die Liste oben ist ein Anfang, keine vollständige Sammlung – ergänzen Sie
Ihre eigenen Abkürzungen.

Umgekehrt: Wenn zu wenig korrigiert wird, ist meist nicht der Prompt schuld,
sondern der Text war schon in Ordnung.
