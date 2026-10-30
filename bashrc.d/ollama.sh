#!/usr/bin/env bash

# User-owned models dir so every file `make sync_models` reads is readable by
# this user (the system service's metadata/*.json files are mode 600). Must
# match Environment=OLLAMA_MODELS in ollama/ollama.service.
export OLLAMA_MODELS="$HOME/ollama-models"
