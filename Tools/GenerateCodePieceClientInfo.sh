#!/bin/sh

CLIENTINFO="CodePieceClientInfo"
CLIENTINFO_FILE="${CLIENTINFO}.plist"
CLIENTINFO_DESTINATION_DIR="/private/tmp"

echo "Generating '${CLIENTINFO_FILE}' ..."
/usr/local/bin/XcodeGenerateConstants "${CLIENTINFO}" "${CLIENTINFO_DESTINATION_DIR}"
