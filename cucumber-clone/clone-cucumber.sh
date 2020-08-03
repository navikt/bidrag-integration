#!/bin/bash
set -x

############################################
#
# Følgende skjer i dette skriptet:
# 1) sletter bidrag-cucumber-backend hvis den finnes fra før
# 2a) ved feature branch
#    - clone bidrag-cucumber-backend, branch=feature (hvis den finnes), hvis ikke brukes master
# 2b) ved master branch
#    - clone bidrag-cucumber-backend master
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen (passord for nav-bruker og testbrukere)
# 4) klon GITHUB_REPOSITORY i mappa "simple" for at cucumber skal lese nais-konfigurasjon
#
############################################

sudo rm -rf bidrag-cucumber-backend
BRANCH="${GITHUB_REF#refs/heads/}"

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
  FEATURE_BRANCH=$BRANCH
  # shellcheck disable=SC2046
  IS_API_CHANGE="$(git ls-remote --heads $(echo "https://github.com/navikt/bidrag-cucumber-backend $FEATURE_BRANCH" | sed "s/'//g") | wc -l)"

  if [[ $IS_API_CHANGE -eq 1 ]]; then
    echo "Using feature branch: $FEATURE_BRANCH"
    # shellcheck disable=SC2086
    git clone "--depth 1 --branch=$FEATURE_BRANCH https://github.com/navikt/bidrag-cucumber-backend"
  else
    echo "Using /refs/heads/master"
    git clone "--depth 1 https://github.com/navikt/bidrag-cucumber-backend"
  fi
else
  echo "Using /refs/heads/master"
  git clone "--depth 1 https://github.com/navikt/bidrag-cucumber-backend"
fi

# gå til bidrag-cucumber-backend slik at json filene blir synlige i docker container når integrasjonstestene gjøres
cd bidrag-cucumber-backend || exit 1;

if [[ "$BRANCH" == "master" ]]; then
  CLONE_BRANCH=""
else
  CLONE_BRANCH="--branch=$BRANCH"
fi

SIMPLE="$PWD/simple"

sudo rm -rf "$SIMPLE"
mkdir "$SIMPLE"
cd "$SIMPLE" || exit 1;

if [[ -z "$GITHUB_TOKEN" ]]; then
  git clone "--depth 1 $CLONE_BRANCH https://github.com/$GITHUB_REPOSITORY"
else
  git clone "--depth 1 $CLONE_BRANCH https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
fi

find . -type f -name "q*.json"
