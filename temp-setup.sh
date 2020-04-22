#!/bin/bash
set -e

script_dir="$(dirname "$(readlink -f "$0")")"

usage() {
  echo "Setup, then teardown in 30 minutes:"
  echo
  echo "$0"
  echo
  echo "You may provide a time interval. See \`man 1 at\` for all options."
  echo
  echo "Some examples:"
  echo
  echo "$0" "'30 minutes'"
  echo "$0" "'2 hours'"
  echo "$0" "'1 days'"
  echo
  echo "If run more than once, shutdown attempts will trigger at all given time intervals"
}

case "$1" in
  [Hh]*|?*)
    usage
    exit
    ;;
  *)
    ;;
esac

"$script_dir"/bin/schedule-destroy.sh "$1"
"$script_dir/tf/apply.sh" apply
