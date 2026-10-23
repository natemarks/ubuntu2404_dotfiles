#!/usr/bin/env bash
# install Nerd Fonts (patched with powerline + icon glyphs) for the terminal and neovim
# https://github.com/ryanoasis/nerd-fonts/releases
#
# Usage: install_nerdfonts.sh [--overwrite] [FONT...]
#   FONT defaults to JetBrainsMono; supported: JetBrainsMono, UbuntuSans
#
# then point the terminal (ptyxis) at the font, e.g.
# gsettings set org.gnome.Ptyxis use-system-font false
# gsettings set org.gnome.Ptyxis font-name 'UbuntuSansMono Nerd Font Mono 11'
set -Eeuo pipefail

VERSION="3.5.1"
FONTS_DIR="${HOME}/.fonts"

# sha256 digests published on the GitHub release; update alongside VERSION
declare -A SHA256=(
  [JetBrainsMono]="fab782a66f7d3019da64f6572db9fc5d3a4bcb19f9fa13e2d8a62e3693d6396e"
  [UbuntuSans]="2e7dc2d1e116d1f4fd9d2fc65071f5c6c5c95af0c1484379b06581161466ae0b"
)

overwrite=false
fonts=()
for arg in "$@"; do
  case "${arg}" in
    --overwrite) overwrite=true ;;
    *) fonts+=("${arg}") ;;
  esac
done
[[ ${#fonts[@]} -gt 0 ]] || fonts=(JetBrainsMono)

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

for font in "${fonts[@]}"; do
  if [[ -z "${SHA256[${font}]:-}" ]]; then
    echo "ERROR: unknown font '${font}' (supported: ${!SHA256[*]})" >&2
    exit 1
  fi

  font_dir="${FONTS_DIR}/${font}NerdFont"
  if [[ -d "${font_dir}" && "${overwrite}" != true ]]; then
    echo "${font} already installed at ${font_dir}. Use --overwrite to reinstall."
    continue
  fi

  zip_path="${tmpdir}/${font}.zip"
  curl --tlsv1.2 -fsSLo "${zip_path}" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${font}.zip"
  if ! echo "${SHA256[${font}]}  ${zip_path}" | sha256sum --check --quiet; then
    echo "ERROR: checksum mismatch for ${font}.zip" >&2
    exit 1
  fi

  rm -rf "${font_dir}"
  mkdir -p "${font_dir}"
  unzip -q -o "${zip_path}" '*.ttf' -d "${font_dir}"
  echo "Installed ${font} Nerd Font to ${font_dir}"
done

fc-cache -f "${FONTS_DIR}"
echo "Font cache updated."
