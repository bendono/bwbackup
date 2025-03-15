#!/bin/bash

# Bitwarden CLI vault export
# Author: Ben
# Date: 2024/02/20

export BW_CLIENTID="$1"
export BW_CLIENTSECRET="$2"
export BW_PASSWORD="$3"
export BW_ENC_PW="$4"
export EXPORT_PATH="$5"
EXPORT_FILE=vault_enc.json

mkdir -p "${EXPORT_PATH}"

# Check whether jq is installed.
if [ ! -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.'
  exit 1
fi

# Check whether bw CLI is available.
if [ ! -f ./bw ]; then
  echo 'bw does not exist. Downloading...'
  curl -JLs "https://vault.bitwarden.com/download/?app=cli&platform=linux" -o bw.zip
  unzip -oq bw.zip
  rm bw.zip
  chmod +x ./bw
fi

# Check whether already logged in.
if ./bw login --check > /dev/null 2>&1; then
  ./bw logout > /dev/null
fi

# Login and unlock
{ ./bw login --apikey > /dev/null; } 2>&1
BW_SESSION=$(./bw unlock --passwordenv BW_PASSWORD --raw)
export BW_SESSION

# Export vault
./bw export --format encrypted_json --password "${BW_ENC_PW}" --output "${EXPORT_PATH}/${EXPORT_FILE}"

# Check for attachments
if [[ $(./bw list items | jq -r '.[] | select(.attachments != null)') != "" ]]; then
  bash <(./bw list items | jq -r '.[] | select(.attachments != null)
    | . as $parent | .attachments[]
    | "./bw get attachment \(.id) --itemid \($parent.id) --output \"$EXPORT_PATH/attachments/\($parent.name)/\(.fileName)\""')
fi

# Check for organizations
if [[ $(./bw list organizations | jq -r '.[]') != "" ]]; then
  bash <(./bw list organizations | jq -r '.[] 
    | "./bw export --organizationid \"\(.id)\" --format encrypted_json --password $BW_ENC_PW --output \"$EXPORT_PATH/org/\(.name)/org_enc.json\""')
fi

{ ./bw logout > /dev/null; } 2>&1

# Remove exported variables
unset BW_CLIENTID
unset BW_CLIENTSECRET
unset BW_PASSWORD
unset BW_SESSION
