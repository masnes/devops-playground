#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"

usage() {
  cat <<EOF
Usage:
  $0 username servername_in_tf_config

Example:
  $0 admin ca_server
EOF
}
if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi
target_server="$(TF_STATE="$script_dir/tf/" ./ansible/terraform-inventory --list | jq ".$2[0]" | tr -d '"')"
set -x
( "$script_dir"/ansible/generate-bastion-ssh-config.sh )
ssh "$1"@"$target_server" -F "$script_dir/ansible/ssh_config"
