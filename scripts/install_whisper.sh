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
TARGET_EXECUTABLE="${PROJECT_ROOT}/bin/whisper-stream"
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
  echo "Removed successfully"
  exit 0
fi

# Check if already installed
if [ -f "${TARGET_EXECUTABLE}" ]; then
  echo "whisper-stream already exists at ${TARGET_EXECUTABLE}"
  echo "Run 'make whisper-clean' or 'bash scripts/install_whisper.sh delete' to remove before reinstalling"
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

echo "Cleaning up build directory..."
cd "${HOME}"
rm -rf "${BUILD_DIR}/whisper.cpp"

echo "Installation complete!"
echo "Binary location: ${TARGET_EXECUTABLE}"
echo "Test with: whisper-stream --help"
echo "=== Installation finished at $(date) ===="
echo "Log file: ${LOG_FILE}"
