#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - github prosjektets "front-page" beginner seg som "template" fil i rot-mappa til prosjektet
# - github pages befinner seg under mappa docs
# - sist genererte rapport blir lagt under mappe docs/latest
# - eldre genererte rapporter blir lagt under mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input (addresse til github pages for prosjektet, navnet til prosjektet og prosjektets forside)
# 2) leser prosjektets README.md og lagrer den teksten under docs/index.md
# 3) legger siste genererte integrasjonsrapport inn under docs/latest
# 4) legger til linker for alle genererte rapporter under docs/inndex.md som peker til docs/generated/<dato-tid>
#
############################################

if [[ $# -ne 3 ]]; then
  echo "Bruk: report.sh <organisasjon>.github.io/<prosjekt> <project where to move> <project front page>"
  exit 1;
fi

INPUT_PAGES_ADDRESS=$1
INPUT_PROJECT_WHERE_TO_MOVE=$2
INPUT_FRONT_PAGE=$3

FULL_PATH_TO_ROOT_PROJECT="$PWD/$(find . -type f | grep "$INPUT_PROJECT_WHERE_TO_MOVE/$INPUT_FRONT_PAGE" | sed "s;/$INPUT_FRONT_PAGE;;")" # remove front page from string

cat "$FULL_PATH_TO_ROOT_PROJECT/$INPUT_FRONT_PAGE" > "$FULL_PATH_TO_ROOT_PROJECT/docs/index.md"
cd "$FULL_PATH_TO_ROOT_PROJECT/docs/generated" || exit 1;

for folder in $(ls -d -r */); do
  echo "lager link til $folder..."
  FOLDER_NAME=$(echo "$folder" | sed 's;/;;')
  echo "Tests at [$FOLDER_NAME]($INPUT_PAGES_ADDRESS/generated/$folder) <br>" >> "$FULL_PATH_TO_ROOT_PROJECT/docs/index.md"
done
