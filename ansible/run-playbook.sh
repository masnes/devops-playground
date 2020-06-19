#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"

# Pending setup of ansible vault, generate a local password with high
# entropy for use in a password file
mkdir -p "$script_dir"/files
if [[ ! -f "$script_dir"/files/generated-password ]]; then
  tr </dev/urandom -dc 'A-Za-z0-9' | head -c 22 > "$script_dir"/files/generated-password
fi

export TF_STATE="$script_dir/../tf/"
run_playbook() {
  ansible-playbook --inventory-file="$script_dir"/terraform-inventory "$@" --syntax-check
  ansible-playbook --inventory-file="$script_dir"/terraform-inventory "$@"
}
run_playbook "$@"
