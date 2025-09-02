#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/jesseduffield/lazygit/releases/download/v0.36.0/lazygit_0.36.0_Linux_x86_64.tar.gz
VERSION="0.36.0"
EXECUTABLE="lazygit"
TARBALL="${EXECUTABLE}_${VERSION}_Linux_x86_64.tar.gz"
URL="https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/${TARBALL}"

if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
    rm -f "${HOME}/bin/${EXECUTABLE}"
fi

if [ ! -f "${HOME}/bin/${EXECUTABLE}" ] ; then
  curl -sSLo "${HOME}/bin/${TARBALL}" "${URL}"

  tar xf "${HOME}/bin/${TARBALL}" -C "${HOME}/bin" "${EXECUTABLE}"
  rm -f "${HOME}/bin/${TARBALL}"
fi
