#!/usr/bin/env bash
# install the tree-sitter CLI, needed by nvim-treesitter (main branch) to build parsers
# apt's tree-sitter-cli is too old (26.04 ships 0.25.x; nvim-treesitter needs >= 0.26.1)
set -Eeuo pipefail

case "$(uname -m)" in
  x86_64) ARCH="x64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

TREESITTER_GZ="tree-sitter-linux-${ARCH}.gz"

# latest release by default; set TREESITTER_VERSION=x.y.z to pin.
# tree-sitter publishes no checksums file, so the sha256 comes from the release API's asset digest
if [[ -n "${TREESITTER_VERSION:-}" ]]; then
  RELEASE_API="https://api.github.com/repos/tree-sitter/tree-sitter/releases/tags/v${TREESITTER_VERSION}"
else
  RELEASE_API="https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest"
fi
release_json="$(curl -fsSL "${RELEASE_API}")"
TREESITTER_VERSION="$(jq -r '.tag_name | ltrimstr("v")' <<<"${release_json}")"
TREESITTER_SHA256="$(jq -r --arg name "${TREESITTER_GZ}" '.assets[] | select(.name == $name) | .digest | ltrimstr("sha256:")' <<<"${release_json}")"
if [[ ! "${TREESITTER_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ || ! "${TREESITTER_SHA256}" =~ ^[0-9a-f]{64}$ ]]; then
  echo "ERROR: could not resolve tree-sitter release/digest from ${RELEASE_API}" >&2
  exit 1
fi

TREESITTER_INSTALL_DIR="${HOME}/local/tree-sitter-${TREESITTER_VERSION}"
TREESITTER_BIN="${TREESITTER_INSTALL_DIR}/tree-sitter"
TREESITTER_LINK="${HOME}/bin/tree-sitter"

TREESITTER_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREESITTER_VERSION}/${TREESITTER_GZ}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/helper.sh"

if [[ -x "${TREESITTER_BIN}" ]]; then
  echo "tree-sitter ${TREESITTER_VERSION} already installed at ${TREESITTER_BIN}"
else
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT

  curl -fsSL "${TREESITTER_URL}" -o "${tmpdir}/${TREESITTER_GZ}"
  check_sha256 "${tmpdir}/${TREESITTER_GZ}" "${TREESITTER_SHA256}"
  gunzip -f "${tmpdir}/${TREESITTER_GZ}"

  mkdir -p "${TREESITTER_INSTALL_DIR}"
  install -m 0755 "${tmpdir}/${TREESITTER_GZ%.gz}" "${TREESITTER_BIN}"
fi

# always relink so ~/bin/tree-sitter points at this version
mkdir -p "$(dirname "${TREESITTER_LINK}")"
rm -f "${TREESITTER_LINK}"
ln -s "${TREESITTER_BIN}" "${TREESITTER_LINK}"
"${TREESITTER_LINK}" --version
