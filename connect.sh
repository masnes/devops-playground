#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
cd "$script_dir/tf"
ssh "$1"@"$(terraform output "$2")"
