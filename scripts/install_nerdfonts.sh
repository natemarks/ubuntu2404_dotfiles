#!/usr/bin/env bash
# install fonts required by neovim
# https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
set -Eeuo pipefail

VERSION="3.2.1"
ZIP_NAME="JetBrainsMono.zip"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${ZIP_NAME}"

# Download the zip file to /tmp
wget -O "/tmp/${ZIP_NAME}" "$ZIP_URL"

# Create the fonts directory if it doesn't exist
mkdir -p ~/.fonts

# Unzip the file into ~/.fonts
unzip /tmp/font.zip -d ~/.fonts

# Refresh the font cache
fc-cache -fv

# Clean up
rm /tmp/font.zip

echo "Fonts installed and cache updated."
