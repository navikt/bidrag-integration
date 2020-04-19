#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter input fra script (mappe hvor innhold skal kopieres og flyttes fra, samt navn på mappa som skal inneholde generert html)
# 2) oppretter generert mappe
# 3) kopierer generert html til generert mappe
# 4) flytter generert html til github pages
#
############################################

INPUT_FOLDER_MOVE_FROM=$1
INPUT_FOLDER_FOR_HTML=$2

if [[ $# -ne 2 ]]; then
  echo "Usage: move.sh [target/html/folder] [name-of-folder-for-html]"
  exit 1;
fi

echo "Flytter html fra mappe $PWD/$INPUT_FOLDER_MOVE_FROM til mappe $PWD/docs samt oppretter en kopi i $PWD/generated/$INPUT_FOLDER_FOR_HTML."

mkdir $PWD/generated/${INPUT_FOLDER_FOR_HTML}
cp -r $PWD/${INPUT_FOLDER_MOVE_FROM}/* $PWD/generated/${INPUT_FOLDER_FOR_HTML}/.
rm -rf $PWD/docs/*
sudo mv $PWD/${INPUT_FOLDER_MOVE_FROM}/* $PWD/docs/.
