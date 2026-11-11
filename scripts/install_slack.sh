#!/usr/bin/env bash
set -Eeuo pipefail

# Install or upgrade Slack from the official .deb (Slack's apt repo is unmaintained).
# Always resolves the latest release; skips the download if it is already current.

API_URL="https://slack.com/api/desktop.latestRelease?arch=x64&variant=deb"

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
	echo "Error: Slack is only published for amd64" >&2
	exit 1
fi

release_json="$(curl -fsSL "${API_URL}")"
latest_version="$(jq -er '.version' <<<"${release_json}")"
deb_url="$(jq -er '.download_url' <<<"${release_json}")"

installed_version="$(dpkg-query -W -f='${Version}' slack-desktop 2>/dev/null || true)"

if [[ "${installed_version}" == "${latest_version}" ]]; then
	echo "slack ${installed_version} is already the latest version"
	exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT
deb_file="${tmp_dir}/slack-desktop.deb"

echo "installing slack ${latest_version} (installed: ${installed_version:-none})"
curl -fsSL -o "${deb_file}" "${deb_url}"

# apt (not dpkg -i) so dependencies are resolved
sudo apt-get install -y "${deb_file}"
dpkg-query -W slack-desktop
