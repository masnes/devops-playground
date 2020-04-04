#!/bin/bash
set -e

script_dir="$(dirname "$(readlink -f "$0")")"

usage() {
  echo $0 "[a - pply | d - estroy]"
}


case $1 in
  a*)
    cmd="apply"
  ;;
  d*)
    cmd="destroy"
  ;;
  *)
    usage
    exit 1
  ;;
esac

set -x
( cd "$script_dir/"  # make sure we are in the tf directory for this part
if [ -f ./terraform.tfstate ]; then
  git add terraform.tfstate
fi
git add *.tf
git commit -m "pre terraform $cmd" || true
git pull --rebase
( set +e
terraform "$cmd" -auto-approve
)
git add terraform.tfstate *.tf
git commit -m "terraform $cmd run" || true
git pull --rebase
git push
)
