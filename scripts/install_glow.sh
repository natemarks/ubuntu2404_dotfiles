#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/charmbracelet/glow

KEYRING_DIR="/etc/apt/keyrings"
KEYRING_PATH="${KEYRING_DIR}/charm.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/charm.list"
KEY_URL="https://repo.charm.sh/apt/gpg.key"
REPO_LINE="deb [signed-by=${KEYRING_PATH}] https://repo.charm.sh/apt/ * *"

sudo mkdir -p "${KEYRING_DIR}"

if [ ! -f "${KEYRING_PATH}" ]; then
  curl -fsSL "${KEY_URL}" | sudo gpg --dearmor -o "${KEYRING_PATH}"
fi

if [ ! -f "${SOURCE_LIST_PATH}" ]; then
  printf '%s\n' "${REPO_LINE}" | sudo tee "${SOURCE_LIST_PATH}" >/dev/null
fi

sudo apt-get update
sudo apt-get install -y glow
