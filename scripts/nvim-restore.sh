#!/usr/bin/env bash
CONFIG="${HOME}/.config/nvim"
SHARE="${HOME}/.local/share/nvim"
CONFIG_BACKUP="${HOME}/.config/nvim.backup"
SHARE_BACKUP="${HOME}/.local/share/nvim.backup"

if [[ ! -d "${CONFIG_BACKUP}" ]]; then
  echo moving "${CONFIG} to ${CONFIG_BACKUP}"
  mv "${CONFIG}" "${CONFIG_BACKUP}"
fi


if [[ ! -d "${SHARE_BACKUP}" ]]; then
  echo moving "${SHARE} to ${SHARE_BACKUP}"
  mv "${SHARE}" "${SHARE_BACKUP}"
fi

rm -rf "${CONFIG}"
rm -rf "${SHARE}"
cp -a "${CONFIG_BACKUP}" "${CONFIG}"
cp -a "${SHARE_BACKUP}" "${SHARE}"
