#!/usr/bin/env bash

# https://unix.stackexchange.com/questions/4219/how-do-i-get-bash-completion-for-command-aliases
# Wraps a completion function, eg for use with an alias.
# Usage:
# make-completion-wrapper <actual completion function> <name of new func.>
#                         <command name> <list supplied arguments>
# eg.
#   alias agi='apt-get install'
#   make-completion-wrapper _apt_get _apt_get_install apt-get install
#     # defines a function called _apt_get_install (that's $2) that will
#     # complete the 'agi' alias. 
#   complete -F _apt_get_install agi
function make-completion-wrapper {
  local function_name="$2"
  local arg_count=$(( $#-3 ))
  local comp_function_name="$1"
  shift 2
  local function="function $function_name {
      (( COMP_CWORD += $arg_count ))
      COMP_WORDS=( \"\$@\" \${COMP_WORDS[@]:1} )
      \"$comp_function_name\"
    }"
  eval "$function"
  # echo "$function"
}

function complete-alias  {
    # uses make-completion-wrapper: https://unix.stackexchange.com/a/4220/50978
    # example usage
    # complete-alias _pass pshow pass show
    # complete-alias _pass pgen pass generate

    EXISTING_COMPLETION_FN=${1} && shift
    ALIAS=${1} && shift
    AUTOGEN_COMPLETION_FN="__autogen_completion_${ALIAS}"
    make-completion-wrapper "${EXISTING_COMPLETION_FN}" "${AUTOGEN_COMPLETION_FN}" "${*}"
    complete -F "${AUTOGEN_COMPLETION_FN}" "${ALIAS}"
}

pathinsert() {
  export PATH="${1}":$PATH
}

pathappemd() {
  export PATH=$PATH:"${1}"
}

function get_projects {
    echo ~/projects
    }

function mk_ramdisk() {
  # mounts ramdisk of size in MB at /mnt/ramdisk
  RDIR="${HOME}/ramdisk"
  mkdir -p "${RDIR}"
  sudo mount -t tmpfs -o size="${1}m" tmpfs "${RDIR}"
}

function cdk_local() {
  # prioritize ./node_modules/aws-cdk/bin/ in PATH
  [ -d "./node_modules/aws-cdk/bin" ] && export PATH="./node_modules/aws-cdk/bin":$PATH
}

function ccutter() {
  # run cookiecutter with a couple of versions.
  # this up with:
  # PYENV_VERSION=3.10.6 pip install cookiecutter
  # PYENV_VERSION=3.10.6 pip install --upgrade pip setuptools
  PYENV_VERSION=3.10.6 cookiecutter "$@"
}

# grep pythion files in all projects, but exclude venv
# find . -type f -name "*.py" -not -path "*/.venv/*" -exec grep -H -n 'secretsmanager' {} \;
function pygrep() {
  find "${HOME}/projects" -type f -name "*.py" -not -path "*/.venv/*" -exec grep -H -n "${1}" {} \;
}