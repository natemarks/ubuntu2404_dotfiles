#!/usr/bin/env bash
set -Eeuo pipefail

# Keep this easy to bump when new fzf releases are published.
VERSION="0.71.0"
PLATFORM="linux_amd64"
EXECUTABLE="fzf"
ARCHIVE="${EXECUTABLE}-${VERSION}-${PLATFORM}.tar.gz"
URL="https://github.com/junegunn/fzf/releases/download/v${VERSION}/${ARCHIVE}"
DOC_URL="https://raw.githubusercontent.com/junegunn/fzf/master/doc/fzf.txt"

INSTALL_DIR="${HOME}/bin"
INSTALL_PATH="${INSTALL_DIR}/${EXECUTABLE}"
DOC_INSTALL_DIR="/usr/share/doc/fzf"

HELPER_SCRIPTS=(
  "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-preview.sh"
  "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux"
)

DOC_SHELL_ASSETS=(
  "common.sh|https://raw.githubusercontent.com/junegunn/fzf/master/shell/common.sh"
  "completion.bash|https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash"
  "key-bindings.bash|https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash"
)

overwrite=false

usage() {
  cat <<'EOF'
Usage: install_fzf.sh [--overwrite]

Installs fzf plus helper scripts to $HOME/bin.

Options:
  --overwrite  Reinstall even if files already exist in $HOME/bin.
  -h, --help   Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overwrite)
      overwrite=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

mkdir -p "${INSTALL_DIR}"

tmpdir="$(mktemp -d)"
archive_path="${tmpdir}/${ARCHIVE}"

cleanup() {
  rm -rf "${tmpdir}"
}

trap cleanup EXIT

install_from_url() {
  local source_url="$1"
  local destination_name="$2"
  local destination_path="${INSTALL_DIR}/${destination_name}"

  if [[ -f "${destination_path}" && "${overwrite}" != true ]]; then
    echo "${destination_name} already exists at ${destination_path}. Use --overwrite to reinstall."
    return 0
  fi

  echo "Downloading ${source_url}"
  curl -fsSL "${source_url}" -o "${destination_path}"
  chmod 0755 "${destination_path}"

  echo "Installed ${destination_name} to ${destination_path}"
}

install_doc_from_url() {
  local source_url="$1"
  local destination_name="$2"
  local destination_path="${DOC_INSTALL_DIR}/${destination_name}"
  local doc_tmp_path="${tmpdir}/${destination_name}"

  if [[ -f "${destination_path}" && "${overwrite}" != true ]]; then
    echo "${destination_name} already exists at ${destination_path}. Use --overwrite to reinstall."
    return 0
  fi

  echo "Downloading ${source_url}"
  curl -fsSL "${source_url}" -o "${doc_tmp_path}"

  if [[ -w "${DOC_INSTALL_DIR}" || ( ! -e "${DOC_INSTALL_DIR}" && -w "$(dirname "${DOC_INSTALL_DIR}")" ) ]]; then
    mkdir -p "${DOC_INSTALL_DIR}"
    install -m 0644 "${doc_tmp_path}" "${destination_path}"
  elif command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p "${DOC_INSTALL_DIR}"
    sudo install -m 0644 "${doc_tmp_path}" "${destination_path}"
  else
    echo "ERROR: cannot write to ${DOC_INSTALL_DIR}. Re-run as root or install sudo." >&2
    exit 1
  fi

  echo "Installed ${destination_name} to ${destination_path}"
}

if [[ -f "${INSTALL_PATH}" && "${overwrite}" != true ]]; then
  echo "${EXECUTABLE} already installed at ${INSTALL_PATH}. Use --overwrite to reinstall."
else
  echo "Downloading ${URL}"
  curl -fsSL "${URL}" -o "${archive_path}"

  tar -xzf "${archive_path}" -C "${tmpdir}" "${EXECUTABLE}"
  install -m 0755 "${tmpdir}/${EXECUTABLE}" "${INSTALL_PATH}"

  echo "Installed ${EXECUTABLE} ${VERSION} to ${INSTALL_PATH}"
fi

for script_url in "${HELPER_SCRIPTS[@]}"; do
  script_name="$(basename "${script_url}")"
  install_from_url "${script_url}" "${script_name}"
done

install_doc_from_url "${DOC_URL}" "fzf.txt"

for doc_asset in "${DOC_SHELL_ASSETS[@]}"; do
  doc_name="${doc_asset%%|*}"
  doc_url="${doc_asset#*|}"
  install_doc_from_url "${doc_url}" "${doc_name}"
done
