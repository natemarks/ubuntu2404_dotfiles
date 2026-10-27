#!/usr/bin/env bash
set -Eeuo pipefail
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

KEYRING_DIR="/etc/apt/keyrings"
KEYRING_PATH="${KEYRING_DIR}/microsoft.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/azure-cli.sources"
KEY_URL="https://packages.microsoft.com/keys/microsoft.asc"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

sudo mkdir -p -m 755 "${KEYRING_DIR}"

tmp_keyring_file="$(mktemp)"
trap 'rm -f "${tmp_keyring_file}"' EXIT

curl -fsSL "${KEY_URL}" | gpg --dearmor >"${tmp_keyring_file}"
sudo install -m 644 "${tmp_keyring_file}" "${KEYRING_PATH}"

sudo tee "${SOURCE_LIST_PATH}" >/dev/null <<SOURCES
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: ${KEYRING_PATH}
SOURCES

sudo apt-get update
sudo apt-get install -y azure-cli
# 'install' is a no-op when az is already present; force the upgrade to latest
sudo apt-get install -y --only-upgrade azure-cli
az version
