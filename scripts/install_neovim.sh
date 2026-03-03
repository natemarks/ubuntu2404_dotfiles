#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_VERSION="0.11.6"
NVIM_SHA256SUM="2fc90b962327f73a78afbfb8203fd19db8db9cdf4ee5e2bef84704339add89cc"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_DIR="/opt/neovim/${NVIM_VERSION}"
NVIM_BIN="/opt/neovim/${NVIM_VERSION}/nvim-linux-x86_64/bin/nvim"
NVIM_LINK="${HOME}/bin/nv"

TARBALL_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_TARBALL}"
SHA256SUM_URL="${TARBALL_URL}.sha256sum"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/helper.sh"

if [ -d "${NVIM_INSTALL_DIR}" ]; then
  echo "install dir exists: ${NVIM_INSTALL_DIR}. exiting"
  exit
fi

curl -JLO "${TARBALL_URL}"
check_sha256 "${NVIM_TARBALL}" "${NVIM_SHA256SUM}"
sudo mkdir -p "$NVIM_INSTALL_DIR"
sudo tar -C "${NVIM_INSTALL_DIR}" -xzf "${NVIM_TARBALL}"
rm -f "${NVIM_LINK}"
ln -s "${NVIM_BIN}" "${NVIM_LINK}"
ls -la "${NVIM_LINK}"
rm -rf nvim-linux64 "${NVIM_TARBALL}" "${NVIM_TARBALL}.sha256sum"
