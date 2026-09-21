#!/usr/bin/env bash
set -euo pipefail

DELIM=$'\t'
FZF_OPTS=(--height=40% --border --prompt "Instance: ")

INSTANCE_ID=$(
  aws ec2 describe-instances --output json \
    --filters Name=instance-state-name,Values=running \
    | jq -r '
      .Reservations[].Instances[]
      | ((.Tags // []) | map(select(.Key=="Name").Value) | .[0] // "<no-name>") as $name
      | .InstanceId as $id
      | ($name + "\t" + $id)
    ' \
    | fzf "${FZF_OPTS[@]}" --delimiter="$DELIM" --with-nth=1 --nth=1 \
    | cut -f2
) || true

if [[ -z "${INSTANCE_ID:-}" ]]; then
  echo "No instance selected." >&2
  exit 1
fi

aws ssm start-session --target "${INSTANCE_ID}"
