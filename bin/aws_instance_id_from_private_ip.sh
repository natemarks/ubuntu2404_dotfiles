#!/usr/bin/env bash
set -Eeuo pipefail

aws ec2 describe-instances \
--filters Name=network-interface.addresses.private-ip-address,Values="${1}" \
--query 'Reservations[*].Instances[*].{Instance:InstanceId}' \
--output text