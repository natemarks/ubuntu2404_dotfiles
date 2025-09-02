#!/usr/bin/env bash
set -Eeuo pipefail
# https://github.com/sertvitas/exp-go-ec2list/releases/download/latest/ec2list
VERSION="latest"

mkdir -p ~/bin
curl -L  "https://github.com/sertvitas/exp-go-ec2list/releases/download/${VERSION}/ec2list" \
--output ~/bin/ec2list
chmod 755 ~/bin/ec2list