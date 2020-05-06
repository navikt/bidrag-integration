#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input fra script (mappe hvor innhold skal kopieres og flyttes fra)
# 2) oppretter generert mappe under docs/generated
# 3) kopierer generert html til generert mappe
# 4) sletter gamle genererte html under docs/recent mappa
# 5) flytter (og overskriver gammel) generert html til github pages (docs/recent mappa)
# 6) for hver generert mappe, lag en link i docs/index.md
#
############################################

INPUT_FOLDER_MOVE_FROM=$1

if [[ $# -ne 1 ]]; then
  echo "Usage: move.sh [relative/path/to/html/folder/to/move]"
  exit 1;
fi

PROJECT_ROOT="$PWD"
GH_PAGES_GENERATED="$PROJECT_ROOT/docs/generated"
GH_PAGES_RECENT="$PROJECT_ROOT/docs/recent"

if [[ ! -d "$PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM" ]]; then
  echo ::error:: "unable to locate folder to move from $PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM"
  exit 1;
fi

GENERATED_FOLDER=$(date +"%Y-%m-%d")

if [[ -d "$GH_PAGES_GENERATED/$GENERATED_FOLDER" ]]; then
  GENERATED_FOLDER=$(date +"%Y-%m-%d.%T")
fi

echo "Flytter html fra mappe $PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM til mappe $GH_PAGES_RECENT"
echo "Oppretter også en kopi i $GH_PAGES_GENERATED/$GENERATED_FOLDER"

mkdir "$GH_PAGES_GENERATED/$GENERATED_FOLDER"
cp -R "$PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM/*" "$GH_PAGES_GENERATED/$GENERATED_FOLDER/."
cd "$GH_PAGES_RECENT" && rm -rf *
sudo mv "$PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM/* ."

cd "$PROJECT_ROOT/docs"
INDEX=$(cat index.md)

for file in $(ls -r -F docs/generated/. | grep -v .md | grep -v generated)
INDEX=INDEX+"Cucumber reports at [$file](https://jactor-rises.github.io/jactor-cucumber/generated/$file)"

echo "$INDEX" > index.md
