#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_VERSION="0.12.3"
NVIM_SHA256SUM="c441b547142860bf01bcce39e36cbed185c41112813e15443b16e5237750724d"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_DIR="${HOME}/local/nvim-${NVIM_VERSION}"
NVIM_BIN="${NVIM_INSTALL_DIR}/nvim-linux-x86_64/bin/nvim"
NVIM_LINK="${HOME}/bin/nv"

# Man and share directories
NVIM_SHARE_DIR="${NVIM_INSTALL_DIR}/nvim-linux-x86_64/share"
LOCAL_SHARE_DIR="${HOME}/.local/share"
LOCAL_MAN_DIR="${HOME}/.local/share/man"

TARBALL_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_TARBALL}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/helper.sh"

if [ -d "${NVIM_INSTALL_DIR}" ]; then
  echo "install dir exists: ${NVIM_INSTALL_DIR}. exiting"
  exit
fi

echo "Installing neovim ${NVIM_VERSION} to ${NVIM_INSTALL_DIR}"

# Download and verify tarball
curl -JLO "${TARBALL_URL}"
check_sha256 "${NVIM_TARBALL}" "${NVIM_SHA256SUM}"

# Extract to versioned directory in ~/local
mkdir -p "${HOME}/local"
tar -C "${HOME}/local" -xzf "${NVIM_TARBALL}"
mv "${HOME}/local/nvim-linux-x86_64" "${NVIM_INSTALL_DIR}"

# Create ~/bin/nv symlink
rm -f "${NVIM_LINK}"
ln -s "${NVIM_BIN}" "${NVIM_LINK}"
echo "Created symlink: ${NVIM_LINK} -> ${NVIM_BIN}"

# Create ~/.local/share directory if it doesn't exist
mkdir -p "${LOCAL_SHARE_DIR}"

# Symlink man pages
if [ -d "${NVIM_SHARE_DIR}/man" ]; then
  mkdir -p "${LOCAL_MAN_DIR}"
  for mandir in "${NVIM_SHARE_DIR}/man"/*; do
    if [ -d "$mandir" ]; then
      section=$(basename "$mandir")
      mkdir -p "${LOCAL_MAN_DIR}/${section}"
      for manpage in "$mandir"/*; do
        if [ -f "$manpage" ]; then
          manfile=$(basename "$manpage")
          rm -f "${LOCAL_MAN_DIR}/${section}/${manfile}"
          ln -s "$manpage" "${LOCAL_MAN_DIR}/${section}/${manfile}"
        fi
      done
    fi
  done
  echo "Symlinked man pages to ${LOCAL_MAN_DIR}"
fi

# Symlink other share resources (icons, applications, etc.)
for item in "${NVIM_SHARE_DIR}"/*; do
  if [ -d "$item" ] && [ "$(basename "$item")" != "man" ]; then
    itemname=$(basename "$item")
    rm -f "${LOCAL_SHARE_DIR}/${itemname}"
    ln -s "$item" "${LOCAL_SHARE_DIR}/${itemname}"
    echo "Symlinked ${itemname} to ${LOCAL_SHARE_DIR}/${itemname}"
  fi
done

# Cleanup
rm -f "${NVIM_TARBALL}"

echo "Neovim ${NVIM_VERSION} installed successfully"
echo "Binary: ${NVIM_BIN}"
echo "Link: ${NVIM_LINK}"
ls -la "${NVIM_LINK}"
