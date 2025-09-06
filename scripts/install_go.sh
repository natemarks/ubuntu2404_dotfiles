#!/usr/bin/env bash
set -Eeuo pipefail

GO_VERSION="1.25.1"

mkdir -p ~/bin/go/"${GO_VERSION}"
curl -L  "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
--output ~/bin/go/${GO_VERSION}/go${GO_VERSION}.linux-amd64.tar.gz

tar -xzvf ~/bin/go/${GO_VERSION}/go${GO_VERSION}.linux-amd64.tar.gz \
--directory ~/bin/go/"${GO_VERSION}"

~/bin/go/"${GO_VERSION}"/go/bin/go install -v golang.org/x/tools/gopls@latest
~/bin/go/"${GO_VERSION}"/go/bin/go install honnef.co/go/tools/cmd/staticcheck@latest
~/bin/go/"${GO_VERSION}"/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
