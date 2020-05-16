#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - github pages befinner seg under mappa docs
# - sist genererte rapport lagges under mappe docs/latest
# - eldre genererte rapporter ligger under mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input fra script (mappe hvor innhold skal kopieres og flyttes fra)
# 2) oppretter generert mappe under docs/generated
# 3) kopierer generert html til generert mappe
# 4) sletter gamle genererte html mapper rett under docs/latest mappa
# 5) flytter (og overskriver gammel) generert html til github pages (docs/latest mappa)
#
############################################

if [[ $# -ne 1 ]]; then
  echo "Usage: report.sh [relative/path/to/html/folder/to/move]"
  exit 1;
fi

INPUT_FOLDER_MOVE_FROM=$1

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

echo "Flytter html fra mappe $PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM til mappe $PROJECT_ROOT/docs/latest"
echo "Oppretter også en kopi i $PROJECT_ROOT/docs/generated/$GENERATED_FOLDER"

mkdir ${PROJECT_ROOT}/docs/generated/${GENERATED_FOLDER}
cp -R ${PROJECT_ROOT}/${INPUT_FOLDER_MOVE_FROM}/* ${PROJECT_ROOT}/docs/generated/${GENERATED_FOLDER}/.
cd ${PROJECT_ROOT}/docs/latest && ls |  xargs rm -rf
sudo mv ${PROJECT_ROOT}/${INPUT_FOLDER_MOVE_FROM}/* .
