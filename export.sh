#!/bin/bash

# Bitwarden CLI vault export
# Author: Ben
# Date: 2024/02/20
#       2024/03/02

TIMESTAMP=$(date +%Y%m%d%S)
BW_CLIENTID='<client id>'
BW_CLIENTSECRET='<client secret>'
BW_PASSWORD='<master password'
BW_ENC_PW='encryption password'
EXPORT_PATH="backups/${TIMESTAMP}/<user>"

./_export.sh "$BW_CLIENTID" "$BW_CLIENTSECRET" "$BW_PASSWORD" "$BW_ENC_PW" "$EXPORT_PATH"
