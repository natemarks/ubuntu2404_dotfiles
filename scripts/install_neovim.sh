#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_VERSION="0.12.6"
NVIM_SHA256SUM="474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_DIR="${HOME}/local/nvim-${NVIM_VERSION}"
NVIM_BIN="${NVIM_INSTALL_DIR}/bin/nvim"
NVIM_LINK="${HOME}/bin/nv"

# Man and share directories
NVIM_SHARE_DIR="${NVIM_INSTALL_DIR}/share"
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

# Download and verify tarball in a temp dir, not the caller's cwd (the repo root under make)
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "${TARBALL_URL}" -o "${tmpdir}/${NVIM_TARBALL}"
check_sha256 "${tmpdir}/${NVIM_TARBALL}" "${NVIM_SHA256SUM}"

# Extract to versioned directory in ~/local
mkdir -p "${HOME}/local"
tar -C "${tmpdir}" -xzf "${tmpdir}/${NVIM_TARBALL}"
mv "${tmpdir}/nvim-linux-x86_64" "${NVIM_INSTALL_DIR}"

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
# share/nvim is the bundled runtime, found relative to the binary; linking it would
# replace ~/.local/share/nvim, Neovim's data dir (plugins, parsers, mason)
for item in "${NVIM_SHARE_DIR}"/*; do
  if [ -d "$item" ] && [ "$(basename "$item")" != "man" ] && [ "$(basename "$item")" != "nvim" ]; then
    itemname=$(basename "$item")
    target_path="${LOCAL_SHARE_DIR}/${itemname}"

    # Skip if target is already a real directory (not a symlink)
    if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
      echo "Skipping ${itemname} (directory already exists at ${target_path})"
      continue
    fi

    # Remove existing symlink or file, then create new symlink
    rm -f "$target_path"
    ln -s "$item" "$target_path"
    echo "Symlinked ${itemname} to ${target_path}"
  fi
done

echo "Neovim ${NVIM_VERSION} installed successfully"
echo "Binary: ${NVIM_BIN}"
echo "Link: ${NVIM_LINK}"
ls -la "${NVIM_LINK}"
