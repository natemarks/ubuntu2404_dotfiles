#!/usr/bin/env bash
set -Eeuo pipefail

# Script to install eamhybridcerts utilities from GitHub releases
# Always fetches the latest version and overwrites existing installation
# Requires: gh (GitHub CLI)

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh (GitHub CLI) is required but not installed" >&2
  exit 1
fi

REPO="imprivata-cloud/eamhybridcerts"
PACKAGE_NAME="eamhybridcerts"
PLATFORM="linux_amd64"
INSTALL_DIR="${HOME}/bin"

# Binaries included in the release
BINARIES=("hclookup" "hcrestore" "hcrenew")

# Fetch the latest release tag
echo "Fetching latest release version..."
LATEST_VERSION=$(gh release view --repo "${REPO}" --json tagName --jq '.tagName')

if [[ -z "${LATEST_VERSION}" ]]; then
  echo "ERROR: Could not determine latest version" >&2
  exit 1
fi

echo "Latest version: ${LATEST_VERSION}"

# Construct tarball name
TARBALL="${PACKAGE_NAME}_${LATEST_VERSION}_${PLATFORM}.tar.gz"

# Remove existing installations
for binary in "${BINARIES[@]}"; do
  if [[ -f "${INSTALL_DIR}/${binary}" ]]; then
    echo "Removing existing ${binary} at ${INSTALL_DIR}/${binary}"
    rm -f "${INSTALL_DIR}/${binary}"
  fi
done

# Create install directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Create temporary directory for download
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${TARBALL}"
gh release download "${LATEST_VERSION}" --repo "${REPO}" --pattern "${TARBALL}" --dir "${tmpdir}"

# Extract all files
echo "Extracting binaries"
tar xzf "${tmpdir}/${TARBALL}" -C "${tmpdir}"

# Install each binary
for binary in "${BINARIES[@]}"; do
  if [[ -f "${tmpdir}/${binary}" ]]; then
    install -m 0755 "${tmpdir}/${binary}" "${INSTALL_DIR}/${binary}"
    echo "Installed ${binary} to ${INSTALL_DIR}/${binary}"
  else
    echo "WARNING: ${binary} not found in archive" >&2
  fi
done

echo "Successfully installed eamhybridcerts ${LATEST_VERSION} utilities to ${INSTALL_DIR}"
