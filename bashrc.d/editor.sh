#!/usr/bin/env bash
# shellcheck disable=SC2230
if which nv; then
  export EDITOR=nv
  else
  export EDITOR=vi
fi
