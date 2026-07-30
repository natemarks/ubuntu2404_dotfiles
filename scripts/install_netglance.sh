#!/usr/bin/env bash
set -Eeuo pipefail

EXECUTABLE="netglance"
INSTALL_DIR="${HOME}/bin"
INSTALL_PATH="${INSTALL_DIR}/${EXECUTABLE}"

# Fetch latest release version from GitHub API
echo "Fetching latest release version..."
VERSION=$(curl -fsSL "https://api.github.com/repos/natemarks/netglance/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [[ -z "${VERSION}" ]]; then
  echo "ERROR: Failed to fetch latest version" >&2
  exit 1
fi

# https://github.com/natemarks/netglance/releases/download/v0.0.5/netglance-0.0.5-linux-x86_64
BINARY="${EXECUTABLE}-${VERSION}-linux-x86_64"
URL="https://github.com/natemarks/netglance/releases/download/v${VERSION}/${BINARY}"

mkdir -p "${INSTALL_DIR}"

# Always overwrite with latest version
echo "Downloading ${URL}"
curl -fsSL "${URL}" -o "${INSTALL_PATH}"
chmod +x "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
