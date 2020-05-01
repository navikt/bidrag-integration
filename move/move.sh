#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input fra script (mappe hvor innhold skal kopieres og flyttes fra)
# 2) oppretter generert mappe under docs/generated
# 3) kopierer generert html til generert mappe
# 4) sletter gamle genererte html mapper rett under docs mappa
# 5) flytter (og overskriver gammel) generert html til github pages (docs mappa)
#
############################################

INPUT_FOLDER_MOVE_FROM=$1

if [[ $# -ne 1 ]]; then
  echo "Usage: move.sh [relative/path/to/html/folder/to/move]"
  exit 1;
fi

PROJECT_ROOT=${PWD}

if [[ ! -d "$PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM" ]]; then
  echo ::error:: "unable to locate folder to move from $PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM"
  exit 1;
fi

GENERATED_FOLDER=$(date +"%Y-%m-%d")

if [[ -d "$PROJECT_ROOT/docs/generated/$GENERATED_FOLDER" ]]; then
  GENERATED_FOLDER=$(date +"%Y-%m-%d0.%T")
fi

echo "Flytter html fra mappe $PROJECT_ROOT/$INPUT_FOLDER_MOVE_FROM til mappe $PROJECT_ROOT/docs"
echo "Oppretter også en kopi i $PROJECT_ROOT/docs/generated/$GENERATED_FOLDER"

mkdir ${PROJECT_ROOT}/docs/generated/${GENERATED_FOLDER}
cp -R ${PROJECT_ROOT}/${INPUT_FOLDER_MOVE_FROM}/* ${PROJECT_ROOT}/docs/generated/${GENERATED_FOLDER}/.
cd ${PROJECT_ROOT}/docs && ls | grep -v generated | xargs rm -rf
sudo mv ../${INPUT_FOLDER_MOVE_FROM}/* .
