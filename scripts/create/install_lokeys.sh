#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/natemarks/lokeys/releases/download/v0.1.2/lokeys_v0.1.2_linux_amd64.tar.gz
VERSION="0.1.2"
EXECUTABLE="lokeys"
BIN_DIR="${HOME}/bin"
TARBALL="${EXECUTABLE}_v${VERSION}_linux_amd64.tar.gz"
URL="https://github.com/natemarks/lokeys/releases/download/v${VERSION}/${TARBALL}"

if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
	rm -f "${BIN_DIR}/${EXECUTABLE}"
fi

mkdir -p "${BIN_DIR}"

if [ ! -f "${BIN_DIR}/${EXECUTABLE}" ]; then
	curl -sSLo "${BIN_DIR}/${TARBALL}" "${URL}"
	tar xf "${BIN_DIR}/${TARBALL}" -C "${BIN_DIR}" "${EXECUTABLE}"
	chmod +x "${BIN_DIR}/${EXECUTABLE}"
	rm -f "${BIN_DIR}/${TARBALL}"
fi
