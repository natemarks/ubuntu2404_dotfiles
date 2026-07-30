#!/usr/bin/env bash
set -Eeuo pipefail

# Fetch latest gitleaks version from GitHub API
echo "Fetching latest release version..."
VERSION=$(curl -fsSL "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [[ -z "${VERSION}" ]]; then
  echo "ERROR: Failed to fetch latest version" >&2
  exit 1
fi

EXECUTABLE="gitleaks"
TARBALL="${EXECUTABLE}_${VERSION}_linux_x64.tar.gz"
URL="https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/${TARBALL}"
INSTALL_DIR="${HOME}/bin"

mkdir -p "${INSTALL_DIR}"

# Create temporary directory for download
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# Always overwrite - remove existing binary first
rm -f "${INSTALL_DIR}/${EXECUTABLE}"

echo "Downloading ${URL}"
curl -fsSL "${URL}" -o "${tmpdir}/${TARBALL}"

echo "Extracting ${EXECUTABLE}"
tar xzf "${tmpdir}/${TARBALL}" -C "${tmpdir}" "${EXECUTABLE}"

# Install the binary
install -m 0755 "${tmpdir}/${EXECUTABLE}" "${INSTALL_DIR}/${EXECUTABLE}"

echo "Successfully installed ${EXECUTABLE} ${VERSION} to ${INSTALL_DIR}/${EXECUTABLE}"
"${INSTALL_DIR}/${EXECUTABLE}" version
