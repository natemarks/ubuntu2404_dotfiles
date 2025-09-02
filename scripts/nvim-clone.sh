#!/usr/bin/env bash
CONFIG="${HOME}/.config/nvim"
SHARE="${HOME}/.local/share/nvim"
CONFIG_BACKUP="${HOME}/.config/nvim.backup"
SHARE_BACKUP="${HOME}/.local/share/nvim.backup"

if [[ -d "${CONFIG}" ]]; then
  echo "${CONFIG} alreday exists"
  exit 1
fi


if [[ -d "${SHARE}" ]]; then
  echo "${SHARE} already exists"
  exit 1 
fi

git clone https://github.com/natemarks/kickstart.nvim.git "${HOME}/.config/nvim"
