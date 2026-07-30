#!/usr/bin/env bash
set -Eeuo pipefail

# Fetch latest mise version from GitHub API
LATEST_VERSION=$(curl -sSL https://api.github.com/repos/jdx/mise/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
VERSION="${LATEST_VERSION#v}"  # Strip 'v' prefix if present

EXECUTABLE="mise"
PLATFORM="linux-x64"
ARCHIVE="${EXECUTABLE}-v${VERSION}-${PLATFORM}.tar.gz"
URL="https://github.com/jdx/mise/releases/download/v${VERSION}/${ARCHIVE}"

INSTALL_DIR="${HOME}/bin"
INSTALL_PATH="${INSTALL_DIR}/${EXECUTABLE}"

mkdir -p "${INSTALL_DIR}"

tmpdir="$(mktemp -d)"
archive_path="${tmpdir}/${ARCHIVE}"

cleanup() {
  rm -rf "${tmpdir}"
}

trap cleanup EXIT

echo "Downloading mise ${VERSION} from ${URL}"
curl -fsSL "${URL}" -o "${archive_path}"

echo "Extracting ${ARCHIVE}"
tar -xzf "${archive_path}" -C "${tmpdir}"

# Always overwrite existing installation
echo "Installing ${EXECUTABLE} to ${INSTALL_PATH}"
install -m 0755 "${tmpdir}/${EXECUTABLE}/bin/${EXECUTABLE}" "${INSTALL_PATH}"

echo "Successfully installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
"${INSTALL_PATH}" --version
