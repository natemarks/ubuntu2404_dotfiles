#!/usr/bin/env bash
set -Eeuo pipefail

INSTALLER=~/Downloads/awscli-exe-linux-x86_64.zip
UNZIP_DIR="$(mktemp -d -t deleteme.XXXXXX)"
rm -f "${INSTALLER}"
curl -o "${INSTALLER}" -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip "${INSTALLER}" -d "${UNZIP_DIR}"
"${UNZIP_DIR}/aws/install"
