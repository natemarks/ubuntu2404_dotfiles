#!/usr/bin/env bash
set -Eeuo pipefail
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl

URL="https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl"
EXECUTABLE="${HOME}/bin/kubectl"

mkdir -p ~/bin
curl -L  "${URL}" \
--output "${EXECUTABLE}"
chmod 755 "${EXECUTABLE}"