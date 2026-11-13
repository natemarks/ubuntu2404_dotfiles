#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest cfn-validate (aws-cloudformation/cloudformation-validate) CLI to ~/bin,
# overwriting any existing binary. The release signature is verified with openssl.
# Set VERSION=x.y.z to install a specific release instead.
REPO="aws-cloudformation/cloudformation-validate"
EXECUTABLE="cfn-validate"
INSTALL_PATH="${HOME}/bin/${EXECUTABLE}"

case "$(uname -m)" in
  x86_64) ARCH="x64" ;;
  aarch64) ARCH="aarch64" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# the /releases/latest redirect avoids the GitHub API rate limit
if [[ -z "${VERSION:-}" ]]; then
  latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest")"
  VERSION="${latest_url##*/}"
  VERSION="${VERSION#v}"
fi
if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: could not determine ${EXECUTABLE} version (got '${VERSION}')" >&2
  exit 1
fi

ASSET="${EXECUTABLE}-${VERSION}-linux-${ARCH}"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${BASE_URL}/${ASSET}"
curl -fsSL "${BASE_URL}/${ASSET}" -o "${tmpdir}/${ASSET}"
curl -fsSL "${BASE_URL}/${ASSET}.sig" -o "${tmpdir}/${ASSET}.sig"
curl -fsSL "${BASE_URL}/signing-key.pem" -o "${tmpdir}/signing-key.pem"
curl -fsSL "${BASE_URL}/signing-key.pem.sha256" -o "${tmpdir}/signing-key.pem.sha256"

# the key ships in the same release as the binary, so also check it against its published fingerprint
key_fingerprint="$(openssl pkey -pubin -in "${tmpdir}/signing-key.pem" -outform DER | openssl dgst -sha256 | awk '{print $NF}')"
if [[ "${key_fingerprint}" != "$(awk '{print $1}' "${tmpdir}/signing-key.pem.sha256")" ]]; then
  echo "ERROR: signing key fingerprint mismatch" >&2
  exit 1
fi

if ! openssl dgst -sha256 -verify "${tmpdir}/signing-key.pem" \
  -signature "${tmpdir}/${ASSET}.sig" "${tmpdir}/${ASSET}" >/dev/null; then
  echo "ERROR: signature verification failed for ${ASSET}" >&2
  exit 1
fi

mkdir -p "$(dirname "${INSTALL_PATH}")"
install -m 0755 "${tmpdir}/${ASSET}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
