#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname "$(readlink -f "$0")")"

bastion_ip="$("$script_dir/../query-inventory.sh" bastion)"

cat > "$script_dir/ssh_config" <<EOF

# Bastion IP: ${bastion_ip}

StrictHostKeyChecking=no

HOST 172.16.*
  ProxyCommand ssh -W %h:%p ec2-user@${bastion_ip}
  IdentityFile ~/.ssh/id_rsa

HOST ${bastion_ip}
  User ec2-user
  IdentityFile ~/.ssh/id_rsa
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%r@%h:%p
  ControlPersist 5m
EOF
set -x
cat "$script_dir/ssh_config"
