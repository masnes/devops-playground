#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
cd "$script_dir/tf"
set -x
ssh "$1"@"$(terraform output "$2")"
