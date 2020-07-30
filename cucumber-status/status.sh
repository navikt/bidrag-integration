#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# det forventes at endelig resultat som legges på markdown-fil som input blir fila <inpdut github pages>/index.md
# det forventes også markdown-fil som er input ligger på rotkatalogen til prosjektet
# skriptet håndterer bare github pages som ligger i en sub-folder til rotkatalogen i prosjektet
#
# Følgende skjer i dette skriptet:
# 1) setter input (navn til markdown-fil, antall passerte og feilede teststeg, samt prosjektnavn, mappe til "github pages" og tidsstempel)
# 2) går til runner workspace og finner fullstendig sti til markdown-fil og sluttresultat-fil
# 3) legger til status på sluttresultat-fil
# 3) legger til tidsstempel på sluttresultat-fil
# 4) setter full filsti til sluttresultat-fil som output
#
############################################

if [[ $# -ne 6 ]]; then
  echo "Bruk: status.sh <sidefil i markdown> <antall ok teststeg> <antall feilede teststeg> <navn på prosjekt> <mappe til github pages> <timestamp>"
  exit 1;
fi

INPUT_MARKDOWN_PAGE=$1
INPUT_PASSED_STEPS=$2
INPUT_FAILED_STEPS=$3
INPUT_PROJECT_NAME=$4
INPUT_GH_PAGES_FOLDER=$5
INPUT_TIMESTAMP=$6

cd "$RUNNER_WORKSPACE" || exit 1

RELATIVE_PATH_TO_MARKDOWN_PAGE=$(find . -type f | grep "$INPUT_PROJECT_NAME/$INPUT_MARKDOWN_PAGE")
PROJECT_ROOT="$PWD/${RELATIVE_PATH_TO_MARKDOWN_PAGE%/$INPUT_MARKDOWN_PAGE}" # fjerner /<md-fil> fra path

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo ::error:: "Unable to find project root from RUNNER_WORKSPACE & INPUT_PROJECT_NAME: $RUNNER_WORKSPACE & $INPUT_PROJECT_NAME"
fi

FULL_PATH_TO_MARKDOWN_PAGE="$PROJECT_ROOT/$INPUT_MARKDOWN_PAGE"
FULL_PATH_TO_EDITED_PAGE="$PROJECT_ROOT/$INPUT_GH_PAGES_FOLDER/index.md"

echo "Antall teststeg som er ok : $INPUT_PASSED_STEPS"
echo "Antall teststeg som feilet: $INPUT_FAILED_STEPS"
echo "Tdstempel for flytting    : $INPUT_TIMESTAMP"
echo "Filsti til markdown side  : $FULL_PATH_TO_MARKDOWN_PAGE"
echo "Filsti til endret side    : $FULL_PATH_TO_EDITED_PAGE"

# shellcheck disable=SC2002
cat "$FULL_PATH_TO_MARKDOWN_PAGE" | sed "s/ANTALL_TESTSTEG_FEILET/$INPUT_FAILED_STEPS/" | sed "s/ANTALL_TESTSTEG_OK/$INPUT_PASSED_STEPS/" | sed "s/TIMESTAMP/$INPUT_TIMESTAMP/"  > "$FULL_PATH_TO_EDITED_PAGE"

echo ::set-output name=edited_page::"$FULL_PATH_TO_EDITED_PAGE"
