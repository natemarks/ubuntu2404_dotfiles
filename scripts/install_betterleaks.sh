#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest betterleaks release to ~/bin, overwriting any existing binary.
# Set VERSION=x.y.z to install a specific release instead.
REPO="betterleaks/betterleaks"
EXECUTABLE="betterleaks"
INSTALL_PATH="${HOME}/bin/${EXECUTABLE}"

case "$(uname -m)" in
  x86_64) ARCH="x64" ;;
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
  echo "ERROR: could not determine ${EXECUTABLE} version (got '${VERSION}')" >&2
  exit 1
fi

TARBALL="${EXECUTABLE}_${VERSION}_linux_${ARCH}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${BASE_URL}/${TARBALL}"
curl -fsSL "${BASE_URL}/${TARBALL}" -o "${tmpdir}/${TARBALL}"
curl -fsSL "${BASE_URL}/checksums.txt" -o "${tmpdir}/checksums.txt"

if ! (cd "${tmpdir}" && grep " ${TARBALL}\$" checksums.txt | sha256sum --check --quiet); then
  echo "ERROR: checksum verification failed for ${TARBALL}" >&2
  exit 1
fi

tar -xzf "${tmpdir}/${TARBALL}" -C "${tmpdir}" "${EXECUTABLE}"
mkdir -p "$(dirname "${INSTALL_PATH}")"
install -m 0755 "${tmpdir}/${EXECUTABLE}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
