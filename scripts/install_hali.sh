#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the hali binary from the newest local release tarball to ~/bin, overwriting any existing binary.
# For now the tarballs come from a local checkout (override with HALI_DIST_DIR=/path/to/dist);
# the newest hali-v*-x86_64-linux.tar.gz is picked by version, and verified against SHA256SUMS when present.
DIST_DIR="${HALI_DIST_DIR:-${HOME}/projects/hali/dist}"
EXECUTABLE="hali"
INSTALL_PATH="${HOME}/bin/${EXECUTABLE}"

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: hali tarballs are only built for x86_64 (this is $(uname -m))" >&2
  exit 1
fi

if [[ ! -d "${DIST_DIR}" ]]; then
  echo "ERROR: dist directory not found: ${DIST_DIR}" >&2
  exit 1
fi

# version sort so v0.10.0 beats v0.9.0
tarball="$(find "${DIST_DIR}" -maxdepth 1 -type f -name 'hali-v*-x86_64-linux.tar.gz' -printf '%f\n' | sort -V | tail -n 1)"
if [[ -z "${tarball}" ]]; then
  echo "ERROR: no hali-v*-x86_64-linux.tar.gz found in ${DIST_DIR}" >&2
  exit 1
fi

if [[ -f "${DIST_DIR}/SHA256SUMS" ]]; then
  if ! (cd "${DIST_DIR}" && grep " ${tarball}\$" SHA256SUMS | sha256sum --check --quiet); then
    echo "ERROR: checksum verification failed for ${tarball}" >&2
    exit 1
  fi
else
  echo "WARNING: no SHA256SUMS in ${DIST_DIR}; skipping checksum verification" >&2
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# tarball layout is hali-vX.Y.Z/hali (alongside completions, man page, README)
src="$(tar -tzf "${DIST_DIR}/${tarball}" | grep -E "^[^/]+/${EXECUTABLE}\$" | head -n 1 || true)"
if [[ -z "${src}" ]]; then
  echo "ERROR: ${EXECUTABLE} not found in ${tarball}" >&2
  exit 1
fi

tar -xzf "${DIST_DIR}/${tarball}" -C "${tmpdir}" "${src}"
mkdir -p "$(dirname "${INSTALL_PATH}")"
install -m 0755 "${tmpdir}/${src}" "${INSTALL_PATH}"

echo "Installed ${EXECUTABLE} from ${tarball} to ${INSTALL_PATH}"
