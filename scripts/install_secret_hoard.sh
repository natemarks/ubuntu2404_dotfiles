#!/usr/bin/env bash
set -Eeuo pipefail

# Install secret-hoard from latest GitHub release
# https://github.com/natemarks/secret-hoard/releases

REPO="natemarks/secret-hoard"

# Fetch latest release version from GitHub API
LATEST_VERSION=$(curl -sSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "${LATEST_VERSION}" ]; then
    echo "Error: Could not fetch latest version from GitHub" >&2
    exit 1
fi

TARBALL="secret-hoard_${LATEST_VERSION}_linux_amd64.tar.gz"
URL="https://github.com/${REPO}/releases/download/${LATEST_VERSION}/${TARBALL}"

echo "Installing secret-hoard ${LATEST_VERSION}..."

# Create bin directory if it doesn't exist
mkdir -p "${HOME}/bin"

# Download tarball to temp location
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

curl -sSLo "${TEMP_DIR}/${TARBALL}" "${URL}"

# Extract to temp directory first
tar xf "${TEMP_DIR}/${TARBALL}" -C "${TEMP_DIR}"

# Copy all sh-* executables to $HOME/bin (always overwrite)
cp -f "${TEMP_DIR}"/sh-* "${HOME}/bin/"
chmod 755 "${HOME}/bin"/sh-*

echo "Successfully installed secret-hoard ${LATEST_VERSION} to ${HOME}/bin"
echo "Installed executables: sh-contents, sh-generate, sh-pull, sh-push"
