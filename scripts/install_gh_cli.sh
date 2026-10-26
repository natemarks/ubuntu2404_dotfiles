#!/usr/bin/env bash
set -Eeuo pipefail

KEYRING_DIR="/etc/apt/keyrings"
KEYRING_PATH="${KEYRING_DIR}/githubcli-archive-keyring.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/github-cli.list"
PREFERENCES_PATH="/etc/apt/preferences.d/github-cli"
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

# Ubuntu (universe/ESM) ships an old gh at priority 510, which beats the
# default 500 of cli.github.com. Pin the official repo higher so it wins.
printf 'Package: gh\nPin: origin cli.github.com\nPin-Priority: 1001\n' |
	sudo tee "${PREFERENCES_PATH}" >/dev/null

sudo apt-get update
sudo apt-get install -y gh
# 'install' is a no-op when gh is already present; force the upgrade to latest
sudo apt-get install -y --only-upgrade gh
gh --version
