#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
export TF_STATE="$script_dir/tf/"
ansible-playbook --inventory-file="$script_dir"/terraform-inventory  ca-server.yml
