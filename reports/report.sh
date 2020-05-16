#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - github pages befinner seg under mappa docs
# - sist genererte rapport blir lagt under mappe docs/latest
# - eldre genererte rapporter blir lagt under mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input (addresse til github pages for prosjektet)
# 2) leser prosjektets README.md og lagrer den teksten under docs/index.md
# 3) legger til linker til de eldre genererte rapportene
#
############################################

if [[ $# -ne 1 ]]; then
  echo "Bruk: report.sh [<organisasjon>.github.io/<prosjekt>]"
  exit 1;
fi

INPUT_PAGES_ADDRESS=$1

cat README.md > docs/index.md
cd docs/generated

for folder in ls -d -r; do
  echo "$INPUT_PAGES_ADDRESS/generated/$folder" >> ../index.md
done
