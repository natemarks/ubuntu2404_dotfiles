#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_VERSION="0.11.4"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_DIR="/opt/neovim/${NVIM_VERSION}"
NVIM_BIN="/opt/neovim/${NVIM_VERSION}/nvim-linux-x86_64/bin/nvim"
NVIM_LINK="${HOME}/bin/nv"

TARBALL_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_TARBALL}"
SHA256SUM_URL="${TARBALL_URL}.sha256sum"

if [ -d "${NVIM_INSTALL_DIR}" ]; then
  echo "install dir exists: ${NVIM_INSTALL_DIR}. exiting"
  exit
fi

curl -JLO "${TARBALL_URL}"
echo "a74740047e73b2b380d63a474282814063d10650cd6cc95efa16d1713c7e616c ${NVIM_TARBALL}" > "${NVIM_TARBALL}.sha256sum"

if sha256sum -c "${NVIM_TARBALL}.sha256sum"; then
  sudo mkdir -p "$NVIM_INSTALL_DIR"
  tar xzvf "${NVIM_TARBALL}"
  sudo tar -C "${NVIM_INSTALL_DIR}" -xzf "${NVIM_TARBALL}"
  rm -f "${NVIM_LINK}"
  ln -s "${NVIM_BIN}" "${NVIM_LINK}"
  ls -la "${NVIM_LINK}"
else
  echo "Checksum failed"
  exit 1
fi
rm -rf nvim-linux64 "${NVIM_TARBALL}" "${NVIM_TARBALL}.sha256sum"
