#!/usr/bin/env bash
set -Eeuo pipefail

INSTALLER=~/Downloads/vscode.deb
rm -f "$INSTALLER"
curl -o "$INSTALLER" -L http://go.microsoft.com/fwlink/?LinkID=760868 && sudo dpkg -i "$INSTALLER"
