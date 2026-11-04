# FHEM-Talk2Fhem

Gepflegte Kopie des FHEM-Moduls **Talk2Fhem** (39_Talk2Fhem.pm, © 2018 Oliver Georgi, GPL v2)
mit kleinen Korrekturen an der Wort-Erkennung.

- `upstream/39_Talk2Fhem.pm` – unveränderter Stand aus dem FHEM-SVN (trunk, abgerufen 04.11.2026, Version 0.5.3)
- `FHEM/39_Talk2Fhem.pm` – angepasste Fassung (Version `0.5.3-ahlers2mi.1`): lokale Anpassungen + Korrekturen unten

Kein Fork von `fhem/fhem-mirror`: der enthielte das komplette FHEM (~300 MB), und Änderungen an
FHEM laufen ohnehin über SVN/Forum, nicht über GitHub-Pull-Requests.

## Lokale Anpassungen (seit längerem im Einsatz)

- `set <talk> …` gibt die Antwort bzw. den Status zurück (bei `done` ein zufälliges
  „alles klar“ o. ä.) – nötig, wenn `set` aus Perl aufgerufen und die Antwort weitergereicht wird
  (z. B. Alexa).
- Optionale Phrasenteile `?(...)` werden nicht mehr aus dem Satz gelöscht.
- Zahlwort `' acht\S*'` mit führendem Leerzeichen („Nacht“ ist keine 8).
- Zeitphrase `heute` deaktiviert.
- `{empty=>…, else=>…}`: bei leerem Treffer nur `empty`, nicht ersatzweise `else`.
- `T2F_disableumlautescaping` wird korrekt über den Gerätenamen gelesen, Debug-Ausgaben auf Level 5.
- `t/` – Test ohne FHEM: lädt das Modul mit Stubs und wertet Sätze aus (es wird nichts geschaltet)

## Änderungen gegenüber upstream

1. **Keywords bevorzugt am Wortanfang.** Bisher traf z. B. `Tisch` aus `&places` auch mitten in
   „Kaffeetisch“ und hatte damit Vorrang vor einem späteren, passenden Wort („… an der Wand“).
   Jetzt wird jede Phrase zuerst mit „Keyword am Wortanfang“ gesucht, erst ohne Treffer wie bisher
   als Teilwort. Zusammengesetzte Wörter („Nachttischlampe“ → `Lampe`) funktionieren also weiter.
   Das Wortende bleibt offen, damit `Rollade` weiterhin in „Rolladen“ trifft – das getroffene
   Listenwort landet in Filtern wie `T2F_types_blind=.*Rollade.*`.
2. **Treffer werden literal aus dem Satz entfernt** (Pflichtteile; optionale werden gar nicht
   entfernt, s. o.). Bisher `$cmd =~ s/$m//gi`: Der Treffer wurde als
   ungeschützter Regex benutzt und auch mitten in anderen Wörtern gelöscht. Jetzt wird genau die
   Trefferstelle entfernt, weitere Vorkommen nur als ganzes Wort (die UND-Analyse erzeugt solche
   Dopplungen, z. B. „Steckdose Steckdose im Keller“).

3. **Backslashes in `T2F_keywordlist`/`T2F_modwordlist` bleiben erhalten.** `quotewords()` entfernte
   sie außerhalb von `'...'`: `Bad\S*` wurde zu `BadS*`, `Terrasse(?!\sOst)` zu `Terrasse(?!sOst)`
   (wirkungslos). Jetzt unterscheiden „Terrasse Ost“, „Terrasse West“ und „Terrasse“ wie gedacht.
4. **Feste Reihenfolge in der UND-Analyse.** Die Listen wurden in Hash-Reihenfolge durchlaufen, die
   Perl bei jedem Start neu würfelt – derselbe Satz konnte nach einem Neustart anders zerlegt werden.

Die Reihenfolge der Keyword-Listen bleibt unverändert (wichtig für die Zuordnung zur `T2F_modwordlist`).

## Test

```sh
t/vergleich.sh                       # Beispielkonfiguration t/beispiel.json + t/saetze.txt
t/vergleich.sh meine.json saetze.txt # eigene Konfiguration: {"def": "...", "attributes": {...}}
```

Zeigt die Unterschiede zwischen upstream und angepasster Fassung. Mit der Konfiguration, für die das
Repo entstanden ist, ergaben 879 Sätze (alle Schalt-, Rollo- und Info-Typen × Räume/Orte) keine
Unterschiede zur vorher installierten Fassung (mit lokalen Anpassungen).

## Installation in FHEM

Über das FHEM-Update aus diesem Repo:

```
update all https://raw.githubusercontent.com/ahlers2mi/FHEM-Talk2Fhem/main/controls_Talk2Fhem.txt
reload 39_Talk2Fhem
```

Danach überschreibt ein normales `update` die Datei wieder mit dem Stand aus dem FHEM-SVN.
Das lässt sich mit `exclude_from_update` verhindern – dann bitte die Doku von `global`/`update`
prüfen, ob die Sperre auf die Quelle fhem.de beschränkt werden kann, sonst greift sie auch für
dieses Repo.

Alternativ die Datei von Hand nach `FHEM/39_Talk2Fhem.pm` kopieren und `reload 39_Talk2Fhem`.

## Bekannte Eigenheiten von upstream (nicht geändert)

- `T2F_filter` verliert seine Backslashes weiterhin (`\bbitte\b` → `bbitteb`, greift also nie).
  Bewusst nicht geändert: ein funktionierender Filter würde „bitte“ vor der Auswertung entfernen,
  Antworten wie `$1{/bitte/=>Gern\,}` fielen dann weg.
- In `{…}`/`[…]`-Modifikatoren (z. B. `$2{empty=>…, else=>$2@}`) gehen Backslashes eines
  eingesetzten Listenworts verloren (`Terrasse\sOst` → `TerrassesOst`); Listenwörter mit einer
  zweiten Schreibweise ohne Regex (`|Ostterrasse`) treffen trotzdem.
- Umlaut-Platzhalter landen im Filter (`T2F_places=.*T\S\S?r.*` für „Tür“), wenn
  `T2F_disableumlautescaping` nicht gesetzt ist.
- Leerzeichen in Listenwörtern landen im `set`-Befehl und zerlegen ihn. Statt `Nachttisch Maike`
  `Nachttisch.Maike` in die Liste schreiben (der Punkt trifft das Leerzeichen).
