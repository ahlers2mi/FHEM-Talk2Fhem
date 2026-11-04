# FHEM-Talk2Fhem

Gepflegte Kopie des FHEM-Moduls **Talk2Fhem** (39_Talk2Fhem.pm, © 2018 Oliver Georgi, GPL v2)
mit kleinen Korrekturen an der Wort-Erkennung.

- `upstream/39_Talk2Fhem.pm` – unveränderter Stand aus dem FHEM-SVN (trunk, abgerufen 04.11.2026, Version 0.5.3)
- `FHEM/39_Talk2Fhem.pm` – angepasste Fassung (Version `0.5.3-ahlers2mi.1`)
- `t/` – Test ohne FHEM: lädt das Modul mit Stubs und wertet Sätze aus (es wird nichts geschaltet)

## Änderungen gegenüber upstream

1. **Keywords bevorzugt am Wortanfang.** Bisher traf z. B. `Tisch` aus `&places` auch mitten in
   „Kaffeetisch“ und hatte damit Vorrang vor einem späteren, passenden Wort („… an der Wand“).
   Jetzt wird jede Phrase zuerst mit „Keyword am Wortanfang“ gesucht, erst ohne Treffer wie bisher
   als Teilwort. Zusammengesetzte Wörter („Nachttischlampe“ → `Lampe`) funktionieren also weiter.
   Das Wortende bleibt offen, damit `Rollade` weiterhin in „Rolladen“ trifft – das getroffene
   Listenwort landet in Filtern wie `T2F_types_blind=.*Rollade.*`.
2. **Treffer werden literal aus dem Satz entfernt.** Bisher `$cmd =~ s/$m//gi`: Der Treffer wurde als
   ungeschützter Regex benutzt und auch mitten in anderen Wörtern gelöscht. Jetzt wird genau die
   Trefferstelle entfernt, weitere Vorkommen nur als ganzes Wort (die UND-Analyse erzeugt solche
   Dopplungen, z. B. „Steckdose Steckdose im Keller“).

Die Reihenfolge der Keyword-Listen bleibt unverändert (wichtig für die Zuordnung zur `T2F_modwordlist`).

## Test

```sh
t/vergleich.sh                       # Beispielkonfiguration t/beispiel.json + t/saetze.txt
t/vergleich.sh meine.json saetze.txt # eigene Konfiguration: {"def": "...", "attributes": {...}}
```

Zeigt die Unterschiede zwischen upstream und angepasster Fassung. Mit der Konfiguration, für die das
Repo entstanden ist, ergaben 879 Sätze (alle Schalt-, Rollo- und Info-Typen × Räume/Orte) keine
Unterschiede.

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

- Backslashes in `T2F_keywordlist` gehen beim Einlesen verloren (`Bad\S*` → `BadS*`,
  `Terrasse(?!\sOst)` → `Terrasse(?!sOst)`).
- Umlaut-Platzhalter landen im Filter (`T2F_places=.*T\S\S?r.*` für „Tür“).
