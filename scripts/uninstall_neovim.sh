#!/usr/bin/env bash
set -Eeuo pipefail

# Script to uninstall a specific neovim version or all versions

NVIM_LINK="${HOME}/bin/nv"
LOCAL_SHARE_DIR="${HOME}/.local/share"
LOCAL_MAN_DIR="${HOME}/.local/share/man"

usage() {
  echo "Usage: $0 <version|all>"
  echo "  version - Specific version to uninstall (e.g., 0.12.3)"
  echo "  all     - Remove all neovim installations"
  echo ""
  echo "Installed versions:"
  if [ -d "${HOME}/local" ]; then
    find "${HOME}/local" -maxdepth 1 -type d -name "nvim-*" -exec basename {} \; | sed 's/nvim-/  /'
  else
    echo "  None found"
  fi
  exit 1
}

remove_symlinks() {
  local version=$1
  local install_dir="${HOME}/local/nvim-${version}"

  if [ ! -d "$install_dir" ]; then
    echo "Installation directory not found: $install_dir"
    return 1
  fi

  echo "Removing symlinks for neovim ${version}..."

  # Remove man page symlinks
  if [ -d "${install_dir}/nvim-linux-x86_64/share/man" ]; then
    for mandir in "${install_dir}/nvim-linux-x86_64/share/man"/*; do
      if [ -d "$mandir" ]; then
        section=$(basename "$mandir")
        for manpage in "$mandir"/*; do
          if [ -f "$manpage" ]; then
            manfile=$(basename "$manpage")
            local link="${LOCAL_MAN_DIR}/${section}/${manfile}"
            if [ -L "$link" ] && [ "$(readlink "$link")" = "$manpage" ]; then
              rm -f "$link"
              echo "  Removed man page link: $link"
            fi
          fi
        done
      fi
    done
  fi

  # Remove other share symlinks
  if [ -d "${install_dir}/nvim-linux-x86_64/share" ]; then
    for item in "${install_dir}/nvim-linux-x86_64/share"/*; do
      if [ -d "$item" ] && [ "$(basename "$item")" != "man" ]; then
        itemname=$(basename "$item")
        local link="${LOCAL_SHARE_DIR}/${itemname}"
        if [ -L "$link" ] && [[ "$(readlink "$link")" == *"nvim-${version}"* ]]; then
          rm -f "$link"
          echo "  Removed share link: $link"
        fi
      fi
    done
  fi

  # Remove binary link if it points to this version
  if [ -L "${NVIM_LINK}" ] && [[ "$(readlink "${NVIM_LINK}")" == *"nvim-${version}"* ]]; then
    rm -f "${NVIM_LINK}"
    echo "  Removed binary link: ${NVIM_LINK}"
  fi

  # Remove installation directory
  rm -rf "$install_dir"
  echo "Removed installation directory: $install_dir"
}

if [ $# -ne 1 ]; then
  usage
fi

VERSION=$1

if [ "$VERSION" = "all" ]; then
  echo "Removing all neovim installations..."
  if [ -d "${HOME}/local" ]; then
    for install_dir in "${HOME}/local"/nvim-*; do
      if [ -d "$install_dir" ]; then
        version=$(basename "$install_dir" | sed 's/nvim-//')
        remove_symlinks "$version"
      fi
    done
  fi
  echo "All neovim installations removed"
else
  remove_symlinks "$VERSION"
  echo "Neovim ${VERSION} uninstalled successfully"
fi
