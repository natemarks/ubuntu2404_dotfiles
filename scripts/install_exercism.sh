#!/usr/bin/env bash
set -Eeuo pipefail

EXERCISM_VERSION="3.1.0"
DOWNLOAD_DIR="${HOME}/bin/exercism_${EXERCISM_VERSION}"

# download the tarball to $HOME/bin/exercism_$VERSION
mkdir -p "${DOWNLOAD_DIR}"
curl -sL  "https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz" \
--output "${DOWNLOAD_DIR}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz"

# unzip only the executable to $HOME/bin
tar -xzvf "${DOWNLOAD_DIR}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz" -C "${HOME}/bin" exercism
