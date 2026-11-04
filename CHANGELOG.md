# Changelog

## 0.5.3-ahlers2mi.2 (04.11.2026)
- Backslashes in T2F_keywordlist/T2F_modwordlist bleiben erhalten (quotewords)
- UND-Analyse in fester Reihenfolge statt Hash-Reihenfolge
- Test-Harness: IsInt wie 99_Utils.pm (vorher lieferten Farbbefehle im Test faelschlich rgb 000000)

## 0.5.3-ahlers2mi.1 (04.11.2026)
- Basis: lokal angepasste 0.5.3 (Antwort aus set, optionale Teile nicht loeschen, acht, heute, empty, disu)
- Keywords zuerst am Wortanfang suchen, Teilwort nur als Rückfall
- Treffer literal statt als Regex aus dem Satz entfernen, Dopplungen nur als ganzes Wort
- Test-Harness `t/` (Modul ohne FHEM laden, upstream vs. angepasst vergleichen)

## 0.5.3 (upstream)
- Stand FHEM-SVN trunk, abgerufen 04.11.2026
