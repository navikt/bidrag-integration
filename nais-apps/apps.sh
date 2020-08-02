#!/bin/bash
set -x

# funksjon som skriver ut hvordan bruk er
function usage() {
  echo Navngi apps som json: apps.sh '{"apps":["github project","another github project","..."]}'
}

# funksjon som henter ut et github prosjekt for en applikasjon (github prosjekt) uten brukernavn/passord
function checkoutNaisWithoutCredentials() {
  NAIS_APP=$(echo "$1" | sed 's/"//g')

  git clone "$(echo "https://github.com/navikt/$NAIS_APP --no-checkout" | sed "s;';;g")"
  cd "$NAIS_APP" || exit 1

  checkoutNais

  cd ..
}

# funksjon som henter ut et github prosjekt for en applikasjon (github prosjekt) med brukernavn/passord
function checkoutNaisWithCredentials() {
  NAIS_APP=$(echo "$1" | sed 's/"//g')

  git clone "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/navikt/$NAIS_APP --no-checkout"
  cd "$NAIS_APP" || exit 1

  checkoutNais

  cd ..
}

# funksjon for å hente nais/q?.json filer
function checkoutNais() {
  if [[ "$GITHUB_REF" == "refs/heads/master" ]]; then
    git checkout origin/master nais/q0.json
    git checkout origin/master nais/q1.json
  else
    git "checkout $(echo "$GITHUB_REF" | sed 's;refs/heads;origin/;') nais/q0.json"
    git "checkout $(echo "$GITHUB_REF" | sed 's;refs/heads;origin/;') nais/q1.json"
  fi
}

############################################
#
# Følgende forutsetninger for dette skriptet
# - input til skriptet er applikasjonsnavn (github prosjekt navn)
#
# Følgende skjer i dette skriptet:
# 1) sjekker at vi har input argument
# 2) sletter eventuell eksisterende mappe og lager ny mappe som brukes til å hente disse prosjektene
# 3) lagrer input som fil og parser denne som json med jq
# 4) for hvert applikasjonsnavn (github prosjekt)
#    - sjekker ut prosjektet
# 5) setter mappa med <applikasjoner> (full filsti) som output
#
############################################

if [[ $# -ne 1 ]]; then
  usage
  exit 1;
fi

echo "$1" > json
NAIS_APPS=$(jq '.apps[]' json)

if [[ -z "$NAIS_APPS" ]]; then
  usage
  exit 1
fi

if [[ -d nais-apps ]]; then
  sudo rm -rf nais-apps
fi

mkdir nais-apps
cd nais-apps || exit 1

for app in $(echo "$NAIS_APPS")
do
  if [[ -z "$GITHUB_TOKEN" ]]; then
    checkoutNaisWithoutCredentials "$app"
  else
    checkoutNaisWithCredentials "$app"
  fi
done

echo ::set-output name=nais-apps-folder::"$PWD/nais-apps"
