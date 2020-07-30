#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - filsti til fil smm endres under er rot katalogen til "github pages" (eks: fila docs/index.md for master branch i bidrag-dev)
# - alle automatisk genererte rapporter som skal linkes ligger under mappa "generated" som finnes direkte under rotkatalogen til "github pages"
#
# Følgende skjer i dette skriptet:
# 1) feiler hvis det ikke er forventet antall parametre (2 stk)
# 2) setter input (addresse til "github pages" for prosjektet og full filsti under rotkatalgen til "github markdown page" som skal endres)
#    - eks: <https://navikt.github.io/bidrag-dev> og </.../docs/index.md>
# 3) lager full sti til github pages ved å fjerne alt fra og med siste slash (/) i "github markdown page", eks på resultat: /.../docs
# 4) går inn i katalogen hvor alle genererte integrasjonstester befinner seg, eks: /.../docs/generated
# 5) legger til linker for alle genererte rapporter til fila som skal endres
#    - eks: /.../docs/index.md får link per generete rapport i /.../docs/generated/<dato-tid>
#
############################################

if [[ $# -ne 2 ]]; then
  echo "Bruk: report.sh <{organisasjon}.github.io/{prosjekt}> <github markdown page to edit>"
  exit 1;
fi

INPUT_PAGES_ADDRESS=$1
INPUT_PATH_TO_GITHUB_PAGE=$2
FULL_PATH_TO_FOLDER_FOR_GITHUB_PAGES=${INPUT_PATH_TO_GITHUB_PAGE%/*} # fjerner alt etter siste slash (/) i filstien

cd "$FULL_PATH_TO_FOLDER_FOR_GITHUB_PAGES/generated" || exit 1;

for folder in $(ls -d -r */); do
  echo "lager link til $folder..."
  FOLDER_NAME=$(echo "$folder" | sed 's;/;;')
  echo "Tests at [$FOLDER_NAME]($INPUT_PAGES_ADDRESS/generated/$folder) <br>" >> "$INPUT_PATH_TO_GITHUB_PAGE"
done
