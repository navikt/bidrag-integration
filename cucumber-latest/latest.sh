#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - input til skriptet inneholder relativ filsti en cucumber json fil
# - input til skriptet inneholder json path til status for hvert steg til alle cucumber testene
# - en tidstempling for når cucumber fil ble lagt under latest er å finne i fila docs/latest/timestamp
#
# Følgende skjer i dette skriptet:
# 1) går til RUNNER_WORKSPACE
# 2) setter input (relativ filsti til json fil og json path til hvert stegs status)
# 3) finner full sti til json fil
#    - hvis sti ikke finnes, sluttes scriptet med feil
# 4) teller antall steg som er ok
# 5) teller antall steg som feilet
# 6) setter output basert på antall som er funnet
# 7) setter også output basert på timestamp fra bidrag-dev.json fra "latest" mappa
#
############################################

cd "$RUNNER_WORKSPACE" || exit 1 # cd til RUNNER_WORKSPACE eller hard exit

if [[ $# -ne 2 ]]; then
  echo "Bruk: latest.sh <relativ/sti/til/json> <path.steg[].status>"
  exit 1;
fi

INPUT_FILE_PATH=$1
INPUT_JSON_PATH=$2
FILE_PATH_RELEATIVE_TO_PWD=$(find . -type f | grep "$INPUT_FILE_PATH")

if [ "$FILE_PATH_RELEATIVE_TO_PWD" == "" ]; then
  echo ::error:: "could not find relative file path: $INPUT_FILE_PATH at PWD: $PWD"
  exit 1;
fi

FULL_PATH_TO_JSON=$( echo "$PWD/$FILE_PATH_RELEATIVE_TO_PWD" | sed 's;/./;/;' ) # erstatter /./ med /

echo "Filsti til json : $FULL_PATH_TO_JSON"
echo "Json path til jq: $INPUT_JSON_PATH"

NUMBER_PASSED=$(jq "$INPUT_JSON_PATH" "$FULL_PATH_TO_JSON" | grep -c passed || true)  # || true for å ikke få exit code > 0 hvis antall er 0
NUMBER_FAILED=$(jq "$INPUT_JSON_PATH" "$FULL_PATH_TO_JSON" | grep -c failed || true)  # || true for å ikke få exit code > 0 hvis antall er o
TIMESTAMP=$(echo "$FULL_PATH_TO_JSON" | sed 's/cucumber.json/bidrag-dev.json/' | xargs jq '.timestamp')

echo ::set-output name=steps_passed::"$NUMBER_PASSED"
echo ::set-output name=steps_failed::"$NUMBER_FAILED"
echo ::set-output name=time_moved::"$TIMESTAMP"
