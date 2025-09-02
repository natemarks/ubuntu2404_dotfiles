#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.27.1/cloud-nuke_linux_amd64
VERSION="0.27.1"
EXECUTABLE="cloud-nuke"
DOWNLOAD="${EXECUTABLE}_linux_amd64"
URL="https://github.com/gruntwork-io/cloud-nuke/releases/download/v${VERSION}/${DOWNLOAD}"

if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
    rm -f "${HOME}/bin/${EXECUTABLE}"
fi

if [ ! -f "${HOME}/bin/${EXECUTABLE}" ] ; then
  curl -sSLo "${HOME}/bin/${EXECUTABLE}" "${URL}"
  chmod 755 "${HOME}/bin/${EXECUTABLE}"
fi
