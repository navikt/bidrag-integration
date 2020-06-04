#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# det forventes at endelig resultat som legges på markdown-fil som input blir fila <input>/index.md
# det forventes også markdown-fil som er input ligger på rotkatalogen til prosjektet
# skriptet håndterer bare github pages som ligger i en sub-folder til rotkatalogen i prosjektet
#
# Følgende skjer i dette skriptet:
# 1) setter input (full filsti til markdown-fil, samt antall passerte og feilede teststeg
# 2) finner fullstendig sti markdown-fil og sluttresultat-fil
# 3) setter status ikon basert på antall feilede tester
# 4) legger til status på sluttresultat-fil
# 5) setter full filsti til sluttresultat-fil som output
#
############################################

if [[ $# -ne 5 ]]; then
  echo "Bruk: status.sh <sidefil i markdown> <antall ok teststeg> <antall feilede teststeg> <navn på prosjekt> <mappe til github pages>"
  exit 1;
fi

INPUT_MARKDOWN_PAGE=$1
INPUT_PASSED_STEPS=$2
INPUT_FAILED_STEPS=$3
INPUT_PROJECT_NAME=$4
INPUT_GH_PAGES_FOLDER=$5

cd ..

FIRST_LINE_PATH_OF_PROJECT_NAME=$(find . -type d | grep "$INPUT_PROJECT_NAME" | sed 1q) # first line of directory match
PROJECT_ROOT=$(echo "$PWD/$FIRST_LINE_PATH_OF_PROJECT_NAME" | sed 's;/./;/;')
FULL_PATH_TO_MARKDOWN_PAGE="$PROJECT_ROOT/$INPUT_MARKDOWN_PAGE"
FULL_PATH_TO_EDITED_PAGE="$PROJECT_ROOT/$INPUT_GH_PAGES_FOLDER/index.md"

echo "Antall teststeg som er ok : $INPUT_PASSED_STEPS"
echo "Antall teststeg som feilet: $INPUT_FAILED_STEPS"
echo "Filsti til markdown side  : $FULL_PATH_TO_MARKDOWN_PAGE"
echo "Filsti til endret side    : $FULL_PATH_TO_EDITED_PAGE"

STATUS_ICON=":green_circle:"

if [ "$INPUT_FAILED_STEPS" -ne 0 ]; then
  STATUS_ICON=":red_circle"
fi

echo "$(cat "$FULL_PATH_TO_MARKDOWN_PAGE")

#### Siste Cucumber rapporter

##### Status for siste kjøring
<p>
  Status på jobb: $STATUS_ICON <br>
  Passerte steg : $INPUT_PASSED_STEPS <br>
  Feilede steg  : $INPUT_FAILED_STEPS <br>
</p>
" > "$FULL_PATH_TO_EDITED_PAGE"

echo ::set-output name=edited_page::"$FULL_PATH_TO_EDITED_PAGE"
