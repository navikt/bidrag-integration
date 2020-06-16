#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# det forventes at endelig resultat som legges til et felt i en markdown-fil som er input, eks fila <inpdut github pages>/index.md
# det forventes også markdown-fil som er input ligger på rotkatalogen til prosjektet
# skriptet håndterer bare github pages som ligger i en sub-folder til rotkatalogen i prosjektet
#
# Følgende skjer i dette skriptet:
# 1) setter input
# 2) hvis path til fil som skal få linkene ikke finnes, avsluttes scriptet med feil
# 3) går til runner workspace og lager fullstendig filsti til mappa som inneholder filer som skal linkes
# 4) henter ut tittel fra hver fil  i mappa og leggewr disse som linker i miljøvariabel
# 5) erstatter LINK_PAGES med linker fra miljøvariabel i fila (page_path) for github pages
#
############################################

if [[ $# -ne 3 ]]; then
  echo ::error:: "Bruk: link.sh <folder> <github front page file path> <file pattern to link>"
  exit 1;
fi

INPUT_LINK_PAGES=$1
INPUT_PAGE_PATH=$2
INPUT_PATTERN=$3

if [[ ! -f "$INPUT_PAGE_PATH" ]]; then
  echo ::error:: "File does not exist: $INPUT_PAGE_PATH"
  exit 1;
fi

cd "$RUNNER_WORKSPACE" || exit 1

LINK_PAGES_FOLDER=$(find . -d -name "$INPUT_LINK_PAGES")
FOLDER_ROOT="$PWD/$LINK_PAGES_FOLDER"

if [[ -d "$FOLDER_ROOT" ]]; then
  echo "Folder to link files from: $FOLDER_ROOT"
else
  echo ::error:: "Unable to find folder ($INPUT_LINK_PAGES) as sub folder in $RUNNER_WORKSPACE"
  exit 1;
fi

cd "$FOLDER_ROOT" || exit 1;
PAGE_LINKS=""

for page in $INPUT_PATTERN
do
  # will remove all # from first line in file (and then a space if line starts with space) when building links
  PAGE_LINKS="${PAGE_LINKS}[$(head -n 1 "$page" | sed 's/#//g' | sed 's/^ //')](https://github.com/$GITHUB_REPOSITORY/blob/master/$INPUT_LINK_PAGES/$page) <br> "
done

echo "Linking pages:
$PAGE_LINKS"

GH_PAGE=$(sed "s;LINK_PAGES;$PAGE_LINKS;" "$INPUT_PAGE_PATH")
rm "$INPUT_PAGE_PATH"
echo "$GH_PAGE" > "$INPUT_PAGE_PATH"
