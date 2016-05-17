#!/bin/sh

# exit immediately when error.
set -eu

WORKDIR="/tmp"

XCODEGENERATECONSTRAINTS="XcodeGenerateConstants"
XCODEGENERATECONSTRAINTS_GIT="https://github.com/EZ-NET/${XCODEGENERATECONSTRAINTS}.git"
XCODEGENERATECONSTRAINTS_WORKINGCOPIES="${WORKDIR}/CodePiece.${XCODEGENERATECONSTRAINTS}"
XCODEGENERATECONSTRAINTS_BIN="${XCODEGENERATECONSTRAINTS}"

CLIENTINFO_FILE="CodePieceClientInfo.plist"
CLIENTINFO_PATH="${HOME}/Library/XcodeGenerateConstants/${CLIENTINFO_FILE}"


function SetupXcodeGenerateConstants() {

	if [ `which "${XCODEGENERATECONSTRAINTS_BIN}"` ]
	then

		echo "'${XCODEGENERATECONSTRAINTS}' is already installed."
		echo

	else

		echo "Cloning '${XCODEGENERATECONSTRAINTS_GIT}' ..."
		git clone "${XCODEGENERATECONSTRAINTS_GIT}" "${XCODEGENERATECONSTRAINTS_WORKINGCOPIES}" || git -C "${XCODEGENERATECONSTRAINTS_WORKINGCOPIES}" pull

		echo

		echo "Installing '${XCODEGENERATECONSTRAINTS_BIN}' ..."
		sudo make -C "${XCODEGENERATECONSTRAINTS_WORKINGCOPIES}" install

		echo

	fi
}

function MakeCodePieceClientInfo() {

	echo
	echo "Checking '${CLIENTINFO_PATH}' ..."

	if [ -f "${CLIENTINFO_PATH}" ]
	then

		echo "'${CLIENTINFO_PATH}' is already exists."
		echo

	else

		echo "Creating new '${CLIENTINFO_PATH}' file."
		echo

		cat << EOT >> "${CLIENTINFO_PATH}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>GitHubClientID</key>
<string></string>
<key>GitHubClientSecret</key>
<string></string>
<key>TwitterConsumerKey</key>
<string></string>
<key>TwitterConsumerSecret</key>
<string></string>
</dict>
</plist>
EOT

	fi

	echo
	echo "Open '${CLIENTINFO_PATH}' file."
	open "${CLIENTINFO_PATH}"
}

# Start Installing If Need.

SetupXcodeGenerateConstants
MakeCodePieceClientInfo

echo "DONE."
