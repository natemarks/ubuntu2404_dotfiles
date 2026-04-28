#!/usr/bin/env bash
set -Eeuo pipefail

# Keep this easy to bump when new sesh releases are published.
VERSION="2.25.0"
EXECUTABLE="sesh"
ARCHIVE="${EXECUTABLE}_Linux_x86_64.tar.gz"
URL="https://github.com/joshmedeski/sesh/releases/download/v${VERSION}/${ARCHIVE}"
INSTALL_DIR="${HOME}/bin"
INSTALL_PATH="${INSTALL_DIR}/${EXECUTABLE}"

overwrite=false

usage() {
  cat <<'EOF'
Usage: install_sesh.sh [--overwrite]

Installs sesh to $HOME/bin.

Options:
  --overwrite  Reinstall even if $HOME/bin/sesh already exists.
  -h, --help   Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overwrite)
      overwrite=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

mkdir -p "${INSTALL_DIR}"

if [[ -f "${INSTALL_PATH}" && "${overwrite}" != true ]]; then
  echo "sesh already installed at ${INSTALL_PATH}. Use --overwrite to reinstall."
  exit 0
fi

tmpdir="$(mktemp -d)"
archive_path="${tmpdir}/${ARCHIVE}"

cleanup() {
  rm -rf "${tmpdir}"
}

trap cleanup EXIT

echo "Downloading ${URL}"
curl -fsSL "${URL}" -o "${archive_path}"

tar -xzf "${archive_path}" -C "${tmpdir}" "${EXECUTABLE}"
install -m 0755 "${tmpdir}/${EXECUTABLE}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
