#!/usr/bin/env bash
# Wrapper for whisper-stream that automatically specifies the model path
# This allows whisper-stream to be called from anywhere (including neovim)

# Get the directory where this script is ACTUALLY located (resolve symlinks)
SCRIPT_PATH="${BASH_SOURCE[0]}"
# Follow symlinks to find the real script location
while [ -L "${SCRIPT_PATH}" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" && pwd)"
    SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
    [[ ${SCRIPT_PATH} != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
done
SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" && pwd)"
MODEL_PATH="${SCRIPT_DIR}/models/ggml-base.en.bin"

# Find the actual whisper-stream binary
# Look for it in common locations
if [[ -x "${SCRIPT_DIR}/whisper-stream-bin" ]]; then
    WHISPER_BIN="${SCRIPT_DIR}/whisper-stream-bin"
elif command -v whisper-stream-bin &>/dev/null; then
    WHISPER_BIN="whisper-stream-bin"
else
    echo "Error: Cannot find whisper-stream binary" >&2
    exit 1
fi

# If -m or --model is not already in the arguments, add our model path
# Otherwise, let the user's model path take precedence
has_model_arg=false
for arg in "$@"; do
    if [[ "$arg" == "-m" ]] || [[ "$arg" == "--model" ]]; then
        has_model_arg=true
        break
    fi
done

if [[ "$has_model_arg" == "false" ]]; then
    exec "${WHISPER_BIN}" -m "${MODEL_PATH}" "$@"
else
    exec "${WHISPER_BIN}" "$@"
fi
