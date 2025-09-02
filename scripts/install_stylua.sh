#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64.zip
VERSION="2.0.2"
EXECUTABLE="stylua"
TARBALL="${EXECUTABLE}-linux-x86_64.zip"
URL="https://github.com/JohnnyMorganz/StyLua/releases/download/v${VERSION}/${TARBALL}"

if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
    rm -f "${HOME}/bin/${EXECUTABLE}"
fi

if [ ! -f "${HOME}/bin/${EXECUTABLE}" ] ; then
  curl -sSLo "${HOME}/bin/${TARBALL}" "${URL}"
  unzip "${HOME}/bin/${TARBALL}" -d "${HOME}/bin"
  rm -f "${HOME}/bin/${TARBALL}"
fi
