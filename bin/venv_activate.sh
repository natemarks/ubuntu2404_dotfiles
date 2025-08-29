#!/usr/bin/env bash
# using new or existing:
#  [ ./.venv  |  ./venv ] based on ./.gitignore
#  requirements_dev.txt  | requirements.text
# (creatre venv if required and) activate venv



# if gitignore exists, grep for the name of the ignored venv and use it
# if not use .venv
[[ -e .gitignore ]] && VENV_DIR=$(grep 'venv' .gitignore) && echo "${VENV_DIR}"

# if VENV_DIR is still unset get it from .gitignore, use .venv
[[ -z $VENV_DIR ]] && VENV_DIR=".venv"

# strip  a trailing slash from the VENV_DIR
VENV_DIR=${VENV_DIR%/}