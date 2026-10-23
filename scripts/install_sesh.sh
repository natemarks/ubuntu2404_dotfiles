#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest sesh release by default; set VERSION=x.y.z to pin.
REPO="joshmedeski/sesh"
EXECUTABLE="sesh"
INSTALL_DIR="${HOME}/bin"
INSTALL_PATH="${INSTALL_DIR}/${EXECUTABLE}"

overwrite=false

usage() {
  cat <<'EOF'
Usage: install_sesh.sh [--overwrite]

Installs the latest sesh release to $HOME/bin, or upgrades an older one.
Set VERSION=x.y.z to install a specific release instead.

Options:
  --overwrite  Reinstall even if the requested version is already installed.
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

case "$(uname -m)" in
  x86_64) ARCH="x86_64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# the /releases/latest redirect avoids the GitHub API rate limit
if [[ -z "${VERSION:-}" ]]; then
  latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest")"
  VERSION="${latest_url##*/v}"
fi
if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: could not determine sesh version (got '${VERSION}')" >&2
  exit 1
fi

if [[ -x "${INSTALL_PATH}" && "${overwrite}" != true ]]; then
  installed="$("${INSTALL_PATH}" --version 2>/dev/null | awk '{print $NF}')"
  if [[ "${installed}" == "${VERSION}" ]]; then
    echo "sesh ${VERSION} already installed at ${INSTALL_PATH}. Use --overwrite to reinstall."
    exit 0
  fi
  echo "Upgrading sesh ${installed:-unknown} -> ${VERSION}"
fi

ARCHIVE="${EXECUTABLE}_Linux_${ARCH}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"

mkdir -p "${INSTALL_DIR}"

tmpdir="$(mktemp -d)"

cleanup() {
  rm -rf "${tmpdir}"
}

trap cleanup EXIT

echo "Downloading ${BASE_URL}/${ARCHIVE}"
curl -fsSL "${BASE_URL}/${ARCHIVE}" -o "${tmpdir}/${ARCHIVE}"
curl -fsSL "${BASE_URL}/${EXECUTABLE}_${VERSION}_checksums.txt" -o "${tmpdir}/checksums.txt"

if ! (cd "${tmpdir}" && grep " ${ARCHIVE}\$" checksums.txt | sha256sum --check --quiet); then
  echo "ERROR: checksum verification failed for ${ARCHIVE}" >&2
  exit 1
fi

tar -xzf "${tmpdir}/${ARCHIVE}" -C "${tmpdir}" "${EXECUTABLE}"
install -m 0755 "${tmpdir}/${EXECUTABLE}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
