#!/usr/bin/env bash
set -Eeuo pipefail

# Install or upgrade Zoom from the official .deb (Zoom has no apt repo).
# Always fetches the latest build; skips the install if it is already current.

DEB_URL="https://zoom.us/client/latest/zoom_amd64.deb"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT
deb_file="${tmp_dir}/zoom_amd64.deb"

curl -fsSL -o "${deb_file}" "${DEB_URL}"

latest_version="$(dpkg-deb -f "${deb_file}" Version)"
installed_version="$(dpkg-query -W -f='${Version}' zoom 2>/dev/null || true)"

if [[ "${installed_version}" == "${latest_version}" ]]; then
	echo "zoom ${installed_version} is already the latest version"
	exit 0
fi

echo "installing zoom ${latest_version} (installed: ${installed_version:-none})"
# apt (not dpkg -i) so dependencies are resolved
sudo apt-get install -y "${deb_file}"
dpkg-query -W zoom
