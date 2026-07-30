#!/usr/bin/env bash
set -Eeuo pipefail

KEYRING_DIR="/etc/apt/keyrings"
KEYRING_PATH="${KEYRING_DIR}/githubcli-archive-keyring.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/github-cli.list"
KEY_URL="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
REPO_LINE="deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING_PATH}] https://cli.github.com/packages stable main"

if ! command -v wget >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get install -y wget
fi

sudo mkdir -p -m 755 "${KEYRING_DIR}"

tmp_keyring_file="$(mktemp)"
trap 'rm -f "${tmp_keyring_file}"' EXIT

wget -nv -O "${tmp_keyring_file}" "${KEY_URL}"
sudo install -m 644 "${tmp_keyring_file}" "${KEYRING_PATH}"

printf '%s\n' "${REPO_LINE}" | sudo tee "${SOURCE_LIST_PATH}" >/dev/null

sudo apt-get update
sudo apt-get install -y gh
