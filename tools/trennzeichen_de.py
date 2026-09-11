#!/usr/bin/env python3
"""
Wandelt Power-Fx-Formeln von invarianten (englischen) Trennzeichen in die
deutsche Schreibweise um.

Regeln in Sprachen mit Komma als Dezimaltrennzeichen (u. a. Deutsch):
  Argumenttrennzeichen   ","  ->  ";"
  Verkettungsoperator    ";"  ->  ";;"
  Dezimaltrennzeichen    "."  ->  ","   (hier nicht noetig, alle Werte ganzzahlig)

Zeichenketten und Kommentare bleiben unveraendert - sonst wuerde deutscher
Anzeigetext wie "Vorname, Nachname" mitveraendert.

WICHTIG: Diese Umwandlung betrifft NUR Formeln, die von Hand in die
Formelleiste eingetragen werden. Der YAML-Code der Codeansicht behaelt
immer die invarianten Trennzeichen.
"""
from __future__ import annotations
import re
import sys

MUSTER_GESCHUETZT = re.compile(r'("(?:[^"]|"")*")|(//[^\n]*)')


def nach_deutsch(text: str) -> str:
    teile: list[str] = []
    pos = 0
    for treffer in MUSTER_GESCHUETZT.finditer(text):
        roh = text[pos:treffer.start()]
        # Reihenfolge ist wichtig: erst Verkettung verdoppeln, dann Argumente.
        roh = roh.replace(";", ";;").replace(",", ";")
        teile.append(roh)
        teile.append(treffer.group(0))
        pos = treffer.end()
    rest = text[pos:].replace(";", ";;").replace(",", ";")
    teile.append(rest)
    return "".join(teile)


if __name__ == "__main__":
    sys.stdout.write(nach_deutsch(sys.stdin.read()))
