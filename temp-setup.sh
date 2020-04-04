#!/bin/bash
set -e

script_dir="$(dirname "$(readlink -f "$0")")"

ADDITIONAL_TIME="30 minutes"
if [[ -n "$1" ]]; then
  ADDITIONAL_TIME="$1"
fi
echo "Temporarily setting things up for $ADDITIONAL_TIME"
(
set -x
at "now + $ADDITIONAL_TIME" <<EOF
"$script_dir/tf/apply.sh" destroy
EOF
)

#"$script_dir/tf/apply.sh" apply
