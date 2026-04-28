#!/usr/bin/env bash
set -Eeuo pipefail

URL="${1:-https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.9/zoxide_0.9.9-1_amd64.deb}"
DEB_PATH="$(mktemp /tmp/zoxide.XXXXXX.deb)"

cleanup() {
  rm -f "${DEB_PATH}"
}

trap cleanup EXIT

curl -fsSL "${URL}" -o "${DEB_PATH}"
sudo dpkg -i "${DEB_PATH}" || sudo apt-get install -f -y
