#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
( # temp cd
cd "$script_dir/tf"
ssh ec2-user@"$(terraform output "$1" )"
)
