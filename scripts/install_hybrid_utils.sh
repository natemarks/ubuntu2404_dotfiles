#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest hybrid_utils release by running the install.sh bundled in its linux_amd64 tarball,
# so new executables added to a release are installed without editing this script.
# Set VERSION=vX.Y.Z to install a specific release instead.
# The repo is private, so this needs an authenticated gh (GitHub CLI).
# Release assets are hybrid_utils_[<commit>_]linux_amd64.tar.gz; older releases omit the commit and
# newer ones nest the files in a directory, so install.sh is located with find.
REPO="imprivata-cloud/hybrid_utils"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh (GitHub CLI) is required but not installed" >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: hybrid_utils is only released for linux amd64 (this is $(uname -m))" >&2
  exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
  VERSION="$(gh release view --repo "${REPO}" --json tagName --jq '.tagName')"
fi
if [[ ! "${VERSION}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: could not determine hybrid_utils version (got '${VERSION}')" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading hybrid_utils ${VERSION}"
gh release download "${VERSION}" --repo "${REPO}" --pattern '*linux_amd64.tar.gz' --dir "${tmpdir}"

shopt -s nullglob
tarballs=("${tmpdir}"/*linux_amd64.tar.gz)
if [[ ${#tarballs[@]} -ne 1 ]]; then
  echo "ERROR: expected exactly one linux_amd64 tarball in release ${VERSION}, found ${#tarballs[@]}" >&2
  exit 1
fi

extract_dir="${tmpdir}/extract"
mkdir -p "${extract_dir}"
tar -xzf "${tarballs[0]}" -C "${extract_dir}"

installer="$(find "${extract_dir}" -type f -name install.sh -print -quit)"
if [[ -z "${installer}" ]]; then
  echo "ERROR: no install.sh found in the ${VERSION} tarball (older releases may not ship one)" >&2
  exit 1
fi

# run from the installer's own directory; it locates the files it installs relative to itself
echo "Running install.sh from the ${VERSION} tarball"
(cd "$(dirname "${installer}")" && bash ./install.sh)

echo "Installed hybrid_utils ${VERSION}"
