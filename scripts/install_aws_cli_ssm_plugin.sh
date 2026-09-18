#!/usr/bin/env bash
set -Eeuo pipefail

if command -v session-manager-plugin &> /dev/null; then
  echo "session-manager-plugin already installed, skipping."
  exit 0
fi

SSM_PLUGIN_INSTALLER=session-manager-plugin.deb
SSM_PLUGIN_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/${SSM_PLUGIN_INSTALLER}"
curl -o "${SSM_PLUGIN_INSTALLER}" -L "${SSM_PLUGIN_URL}" && sudo dpkg -i "${SSM_PLUGIN_INSTALLER}"
rm "${SSM_PLUGIN_INSTALLER}"
