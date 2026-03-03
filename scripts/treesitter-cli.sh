#!/usr/bin/env bash
set -Eeuo pipefail

TREESITTER_VERSION="0.26.6"
TREESITTER_SHA256SUM="sha256:2b9595064a7d9dbe208c6f09f521d73061f8039e4ffcc2fd08979d249aeabb54"
TREESITTER_SHA256="${TREESITTER_SHA256SUM#sha256:}"
TREESITTER_GZ="tree-sitter-linux-x64.gz"
TREESITTER_BINARY_GZLESS="tree-sitter-linux-x64"
TREESITTER_INSTALL_DIR="/opt/tree-sitter/${TREESITTER_VERSION}"
TREESITTER_BIN="${TREESITTER_INSTALL_DIR}/tree-sitter"
TREESITTER_LINK="${HOME}/bin/tree-sitter"

TREESITTER_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREESITTER_VERSION}/${TREESITTER_GZ}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/helper.sh"

if [ -d "${TREESITTER_INSTALL_DIR}" ]; then
  echo "install dir exists: ${TREESITTER_INSTALL_DIR}. exiting"
  exit
fi

curl -JLO "${TREESITTER_URL}"
check_sha256 "${TREESITTER_GZ}" "${TREESITTER_SHA256}"
gunzip -f "${TREESITTER_GZ}"
chmod +x "${TREESITTER_BINARY_GZLESS}"
sudo mkdir -p "${TREESITTER_INSTALL_DIR}"
sudo mv "${TREESITTER_BINARY_GZLESS}" "${TREESITTER_BIN}"
rm -f "${TREESITTER_LINK}"
ln -s "${TREESITTER_BIN}" "${TREESITTER_LINK}"
ls -la "${TREESITTER_LINK}"
