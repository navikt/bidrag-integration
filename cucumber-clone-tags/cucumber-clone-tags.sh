#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet
# - Sjekker at miljøvariabelen WORKFLOW_CREDENTIALS er satt
# - Forventer input: relativ sti til nais apps mappe
# - Går til RUNNER_WORKSPACE. og kloner bidrag-cucumber-backend, (på branch som bygges hvis det er bidrag-cucumber-backen)
# - Setter output (cucumber_path) til hvor dette prosjektet er klonet
# - Oppretter relativ sti til nais apps mappe (under bidrag-cucumber-backend) og går til denne mappa
# - Kloner HEAD til bidragsprosjektene som er tagget i cucumber-features
#
############################################

cd "$RUNNER_WORKSPACE" || exit 1

if [[ -z $WORKFLOW_CREDENTIALS ]]; then
  echo ::error:: "Credentials to clone repositories must be provided, WORKFLOW_CREDENTIALS=<github username>:<github personal access token>"
  exit 1
fi

if [[ $# != 1 ]]; then
  echo ::error:: "Expects nais application folder argument for naming the folder where all nais applications will be stored"
  exit 1
fi

NAIS_APPLICATION_FOLDER=$1

if [[ $GITHUB_REPOSITORY == "navikt/bidrag-cucumber-backend" ]]; then
  BRANCH="${GITHUB_REF#refs/heads/}"
  git clone https://github.com/navikt/bidrag-cucumber-backend
  cd bidrag-cucumber-backend || exit 1
  git checkout ${BRANCH}
else
  git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
  cd bidrag-cucumber-backend || exit 1
fi

echo ::set-output name=cucumber_path::"$PWD"

USE_NAIS_APPS="$(find . -type f -name "*.feature" | xargs cat | grep @bidrag- | grep -v @bidrag-cucumber | sort -u | sed 's/@//')"

mkdir "$NAIS_APPLICATION_FOLDER"
cd "$NAIS_APPLICATION_FOLDER" || exit 1

CLONED_APPS=""

for app in $USE_NAIS_APPS
do
  git clone --depth 1 https://${WORKFLOW_CREDENTIALS}@github.com/navikt/${app}

  if [[ -z "$CLONED_APPS" ]]; then
    CLONED_APPS=$app
  else
    CLONED_APPS+=",$app"
  fi
done

echo ::set-output name=cloned_apps::"$CLONED_APPS"
