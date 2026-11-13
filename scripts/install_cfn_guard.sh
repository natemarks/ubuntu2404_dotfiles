#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest cfn-guard (CloudFormation Guard) release to ~/bin, overwriting any existing binary.
# Set VERSION=x.y.z to install a specific release instead.
# The release publishes no checksums or signatures, so the download is only protected by TLS.
REPO="aws-cloudformation/cloudformation-guard"
EXECUTABLE="cfn-guard"
INSTALL_PATH="${HOME}/bin/${EXECUTABLE}"

case "$(uname -m)" in
  x86_64) ARCH="x86_64" ;;
  aarch64) ARCH="aarch64" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# the /releases/latest redirect avoids the GitHub API rate limit; tags here have no leading "v"
if [[ -z "${VERSION:-}" ]]; then
  latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest")"
  VERSION="${latest_url##*/}"
fi
if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: could not determine ${EXECUTABLE} version (got '${VERSION}')" >&2
  exit 1
fi

NAME="cfn-guard-v3-${ARCH}-ubuntu-latest"
TARBALL="${NAME}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${TARBALL}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${URL}"
curl -fsSL "${URL}" -o "${tmpdir}/${TARBALL}"

tar -xzf "${tmpdir}/${TARBALL}" -C "${tmpdir}" "${NAME}/${EXECUTABLE}"
mkdir -p "$(dirname "${INSTALL_PATH}")"
install -m 0755 "${tmpdir}/${NAME}/${EXECUTABLE}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
