#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1a) sjekker antall inputs, samt setter inputs og sletter cucumber prosjektet hvis det finnes fra før
# 1b) sjekker at miljøvariabelen EXTRA_CLONES_CREDENTIALS er oppgitt
# 2a) ved feature branch
#    - clone cucumber-prosjektet, branch=feature (hvis den finnes), hvis ikke brukes main
# 2b) ved main branch
#    - clone cucumber-prosjektet, main branch
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 4) klon INPUT_CUCUMBER_PROJECT til mappa GITHUB_WORKSPACE
# 5) lag "output" for denne mappa for hvor INPUT_CUCUMBER_PROJECT er i filsystemet
# 6) klon INPUT_FOLDER_NAIS_APPS for at cucumber skal lese nais-konfigurasjon
# 5) kloner også eventuelle main brancher til fra extra clones inn i denne mappa
#
############################################

if [[ $# -ne 4 ]]; then
  echo "Bruk: cucumber-clone.sh <cucumber_prosjekt> <folder_nais_apps> <delimiter> [<extra clones>], see action.yaml (last argument is optional)"
  exit 1;
fi

INPUT_CUCUMBER_PROJECT=$1
INPUT_FOLDER_NAIS_APPS=$2
INPUT_DELIMITER=$3
INPUT_EXTRA_CLONES=$4

if [[ -n $INPUT_EXTRA_CLONES ]]; then
  if [[ -z $EXTRA_CLONES_CREDENTIALS ]]; then
    echo ::error:: "Credentials to clone external repository must be provided, value: <github username>:<github personal access token>"
    exit 1
  fi
fi

cd "$RUNNER_WORKSPACE" || exit 1 # cd til RUNNER_WORKSPACE eller hard exit
sudo rm -rf "$INPUT_CUCUMBER_PROJECT"
BRANCH="${GITHUB_REF#refs/heads/}"

if [[ "$BRANCH" != "main" ]]; then
  FEATURE_BRANCH=$BRANCH
  # shellcheck disable=SC2046
  IS_API_CHANGE=$(git ls-remote --heads $(echo "https://github.com/navikt/$INPUT_CUCUMBER_PROJECT $FEATURE_BRANCH" | sed "s/'//g") | wc -l)

  if [[ $IS_API_CHANGE -eq 1 ]]; then
    echo "Using feature branch: $FEATURE_BRANCH, cloning to $PWD"
    # shellcheck disable=SC2086
    git clone --depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
  else
    echo "Using /refs/heads/main, cloning to $PWD"
    # shellcheck disable=SC2086
    git clone --depth 1 https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
  fi
else
  echo "Using /refs/heads/main, cloning to $PWD"
  # shellcheck disable=SC2086
  git clone --depth 1 https://github.com/navikt/$INPUT_CUCUMBER_PROJECT
fi

# gå til "INPUT_CUCUMBER_PROJECT" slik at json filene blir synlige i docker container når integrasjonstestene kjøres
cd "$INPUT_CUCUMBER_PROJECT" || exit 1;
echo ::set-output name=cucumber_path::"$PWD"

if [[ "$BRANCH" == "main" ]]; then
  CLONE_BRANCH=""
else
  CLONE_BRANCH="--branch=$BRANCH"
fi

mkdir "$INPUT_FOLDER_NAIS_APPS"
cd "$INPUT_FOLDER_NAIS_APPS" || exit 1;

CREDENTIALS=""

if [[ -n "$GITHUB_TOKEN" ]]; then
  CREDENTIALS="${GITHUB_ACTOR}:${GITHUB_TOKEN}@"
fi

echo "cloning head of $GITHUB_REPOSITORY, branch=$BRANCH"
# shellcheck disable=SC2046
# shellcheck disable=SC2086
git clone --depth 1 ${CLONE_BRANCH} https://${CREDENTIALS}github.com/${GITHUB_REPOSITORY}

if [[ -n $INPUT_EXTRA_CLONES ]]; then
  IFS=$INPUT_DELIMITER
  read -ra clones <<< "$INPUT_EXTRA_CLONES"

  for clone in "${clones[@]}"; do
    # shellcheck disable=SC2086
    git clone --depth 1 --branch=main https://${EXTRA_CLONES_CREDENTIALS}@github.com/navikt/${clone}
  done
fi
