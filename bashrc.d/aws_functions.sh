#!/usr/bin/env bash

ssmconnect() {
  aws ssm start-session --target "${1}"
}
ec2_name_from_id() {
  # shellcheck disable=2016
  aws ec2 describe-instances --instance-ids "$1" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --output text
}
