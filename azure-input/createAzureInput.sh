#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet
# - forventer input: en komma separert liste med applikasjonene som det skal hentes azure input for
# - lager en "array" av alle applikasjonsnavnene
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

if [[ $# -ne 1 ]]; then
  echo "Usage: ./createAzureInput.sh <azure-app-1,azure-app-2...,azure-app-x>"
  echo "     - argument: create a path where azure-app-1.json ... azure-app-x.json are saved. Applications not secured with azure are skipped"
  exit 1
fi

NAMES=( $(echo "$1" | sed 's/,/ /g') )

JSON_FOLDER="json"
mkdir "$JSON_FOLDER" || true

if [[ $GITHUB_REF == "refs/heads/main" ]]; then
  BRANCH="main"
else
  BRANCH="feature"
fi

for name in "${NAMES[@]}"
do

  KUBE_APP=$name

  if [[ $BRANCH == "feature" ]]; then
    KUBE_APP+="-feature"
  fi

  echo ::info::" Get azureapp on $BRANCH-branch: $KUBE_APP"

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

    echo "$JSON_STRING" > "$JSON_FOLDER/$KUBE_APP.json"
  fi
done

cd "$JSON_FOLDER"

AZURE_INPUTS=""

for file in $( ls *.json )
do
  if [[ -z "$AZURE_INPUTS" ]]; then
    AZURE_INPUTS="$(cat $file)"
  else
    AZURE_INPUTS+=",$(cat $file)"
  fi
done

echo "{
  \"azureInputs\":[
$AZURE_INPUTS
  ],
  \"environment\":\"$BRANCH\",
  \"naisProjectFolder\":\"src/test/resources\",
  \"userTest\":\"z104364\"
}
" > integrationInput.json

echo ::set-output name=integration_input_path::"$PWD/integrationInput.json"
