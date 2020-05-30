#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - github pages befinner seg under mappa docs
# - sist genererte rapport lagges under mappe docs/latest
# - alle genererte rapporter ligger under mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input og alle FULL_PATH variabler ut fra $PWD/..
# 2) oppretter generert mappe under docs/generated (oppretter timestampted mappe hvis dato-mappe finnes)
# 3) kopierer generert html til generert mappe
# 4) sletter gamle genererte html mapper rett under docs/latest mappa
# 5) flytter (og overskriver gammel) generert html til github pages (docs/latest mappa)
#
############################################

if [[ $# -ne 2 ]]; then
  echo "Usage: report.sh <path/to/html/folder/for/generated/html> <project-name>"
  exit 1;
fi

INPUT_FOLDER_MOVE_FROM=$1
INPUT_PROJECT_WHERE_TO_MOVE=$2

cd ..

FIRST_LINE_PATH_TO_MOVE_FOLDER=$(find . -type d | grep "$INPUT_FOLDER_MOVE_FROM" | sed 1q) # first line of directory match
FULL_PATH_TO_MOVE_FOLDER="$PWD/$(echo "$FIRST_LINE_PATH_TO_MOVE_FOLDER" | sed 's,^ *,,; s, *$,,')" # concat with PWD and remove leading and trailing whitespaces from first line
FULL_PATH_TO_ROOT_PROJECT="$PWD/$(find . -type f | grep "$INPUT_PROJECT_WHERE_TO_MOVE/README.md" | sed 's;/README.md;;')" # remove /README.md from string
FULL_PATH_TO_DOCS_LATEST="$FULL_PATH_TO_ROOT_PROJECT/docs/latest"
FULL_PATH_TO_DOCS_GENERATED="$FULL_PATH_TO_ROOT_PROJECT/docs/generated"

FULL_PATH_TO_MOVE_FOLDER=$(echo "$FULL_PATH_TO_MOVE_FOLDER" | sed 's;/./;/;' | sed "s/'//")       # replace /./ with / and remove '
FULL_PATH_TO_ROOT_PROJECT=$(echo "$FULL_PATH_TO_ROOT_PROJECT" | sed 's;/./;/;' | sed "s/'//")     # replace /./ with / and remove '
FULL_PATH_TO_DOCS_LATEST=$(echo "$FULL_PATH_TO_DOCS_LATEST" | sed 's;/./;/;' | sed "s/'//")       # replace /./ with / and remove '
FULL_PATH_TO_DOCS_GENERATED=$(echo "$FULL_PATH_TO_DOCS_GENERATED" | sed 's;/./;/;' | sed "s/'//") # replace /./ with / and remove '

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
