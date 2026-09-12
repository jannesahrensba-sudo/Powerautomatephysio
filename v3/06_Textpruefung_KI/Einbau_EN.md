# Einbau in die App (EN)

> **For a Studio with INVARIANT / ENGLISH separators.** Arguments with `,`,
> statements with `;`. If your Studio runs in German, use
> `Einbau_DE.md` instead.

**Voraussetzung:** Der Flow `Doku_Korrektur` ist gebaut und getestet – siehe
`Flow_bauen.md`. Ohne ihn meldet die App an `btnKIPruefen` einen Fehler.

---

## Schritt 1 – Flow mit der App verbinden

In Power Apps Studio: **Power Automate → Flow hinzufügen → `Doku_Korrektur`**.

Erscheint er nicht in der Liste, liegt er in einer anderen Umgebung als die
App. Beides muss in derselben Umgebung liegen.

## Schritt 2 – Zwei Zeilen in `App.OnStart`

An das Ende der bestehenden `App.OnStart` anhängen:

```powerfx
Set(gblKIlaeuft, false);
Set(gblKIfehler, "");
```

`gblKorrektur` gehört **nicht** dazu. Sie ist ein Datensatz, kein Text – ein
`Set(gblKorrektur, "")` würde sie zu Text machen und jeden Zugriff wie
`gblKorrektur.massnahmen` unmöglich machen. Eine nie gesetzte Variable ist in
Power Apps bereits leer; genau darauf prüft `Visible: =!IsBlank(gblKorrektur)`.

## Schritt 3 – Steuerelemente einfügen

1. Im Baum **`conDoku`** auswählen.
2. Rechtsklick → **Code einfügen**.
3. Vollständigen Inhalt von **`Zusatz_Controls.yaml`** einfügen.

Die 13 neuen Elemente landen am Ende von `conDoku`. Ziehen Sie
**`conDokuAktionen`** im Baum wieder ganz nach unten, damit „Behandlung
speichern" unter dem Vorschlag steht und nicht darüber.

Reihenfolge danach:

```
conDoku
├── conDokuKopf
├── lblFeldMassnahmen / txtMassnahmen / drpBausteinM / lblLaengeM
├── lblFeldReaktion   / txtReaktion   / drpBausteinR / lblLaengeR
├── lblFeldHeim       / txtHeim
├── btnKIPruefen          ← neu
├── conKI                 ← neu
└── conDokuAktionen       ← nach unten ziehen
```

## Schritt 4 – Durchspielen

| Prüfung | Erwartet |
|---|---|
| Beide Pflichtfelder leer | „Text prüfen" ist grau |
| Text mit Tippfehlern eintragen, „Text prüfen" | Schaltfläche zeigt „Prüft ...", danach erscheint der Vorschlagskasten |
| „Maßnahmen übernehmen" | Nur das Maßnahmenfeld wird ersetzt, Reaktion bleibt stehen |
| „Alle übernehmen" | Beide Felder ersetzt, Kasten verschwindet |
| „Verwerfen" | Kasten verschwindet, Felder unverändert |
| Flow deaktivieren, dann „Text prüfen" | Gelbe Meldung, **Speichern funktioniert weiter** |

Die letzte Zeile ist die wichtigste. Eine ausgefallene Rechtschreibprüfung
darf niemanden daran hindern, seine Behandlung zu dokumentieren.

---

## Wieder ausbauen

1. `btnKIPruefen` und `conKI` im Baum löschen.
2. Die zwei Zeilen aus `App.OnStart` entfernen.
3. **Power Automate → `Doku_Korrektur` → Entfernen.**

Die Textbausteine und die Längenprüfung bleiben davon unberührt – sie gehören
zu V3 und brauchen weder Flow noch Lizenz.

---

## Warum der Einbau so klein ist

Weil V3 die Mechanik schon hat. Die Textbausteine setzen den Text über
`gblTxtM` / `gblTxtR` und lösen dann einen gezielten Reset aus. Das
Übernehmen eines KI-Vorschlags ist derselbe Vorgang mit einer anderen
Textquelle:

```powerfx
Set(gblTxtM, gblKorrektur.massnahmen);
Set(gblResetM, true); Set(gblResetM, false)
```

Deshalb war Weg B zuerst richtig – er hat die Verkabelung gelegt, die dieser
Zusatz mitbenutzt.
