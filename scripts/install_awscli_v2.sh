#!/usr/bin/env bash
set -Eeuo pipefail

INSTALLER=~/Downloads/awscli-exe-linux-x86_64.zip
UNZIP_DIR="$(mktemp -d -t deleteme.XXXXXX)"
trap 'rm -rf "${UNZIP_DIR}"' EXIT
rm -f "${INSTALLER}"
curl -o "${INSTALLER}" -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip -q "${INSTALLER}" -d "${UNZIP_DIR}"

# the installer refuses to overwrite an existing install unless --update is passed
INSTALL_ARGS=()
if [[ -d /usr/local/aws-cli/v2/current ]]; then
  INSTALL_ARGS+=(--update)
fi
sudo "${UNZIP_DIR}/aws/install" "${INSTALL_ARGS[@]}"
aws --version

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/install_aws_cli_ssm_plugin.sh"
