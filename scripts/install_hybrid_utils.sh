#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the latest hybrid_utils release (task-images, ecs-tasks, immutable-ecr, ecr-lifecycle) to ~/bin,
# overwriting existing binaries. Set VERSION=vX.Y.Z to install a specific release instead.
# The repo is private, so this needs an authenticated gh (GitHub CLI).
# Release assets are hybrid_utils_[<commit>_]linux_amd64.tar.gz; older releases omit the commit and
# newer ones nest the files in a directory, so the binaries are located with find.
REPO="imprivata-cloud/hybrid_utils"
INSTALL_DIR="${HOME}/bin"
BINARIES=("task-images" "ecs-tasks" "immutable-ecr" "ecr-lifecycle")

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
mkdir -p "${extract_dir}" "${INSTALL_DIR}"
tar -xzf "${tarballs[0]}" -C "${extract_dir}"

for binary in "${BINARIES[@]}"; do
  src="$(find "${extract_dir}" -type f -name "${binary}" -print -quit)"
  if [[ -z "${src}" ]]; then
    echo "WARNING: ${binary} not found in ${VERSION} (it may have been added in a later release)" >&2
    continue
  fi
  install -m 0755 "${src}" "${INSTALL_DIR}/${binary}"
  echo "Installed ${binary} to ${INSTALL_DIR}/${binary}"
done

echo "Installed hybrid_utils ${VERSION} to ${INSTALL_DIR}"
