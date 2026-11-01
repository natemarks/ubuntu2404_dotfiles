#!/usr/bin/env bash
set -Eeuo pipefail

# Install (or upgrade) Google Chrome from Google's official apt repository.
# https://www.google.com/linux/chrome/ - Google only publishes amd64 builds.

KEYRING=/etc/apt/keyrings/google-chrome.gpg
SOURCE_LIST=/etc/apt/sources.list.d/google-chrome.list

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "Error: Google Chrome is only published for amd64" >&2
  exit 1
fi

# always rewrite the key so a rotated signing key is picked up on re-run
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub |
  sudo gpg --dearmor --yes -o "$KEYRING"

# write the source ourselves so the package's own repo setup doesn't create a
# duplicate entry with a different signed-by path
echo "deb [arch=amd64 signed-by=${KEYRING}] https://dl.google.com/linux/chrome/deb/ stable main" |
  sudo tee "$SOURCE_LIST" > /dev/null

sudo apt-get update
sudo apt-get install -y google-chrome-stable

# 'install' is a no-op when chrome is already present; force the upgrade to latest
sudo apt-get install -y --only-upgrade google-chrome-stable
