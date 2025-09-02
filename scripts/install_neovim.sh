#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_VERSION=0.10.2
NVIM_TARBALL="nvim-linux64.tar.gz"

# https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
TARBALL_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_TARBALL}"
SHA256SUM_URL="${TARBALL_URL}.sha256sum"

curl -JLO "${SHA256SUM_URL}"
curl -JLO "${TARBALL_URL}"

if sha256sum -c "${NVIM_TARBALL}.sha256sum"; then
  tar xzvf "${NVIM_TARBALL}"
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf "${NVIM_TARBALL}"
  sudo rm -f /usr/local/bin/vim
  sudo ln -s /usr/local/bin/nvim /usr/local/bin/vim
  rm -rf nvim-linux64 "${NVIM_TARBALL}" "${NVIM_TARBALL}.sha256sum"
else
  echo "Checksum failed"
  exit 1
fi