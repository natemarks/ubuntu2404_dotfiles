#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz
VERSION="1.8.7"
EXECUTABLE="grpcurl"
TARBALL="${EXECUTABLE}_${VERSION}_linux_x86_64.tar.gz"
URL="https://github.com/fullstorydev/grpcurl/releases/download/v${VERSION}/${TARBALL}"

if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
    rm -f "${HOME}/bin/${EXECUTABLE}"
fi

if [ ! -f "${HOME}/bin/${EXECUTABLE}" ] ; then
  curl -sSLo "${HOME}/bin/${TARBALL}" "${URL}"

  tar xf "${HOME}/bin/${TARBALL}" -C "${HOME}/bin" "${EXECUTABLE}"
  rm -f "${HOME}/bin/${TARBALL}"
fi
