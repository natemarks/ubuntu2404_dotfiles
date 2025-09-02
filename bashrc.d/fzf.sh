#!/usr/bin/env bash
OS="$(uname -s)"
function  fzf_completion() {
  if [ "$OS" = "Darwin" ]; then
    find /usr/local/Cellar/fzf -type f -name completion.bash
  else
    find /usr/share/doc/fzf -type f -name completion.bash
  fi
}


function  fzf_key-bindings() {
  if [ "$OS" = "Darwin" ]; then
    find /usr/local/Cellar/fzf -type f -name key-bindings.bash
  else
    find /usr/share/doc/fzf -type f -name key-bindings.bash
  fi
}
# Auto-completion
# ---------------
# shellcheck disable=SC1091
# $- == *i*  checks to see that the shell is interactive
# shellcheck disable=SC1090
[[ $- == *i* ]] && . "$(fzf_completion)" 2> /dev/null

# Key bindings
# ------------
# shellcheck disable=SC1090
. "$(fzf_key-bindings)"