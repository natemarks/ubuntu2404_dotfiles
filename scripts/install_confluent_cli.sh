#!/usr/bin/env bash
set -Eeuo pipefail

# installs the confluent executable to ./bin/
curl -sL --http1.1 https://cnfl.io/cli | sh -s -- latest
mv bin/confluent "${HOME}/bin"
rmdir bin