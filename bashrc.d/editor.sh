#!/usr/bin/env bash
# shellcheck disable=SC2230
if which nvim; then
  export EDITOR=nvim
  else
  export EDITOR=vi
fi
