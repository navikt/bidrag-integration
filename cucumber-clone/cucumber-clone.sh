#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) sjekker antall og setter inputs og sletter cucumber prosjektet hvis det finnes fra før
# 2a) ved feature branch
#    - clone cucumber-prosjektet, branch=feature (hvis den finnes), hvis ikke brukes main
# 2b) ved main branch
#    - clone cucumber-prosjektet, main branch
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 4) klon GITHUB_REPOSITORY i mappa "simple" for at cucumber skal lese nais-konfigurasjon
# 5) kloner også eventuelle main brancher til fra extra clones inn i simple mappa
#
############################################

if [[ $# -ne 4 ]]; then
  echo "Bruk: cucumber-clone.sh <cucumber_prosjekt> <folder_nais_apps> [<extra clones>] <delimiter>, see action.yaml (third argument is optional)"
  exit 1;
fi

INPUT_CUCUMBER_PROJECT=$1
INPUT_FOLDER_NAIS_APPS=$2
INPUT_EXTRA_CLONES=$3
INPUT_DELIMITER=$3

cd "$RUNNER_WORKSPACE" || exit 1 # cd til RUNNER_WORKSPACE eller hard exit
sudo rm -rf "$INPUT_CUCUMBER_PROJECT"
BRANCH="${GITHUB_REF#refs/heads/}"

if [[ "$BRANCH" != "main" ]]; then
  FEATURE_BRANCH=$BRANCH
  # shellcheck disable=SC2046
  IS_API_CHANGE=$(git ls-remote --heads $(echo "https://github.com/navikt/$INPUT_CUCUMBER_PROJECT $FEATURE_BRANCH" | sed "s/'//g") | wc -l)

  if [[ $IS_API_CHANGE -eq 1 ]]; then
    echo "Using feature branch: $FEATURE_BRANCH"
    # shellcheck disable=SC2086
    git clone --depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
  else
    echo "Using /refs/heads/main"
    # shellcheck disable=SC2086
    git clone --depth 1 https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
  fi
else
  echo "Using /refs/heads/main"
  # shellcheck disable=SC2086
  git clone --depth 1 https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
fi

# gå til "INPUT_CUCUMBER_PROJECT" slik at json filene blir synlige i docker container når integrasjonstestene kjøres
cd "$INPUT_CUCUMBER_PROJECT" || exit 1;

if [[ "$BRANCH" == "main" ]]; then
  CLONE_BRANCH=""
else
  CLONE_BRANCH="--branch=$BRANCH"
fi

mkdir "$INPUT_FOLDER_NAIS_APPS"
cd "$INPUT_FOLDER_NAIS_APPS" || exit 1;

CREDENTIALS=""

if [[ -n "$GITHUB_TOKEN" ]]; then
  CREDENTIALS="$GITHUB_ACTOR:$GITHUB_TOKEN@"
fi

# shellcheck disable=SC2046
# shellcheck disable=SC2086
git clone $(echo --depth 1 $CLONE_BRANCH https://"$CREDENTIALS"github.com/$GITHUB_REPOSITORY  | sed 's/"//g')

if [[ -n $INPUT_EXTRA_CLONES ]]; then
  IFS=$INPUT_DELIMITER
  read -ra clones <<< "$INPUT_EXTRA_CLONES"

  for clone in "${clones[@]}"; do
        # shellcheck disable=SC2046
        git clone $(echo --depth 1 https://"$CREDENTIALS"github.com/navikt/"$clone" | sed 's/"//g')
  done
fi

cd "$RUNNER_WORKSPACE" || echo "could not enter ws: $RUNNER_WORKSPACE"
find . -type f -name "q*.json"
