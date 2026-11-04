#!/bin/sh
# Vergleicht upstream/39_Talk2Fhem.pm mit FHEM/39_Talk2Fhem.pm auf denselben Saetzen.
# Fester Hash-Seed: die UND-Analyse des Moduls haengt von der Hash-Reihenfolge ab.
# Aufruf: t/vergleich.sh [konfig.json] [saetze.txt]
# konfig.json: {"def": "<DEF des Talk2Fhem-Geraets>", "attributes": {...}}
cd "$(dirname "$0")/.." || exit 1
K=${1:-t/beispiel.json}; S=${2:-t/saetze.txt}
PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 perl t/harness.pl ./upstream/39_Talk2Fhem.pm "$K" "$S" > /tmp/t2f_alt.txt 2>/dev/null
PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 perl t/harness.pl ./FHEM/39_Talk2Fhem.pm "$K" "$S" > /tmp/t2f_neu.txt 2>/dev/null
if diff -u /tmp/t2f_alt.txt /tmp/t2f_neu.txt; then echo "keine Unterschiede"; fi
