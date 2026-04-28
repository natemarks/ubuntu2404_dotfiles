#!/usr/bin/env bash
set -Eeuo pipefail

# Example asset:
# https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-x86_64-unknown-linux-gnu.zip
YAZI_VERSION="26.1.22"
YAZI_ZIP="yazi-x86_64-unknown-linux-gnu.zip"
YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/${YAZI_ZIP}"

ARCH="$(uname -m)"
if [[ "${ARCH}" != "x86_64" ]]; then
  echo "Unsupported architecture: ${ARCH}. This installer only supports x86_64." >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
zip_path="${tmp_dir}/${YAZI_ZIP}"
extract_dir="${tmp_dir}/extract"
install_dir="${HOME}/bin"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

echo "Downloading: ${YAZI_URL}"
curl -fL "${YAZI_URL}" -o "${zip_path}"

if ! command -v unzip >/dev/null 2>&1; then
  echo "'unzip' is required but not installed." >&2
  exit 1
fi

mkdir -p "${extract_dir}" "${install_dir}"

echo "Extracting yazi ${YAZI_VERSION}"
unzip -q "${zip_path}" -d "${extract_dir}"

yazi_binary="$(find "${extract_dir}" -type f -name yazi -print -quit)"
if [[ -z "${yazi_binary}" ]]; then
  echo "Could not find yazi executable in archive." >&2
  exit 1
fi

echo "Installing yazi to ${install_dir}/yazi"
mv "${yazi_binary}" "${install_dir}/yazi"
chmod +x "${install_dir}/yazi"

echo "Installed: ${install_dir}/yazi"
