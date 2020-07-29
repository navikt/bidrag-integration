#!/bin/bash
set -x

############################################
#
# Følgende forutsetninger for dette skriptet
# - github prosjektets "front-page" beginner seg som "template" fil i rot-mappa til prosjektet
# - github pages befinner seg under mappa docs
# - sist genererte cucumber json lagges under mappe docs/latest/
# - sist genererte html rapport (m/undermapper) lagges under mappe docs/latest
# - alle genererte html rapporter ligger under mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input
# 2) FULL_PATH variabler ut fra $PWD/..
# 3) oppretter generert mappe under docs/generated (oppretter timestampted mappe hvis dato-mappe finnes)
# 4) kopierer generert html til generert mappe
# 5) sletter gamle genererte html mapper rett under docs/latest mappa
# 6) flytter (og overskriver gammel) generert html til github pages (docs/latest mappa)
# 7) flytter generert json fil fra input under github pages (docs/latest/<input-fil>)
# 8) oppretter ei fil som inneholder tidsstempling for når dette ble gjort i docs/latest/timestamp
#
############################################

if [[ $# -ne 4 ]]; then
  echo "Usage: mova.sh <path/to/html/folder/for/generated/html> <project where to move> <project front page> <cucumber.json>"
  exit 1;
fi

INPUT_FOLDER_MOVE_FROM=$1
INPUT_PROJECT_WHERE_TO_MOVE=$2
INPUT_FRONT_PAGE=$3
INPUT_LATEST_CUCUMBER_JSON=$4

cd ..

FIRST_LINE_PATH_TO_MOVE_FOLDER=$(find . -type d | grep "$INPUT_FOLDER_MOVE_FROM" | sed 1q)                         # first line of directory match
FULL_PATH_TO_MOVE_FOLDER="$PWD/$(echo "$FIRST_LINE_PATH_TO_MOVE_FOLDER" | sed 's,^ *,,; s, *$,,')"                 # concat with PWD and remove leading and trailing whitespaces from first line
FULL_PATH_TO_ROOT_PROJECT="$PWD/$(find . -type f | grep "$INPUT_PROJECT_WHERE_TO_MOVE/$INPUT_FRONT_PAGE" | sed "s;/$INPUT_FRONT_PAGE;;")"       # remove front page from string
FULL_PATH_TO_DOCS_LATEST="$(echo "$FULL_PATH_TO_ROOT_PROJECT/docs/latest" | sed 's;//;/;')"                        # replace // with / in path
FULL_PATH_TO_DOCS_GENERATED="$(echo "$FULL_PATH_TO_ROOT_PROJECT/docs/generated" | sed 's;//;/;')"                  # replace // with / in path
FULL_PATH_TO_GENERATED_CUCUMBER_JSON="$PWD/$(find . -type f | grep "$INPUT_LATEST_CUCUMBER_JSON" | sed 's;//;/;')" # replace // with / in path

FULL_PATH_TO_MOVE_FOLDER=$(echo "$FULL_PATH_TO_MOVE_FOLDER" | sed 's;/./;/;' | sed "s/'//")                        # replace /./ with / and remove '
FULL_PATH_TO_ROOT_PROJECT=$(echo "$FULL_PATH_TO_ROOT_PROJECT" | sed 's;/./;/;' | sed "s/'//")                      # replace /./ with / and remove '
FULL_PATH_TO_DOCS_LATEST=$(echo "$FULL_PATH_TO_DOCS_LATEST" | sed 's;/./;/;' | sed "s/'//")                        # replace /./ with / and remove '
FULL_PATH_TO_DOCS_GENERATED=$(echo "$FULL_PATH_TO_DOCS_GENERATED" | sed 's;/./;/;' | sed "s/'//")                  # replace /./ with / and remove '
FULL_PATH_TO_GENERATED_CUCUMBER_JSON=$(echo "$FULL_PATH_TO_GENERATED_CUCUMBER_JSON" | sed 's;/./;/;'| sed "s/'//") # replace /./ with / and remove '

if [[ ! -d "$FULL_PATH_TO_MOVE_FOLDER" ]]; then
  echo ::error:: "unable to locate folder to move from - $INPUT_FOLDER_MOVE_FROM (using full path: $FULL_PATH_TO_MOVE_FOLDER)"
  exit 1;
fi

GENERATED_FOLDER=$(date +"%Y-%m-%d")

echo "Move generated html from $FULL_PATH_TO_MOVE_FOLDER"

if [[ -d "$FULL_PATH_TO_DOCS_GENERATED/$GENERATED_FOLDER" ]]; then
  GENERATED_FOLDER=$(date +"%Y-%m-%d.%T")
fi

FULL_PATH_TO_GENERATED_FOLDER="$FULL_PATH_TO_DOCS_GENERATED/$GENERATED_FOLDER"
mkdir "$FULL_PATH_TO_GENERATED_FOLDER"

echo "Flytter html fra mappe $FULL_PATH_TO_MOVE_FOLDER til mappe $FULL_PATH_TO_DOCS_LATEST"
echo "Oppretter også en kopi i $FULL_PATH_TO_GENERATED_FOLDER"

cp -R "$FULL_PATH_TO_MOVE_FOLDER"/* "$FULL_PATH_TO_GENERATED_FOLDER"/.
cd "$FULL_PATH_TO_DOCS_LATEST" && ls | xargs sudo rm -rf
sudo mv "$FULL_PATH_TO_MOVE_FOLDER"/* .
sudo mv "$FULL_PATH_TO_GENERATED_CUCUMBER_JSON" "$FULL_PATH_TO_DOCS_LATEST/."
date > "$FULL_PATH_TO_DOCS_LATEST/timestamp"
