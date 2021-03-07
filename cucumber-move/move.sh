#!/bin/bash
set -e

############################################
#
# Følgende forutsetninger for dette skriptet
# - github prosjektets "front-page" beginner seg som "template" fil i rot-mappa til prosjektet
# - github pages befinner seg under mappa docs
# - cucumber.json flyttes til mappe docs/latest/
# - sist genererte cucumber json flyttes under mappe docs/latest/
# - sist genererte html rapport (m/undermapper) flyttesr mappe docs/latest
# - alle genererte html rapporter kopieres til mappa docs/generated/<date or timestamp>
#
# Følgende skjer i dette skriptet:
# 1) setter input
# 2) går til og setter forventet stier til testprosjekt og bidrag-dev ut fra $RUNNER_WORKSPACE
# 3) oppretter generert mappe under docs/generated (oppretter timestampted mappe hvis dato-mappe finnes)
# 4) kopierer generert html til generert mappe
# 5) sletter gamle genererte html mapper rett under docs/latest mappa
# 6) flytter generert html til github pages (docs/latest mappa)
# 7) flytter generert json fil fra input under github pages (docs/latest/<input-fil>)
# 8) oppretter bidrag-dev.json som inneholder data for denne operasjonen
#    - timestamp: tidspunktet for flytting
#    - generated-folder: mappenavnet til den genererte mappa
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

cd "$RUNNER_WORKSPACE" || exit 1
FULL_PATH_TO_GENERATED_TEST_FILES="$RUNNER_WORKSPACE/$INPUT_FOLDER_MOVE_FROM"

if [[ ! -d "$FULL_PATH_TO_GENERATED_TEST_FILES" ]]; then
  echo "Filer som skal flyttes ($INPUT_FOLDER_MOVE_FROM) finnes ikke under $PWD"
  find . -type d | grep -v docs | grep -v .git | grep -v /src/ | grep -v /apps/ | grep -v /test-classes/
  exit 1
fi

FULL_PATH_TO_ROOT_PROJECT="$RUNNER_WORKSPACE/$INPUT_PROJECT_WHERE_TO_MOVE"

if [[  ! -d "$FULL_PATH_TO_ROOT_PROJECT" ]]; then
  echo "Prosjektet som skal ha generert test rapport ($INPUT_PROJECT_WHERE_TO_MOVE) finnes ikke under $PWD"
  find . -type d | grep -v docs | grep -v .git | grep -v /src/ | grep -v /apps/ | grep -v /test-classes/
  exit 1
fi

FULL_PATH_TO_DOCS_LATEST="$FULL_PATH_TO_ROOT_PROJECT/docs/latest"
FULL_PATH_TO_DOCS_GENERATED="$FULL_PATH_TO_ROOT_PROJECT/docs/generated"
FULL_PATH_TO_GENERATED_CUCUMBER_JSON="$RUNNER_WORKSPACE/$INPUT_LATEST_CUCUMBER_JSON"

if [[ ! -f "$FULL_PATH_TO_GENERATED_CUCUMBER_JSON" ]]; then
  echo "Full sti til generert cucumber rapport finnes ikke under $PWD"
  find . -type d | grep -v docs | grep -v .git | grep -v /src/ | grep -v /apps/ | grep -v /test-classes/
  exit 1
fi

GENERATED_FOLDER=$(date +"%Y-%m-%d")

if [[ -d "$FULL_PATH_TO_DOCS_GENERATED/$GENERATED_FOLDER" ]]; then
  GENERATED_FOLDER=$(date +"%Y-%m-%d.%T")
fi

FULL_PATH_TO_GENERATED_FOLDER="$FULL_PATH_TO_DOCS_GENERATED/$GENERATED_FOLDER"

mkdir "$FULL_PATH_TO_GENERATED_FOLDER"

echo "Kopierer generert html og cucumber rapport til $FULL_PATH_TO_GENERATED_FOLDER"
cp -R "$FULL_PATH_TO_MOVE_FOLDER"/* "$FULL_PATH_TO_GENERATED_FOLDER"/.
cp "$FULL_PATH_TO_GENERATED_CUCUMBER_JSON" "$FULL_PATH_TO_GENERATED_FOLDER/."

echo "Flytter generert html og cucumber rapport til $FULL_PATH_TO_DOCS_LATEST"
cd "$FULL_PATH_TO_DOCS_LATEST" && ls | xargs sudo rm -rf # sletter eksisterende rapport
sudo mv "$FULL_PATH_TO_GENERATED_TEST_FILES/* $FULL_PATH_TO_DOCS_LATEST"
sudo mv "$FULL_PATH_TO_GENERATED_CUCUMBER_JSON" "$FULL_PATH_TO_DOCS_LATEST."

TIMESTAMP_JSON="\"timestamp\":\"$( date )\""
FOLDER_JSON="\"foldername\":\"$GENERATED_FOLDER\""
BIDRAG_DEV_JSON="{$TIMESTAMP_JSON,$FOLDER_JSON}"

echo "Oppretter $BIDRAG_DEV_JSON som $FULL_PATH_TO_DOCS_LATEST/bidrag-dev.json"
echo "$BIDRAG_DEV_JSON" > "$FULL_PATH_TO_DOCS_LATEST/bidrag-dev.json"
echo ::set-output name=gresult_json_file::"$FULL_PATH_TO_DOCS_LATEST"

