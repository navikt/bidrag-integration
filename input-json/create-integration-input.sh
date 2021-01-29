#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet
# - forventer og setter input:
#   > komma separert liste med applikasjonene som det skal hentes azure input for (blir transformert til en array av navn)
#   > relative path to where to store the json file
#   > nais project folder (path til hvor nais prosjekt(et/ene) som testes har sin nais konfigurasjon
#   > test brukerens brukernavn
# - lager mappa json som brukes til å lagre all azure input til disse applikasjonene
# - setter variabel som sier om det er main eller feature branch
# - for hvert navn i "array":
#   1) legg på applikasjonsnavnet "-feature" når det er en feature branch som kjøres.
#   2) når denne applikasjonen finnes
#     - så brukes kubernetes til å hente følgende azure info: CLIENT_ID, TENANT_ID og CLIENT_SECRET
#     - bruk jq til å lagre denne azure informasjonen som json inn i json mappa
# - leser hver fil som er laget med azure informasjon og legger denne informasjonen sammen med input som
#   brukes i bidrag-cucumber-nais og lagrer dette til fila integrationInput.json
# - returnerer full sti til denne fila
#
############################################

if [[ $# -ne 4 ]]; then
  echo "Usage: ./createAzureInput.sh <application-1,...application-x> <json/integrationInput.json> </path/to/nais/projects> <test user name>"
  echo "     - 1: names of possible azure applications separated by comma: azure-app-1.azure-app-2,...azure-app-x"
  echo "     - 2: relative path to integrationInput.json"
  echo "     - 3: expected path of where all the projects with nais configuration are located"
  echo "     - 4: the username of the test user"
  exit 1
fi

INPUT_NAMES=( $(echo "$1" | sed 's/,/ /g') )
INPUT_JSON_RELATIVE_PATH=$2
INPUT_NAIS_PROJECT_FOLDER=$3
INPUT_TEST_USERNAME=$4

# expects that this is action will run on a runner for bidrag-cucumber-backend
cd "$GITHUB_WORKSPACE/bidrag-cucumber-backend"
PATH_TO_CUCUMBER=$( pwd )

# fjerner filnavn (altså alt etter siste /) og lager en array av foldernavn (det mellom gjenstående /)
RELATIVE_PATH=( $(echo $INPUT_JSON_RELATIVE_PATH | sed 's|\(.*\)/.*|\1|' | tr '/' ' ' ) )

for folder in $RELATIVE_PATH
do
  mkdir $folder
  cd $folder
done

if [[ $GITHUB_REF == "refs/heads/main" ]]; then
  BRANCH="main"
else
  BRANCH="feature"
fi

for name in "${INPUT_NAMES[@]}"
do

  KUBE_APP=$name

  if [[ $BRANCH == "feature" ]]; then
    KUBE_APP+="-feature"
  fi

  AZURE_APP="$(kubectl get azureapp -n bidrag $KUBE_APP || true)"

  if [[ -n "$AZURE_APP" ]]; then
    CLIENT_ID="$(echo "$AZURE_APP" | grep -v NAME | awk '{print $3}')"
    TENANT_ID="$(kubectl get secret -n bidrag $(kubectl get azureapp -n bidrag $KUBE_APP -ojson | \
                     jq -r '.spec.secretName') -ojson | jq -r '.data.AZURE_APP_TENANT_ID' | base64 -d)"
    CLIENT_SECRET="$(kubectl get secret -n bidrag $(kubectl get azureapp -n bidrag $KUBE_APP -ojson | \
                     jq -r '.spec.secretName') -ojson | jq -r '.data.AZURE_APP_CLIENT_SECRET' | base64 -d)"

    JSON_STRING=$( jq -n \
                  --arg nme "$KUBE_APP" \
                  --arg cid "$CLIENT_ID" \
                  --arg cls "$CLIENT_SECRET" \
                  --arg tid "$TENANT_ID" \
                  '{name: $nme, clientId: $cid, clientSecret: $cls, tenant: $tid}' )

    echo "$JSON_STRING" > "$KUBE_APP.json"
  fi
done

AZURE_INPUTS=""

for file in $( ls *.json )
do
  if [[ -z "$AZURE_INPUTS" ]]; then
    AZURE_INPUTS="$(cat $file)"
  else
    AZURE_INPUTS+=",$(cat $file)"
  fi
done

cd $PATH_TO_CUCUMBER

echo "{
  \"azureInputs\":[$AZURE_INPUTS],
  \"environment\":\"$BRANCH\",
  \"naisProjectFolder\":\"$INPUT_NAIS_PROJECT_FOLDER\",
  \"userTest\":\"$INPUT_TEST_USERNAME\"
}
" > $INPUT_JSON_RELATIVE_PATH

cat $INPUT_JSON_RELATIVE_PATH
