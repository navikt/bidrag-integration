#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) setter cucumber prosjekt som input og sletter cucumber prosjektet hvis den finnes fra før
# 2a) ved feature branch
#    - clone cucumber-prosjektet, branch=feature (hvis den finnes), hvis ikke brukes main
# 2b) ved main branch
#    - clone cucumber-prosjektet, main branchpus
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 4) klon GITHUB_REPOSITORY i mappa "simple" for at cucumber skal lese nais-konfigurasjon
#
############################################

INPUT_CUCUMBER_PROJECT=$1
INPUT_FOLDER_NAIS_APPS=$2

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

if [[ -z "$GITHUB_TOKEN" ]]; then
  # shellcheck disable=SC2086
  git clone --depth 1 $CLONE_BRANCH https://github.com/$GITHUB_REPOSITORY
else
  # shellcheck disable=SC2086
  git clone --depth 1 $CLONE_BRANCH https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY
fi

cd "$RUNNER_WORKSPACE" || echo "could not enter ws: $RUNNER_WORKSPACE"
find . -type f -name "q*.json"
