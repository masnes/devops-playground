#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"

usage() {
  cat <<EOF
Usage:
  $0
  $0 servername_in_tf_config

Examples:
  $0 # get all data
  $0 ca_server  # get data for one instance
EOF
}
if [[ $# -eq 0 ]]; then
  TF_STATE="$script_dir/tf/" "$script_dir"/ansible/terraform-inventory --list | jq "."
elif [[ $# -eq 1 ]]; then
  TF_STATE="$script_dir/tf/" "$script_dir"/ansible/terraform-inventory --list | jq ".$1[0]" | tr -d '"'
else
  usage
  exit 1
fi
