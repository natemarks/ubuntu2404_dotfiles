#!/usr/bin/env bash
set -Eeuo pipefail

# whisper.cpp installation script
# Builds from source and installs whisper-stream to project bin directory

WHISPER_VERSION="v1.8.4"
WHISPER_REPO="https://github.com/ggml-org/whisper.cpp.git"
BUILD_DIR="${HOME}/tmp/whisper-build"

# Detect project root (script is in scripts/ subdirectory)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
TARGET_EXECUTABLE="${PROJECT_ROOT}/bin/whisper-stream-bin"
TARGET_WRAPPER="${PROJECT_ROOT}/bin/whisper-stream-wrapper.sh"
LOG_FILE="${HOME}/tmp/whisper-install.log"

# Setup logging
mkdir -p "$(dirname "${LOG_FILE}")"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo "=== Whisper installation started at $(date) ===="
echo "Project root: ${PROJECT_ROOT}"
echo "Target executable: ${TARGET_EXECUTABLE}"

# Ensure project bin directory exists
mkdir -p "${PROJECT_ROOT}/bin"

# Handle delete command
if [ $# -eq 1 ] && [ "$1" = "delete" ]; then
  echo "Removing ${TARGET_EXECUTABLE}"
  rm -f "${TARGET_EXECUTABLE}"
  echo "Removing ${TARGET_WRAPPER}"
  rm -f "${TARGET_WRAPPER}"
  echo "Removing model files from ${PROJECT_ROOT}/bin/models/"
  rm -rf "${PROJECT_ROOT}/bin/models"
  echo "Removed successfully"
  exit 0
fi

# Check if already installed
if [ -f "${TARGET_EXECUTABLE}" ] && [ -f "${TARGET_WRAPPER}" ]; then
  echo "whisper-stream-bin and wrapper already exist"
  echo "Binary: ${TARGET_EXECUTABLE}"
  echo "Wrapper: ${TARGET_WRAPPER}"
  echo "Run 'make whisper-clean' to remove before reinstalling"
  exit 0
fi

echo "Checking whisper.cpp build dependencies..."
# Check if required packages are installed
MISSING_PKGS=""
for pkg in build-essential cmake git libsdl2-dev; do
  if ! dpkg -l | grep -q "^ii  $pkg "; then
    MISSING_PKGS="$MISSING_PKGS $pkg"
  fi
done

if [ -n "$MISSING_PKGS" ]; then
  echo "Installing missing packages:$MISSING_PKGS"
  echo "This requires sudo access..."
  sudo apt-get update
  # shellcheck disable=SC2086
  sudo apt-get install -y $MISSING_PKGS
else
  echo "All required packages are already installed"
fi

echo "Creating build directory: ${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Clean up old build if it exists
if [ -d "${BUILD_DIR}/whisper.cpp" ]; then
  echo "Removing old whisper.cpp build directory..."
  rm -rf "${BUILD_DIR}/whisper.cpp"
fi

echo "Cloning whisper.cpp repository (${WHISPER_VERSION})..."
cd "${BUILD_DIR}"
git clone --depth 1 --branch "${WHISPER_VERSION}" "${WHISPER_REPO}"
cd whisper.cpp

echo "Downloading base.en model (~142 MB)..."
sh ./models/download-ggml-model.sh base.en

echo "Building whisper.cpp with SDL2 support (static linking)..."
cmake -B build -DWHISPER_SDL2=ON -DBUILD_SHARED_LIBS=OFF
cmake --build build -j --config Release

echo "Installing whisper-stream to ${TARGET_EXECUTABLE}"
cp ./build/bin/whisper-stream "${TARGET_EXECUTABLE}"
chmod +x "${TARGET_EXECUTABLE}"

echo "Installing model files to ${PROJECT_ROOT}/bin/models/"
mkdir -p "${PROJECT_ROOT}/bin/models"
cp -v ./models/ggml-base.en.bin "${PROJECT_ROOT}/bin/models/"

echo "Creating wrapper script at ${TARGET_WRAPPER}"
cat > "${TARGET_WRAPPER}" << 'WRAPPER_EOF'
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
WRAPPER_EOF
chmod +x "${TARGET_WRAPPER}"

echo "Cleaning up build directory..."
cd "${HOME}"
rm -rf "${BUILD_DIR}/whisper.cpp"

echo "Installation complete!"
echo "Binary location: ${TARGET_EXECUTABLE}"
echo "Wrapper location: ${TARGET_WRAPPER}"
echo "Model location: ${PROJECT_ROOT}/bin/models/ggml-base.en.bin"
echo ""
echo "Run 'make bin' to create symlink at ~/bin/whisper-stream"
echo "Run 'make bin' to create symlinks in ~/bin/"
echo "Then test with: cd ~/bin && whisper-stream"
echo "=== Installation finished at $(date) ===="
echo "Log file: ${LOG_FILE}"
