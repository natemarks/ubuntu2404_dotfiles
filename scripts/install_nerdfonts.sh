#!/usr/bin/env bash
# install fonts required by neovim
# https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
# add a gnome terminal profile to use the downloaded fonts
# https://stackoverflow.com/questions/72184554/how-to-fix-nvchad-not-displaying-icons
set -Eeuo pipefail

VERSION="3.2.1"
ZIP_NAME="JetBrainsMono.zip"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${ZIP_NAME}"
FONTS_DIR="${HOME}/.fonts"

mkdir -p "${FONTS_DIR}"
# Download the zip file to /tmp
# wget -O "/tmp/${ZIP_NAME}" "$ZIP_URL"

curl --tlsv1.2 -sSLo "/tmp/${ZIP_NAME}" "$ZIP_URL"
# Create the fonts directory if it doesn't exist

# Unzip the file into ~/.fonts
unzip "/tmp/${ZIP_NAME}" -d "${FONTS_DIR}"

# Refresh the font cache
fc-cache -fv

# Clean up
rm "/tmp/${ZIP_NAME}"

echo "Fonts installed and cache updated."
