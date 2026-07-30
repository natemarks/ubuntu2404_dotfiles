#!/usr/bin/env bash
set -Eeuo pipefail
wget -q -O - https://workspaces-client-linux-public-key.s3-us-west-2.amazonaws.com/ADB332E7.asc | sudo apt-key add -
echo "deb [arch=amd64] https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/amazon-workspaces-clients.list
sudo apt-get update
sudo apt-get install -y workspacesclient
