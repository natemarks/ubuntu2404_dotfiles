#!/usr/bin/env bash
# shellcheck disable=SC2148

# Dynamically add neovim bin directory to PATH based on ~/bin/nv symlink
if [[ -L "${HOME}/bin/nv" ]]; then
  NVIM_TARGET=$(readlink -f "${HOME}/bin/nv")
  NVIM_BIN_DIR=$(dirname "$NVIM_TARGET")

  # Only add to PATH if not already present
  if [[ ":$PATH:" != *":${NVIM_BIN_DIR}:"* ]]; then
    export PATH="${NVIM_BIN_DIR}:${PATH}"
  fi

  unset NVIM_TARGET NVIM_BIN_DIR
fi