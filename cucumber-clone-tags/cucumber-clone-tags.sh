#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet
# - Sjekker at miljøvariabelen WORKFLOW_CREDENTIALS er satt
# - Går til RUNNER_WORKSPACE. og kloner bidrag-cucumber-backend, (på branch som bygges hvis det er bidrag-cucumber-backen)
# - Kloner bidrag-cucumber-backend (bare HEAD når det ikke er bidrag-cucumber-backend som bygges)
# - Kloner HEAD til bidragsprosjektene som er tagget i cucumber-features
#
############################################

cd "$RUNNER_WORKSPACE" || exit 1

if [[ -z $WORKFLOW_CREDENTIALS ]]; then
  echo ::error:: "Credentials to clone repositories must be provided, value: <github username>:<github personal access token>"
  exit 1
fi

if [[ $GITHUB_REPOSITORY == "navikt/bidrag-cucumber-backend" ]]; then
  BRANCH="${GITHUB_REF#refs/heads/}"
  git clone https://github.com/navikt/bidrag-cucumber-backend
  cd bidrag-cucumber-backend || exit 1
  git checkout ${BRANCH}
else
  git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
  cd bidrag-cucumber-backend || exit 1
fi

USE_NAIS_APPS="$(find . -type f -name "*.feature" | xargs cat | grep @bidrag- | grep -v @bidrag-cucumber | sort -u | sed 's/@//')"

mkdir simple
cd simple || exit 1

for app in $USE_NAIS_APPS
do
  git clone --depth 1 https://${WORKFLOW_CREDENTIALS}@github.com/navikt/${app}
done

pwd
ls -al
