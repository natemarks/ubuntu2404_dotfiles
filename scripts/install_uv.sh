#!/usr/bin/env bash
set -Eeuo pipefail

# Install or upgrade uv (and uvx) to the latest version using Astral's
# installer. uv is not in apt. Binaries go to ~/.local/bin.
# https://docs.astral.sh/uv/getting-started/installation/

UV_INSTALL_URL="https://astral.sh/uv/install.sh"
UV_BIN_DIR="${HOME}/.local/bin"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT
installer="${tmp_dir}/uv-install.sh"

curl -fsSL -o "${installer}" "${UV_INSTALL_URL}"

# The installer always fetches the latest release, so rerunning is an upgrade.
# UV_NO_MODIFY_PATH keeps it from appending to ~/.bashrc; PATH is managed by
# this repo's bashrc.d modules.
UV_NO_MODIFY_PATH=1 sh "${installer}"

"${UV_BIN_DIR}/uv" --version

if [[ ":${PATH}:" != *":${UV_BIN_DIR}:"* ]]; then
	echo "warning: ${UV_BIN_DIR} is not on PATH; open a new shell or add it" >&2
fi
