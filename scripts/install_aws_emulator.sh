#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest AWS Emulator (https://github.com/aws/aws-emulator) to ~/bin without sudo,
# overwriting any existing binary. AWS only publishes it as a .deb/.rpm (no standalone binary),
# so this downloads the .deb, verifies its GPG signature, and extracts the single self-contained
# binary instead of running apt. The binary is ~1 GB, so the download takes a while.
# Pinning a version is not supported by this script; AWS's "latest" URL is always used.
INSTALL_PATH="${HOME}/bin/aws-emulator"
BASE_URL="https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/latest"
KEY_URL="https://downloads.aws.com/keys/gpg/current.asc"
# fingerprint AWS documents for ssm-publishing@amazon.com (no spaces)
KEY_FINGERPRINT="98BCF336A3BE53B734E967C52E5BF49BD940F624"

case "$(uname -m)" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

for cmd in gpg dpkg-deb; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "ERROR: ${cmd} is required but not installed" >&2
    exit 1
  fi
done

PACKAGE="aws-emulator_${ARCH}.deb"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
# throwaway keyring so the AWS key never touches ~/.gnupg
export GNUPGHOME="${tmpdir}/gnupg"
mkdir -m 0700 "${GNUPGHOME}"

echo "Downloading ${BASE_URL}/${PACKAGE}"
curl -fsSL "${BASE_URL}/${PACKAGE}" -o "${tmpdir}/${PACKAGE}"
curl -fsSL "${BASE_URL}/${PACKAGE}.sig" -o "${tmpdir}/${PACKAGE}.sig"
curl -fsSL "${KEY_URL}" -o "${tmpdir}/key.asc"

gpg --batch --quiet --import "${tmpdir}/key.asc"
if ! gpg --batch --with-colons --fingerprint | grep -q "^fpr:::::::::${KEY_FINGERPRINT}:"; then
  echo "ERROR: AWS publishing key fingerprint is not ${KEY_FINGERPRINT}" >&2
  exit 1
fi
if ! gpg --batch --verify "${tmpdir}/${PACKAGE}.sig" "${tmpdir}/${PACKAGE}" 2>/dev/null; then
  echo "ERROR: signature verification failed for ${PACKAGE}" >&2
  exit 1
fi

version="$(dpkg-deb -f "${tmpdir}/${PACKAGE}" Version)"
dpkg-deb -x "${tmpdir}/${PACKAGE}" "${tmpdir}/extract"
mkdir -p "$(dirname "${INSTALL_PATH}")"
install -m 0755 "${tmpdir}/extract/opt/aws-emulator/bin/aws-emulator" "${INSTALL_PATH}"

echo "Installed aws-emulator ${version} to ${INSTALL_PATH}"
