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
terraform validate   # also, config better be valid or abort asap
terraform fmt
git add *.tf
if [ -f ./terraform.tfstate ]; then
  git add terraform.tfstate
fi
git commit -m "pre terraform $cmd" || true
git stash
git pull --rebase
git stash pop
set +e
terraform "$cmd" -auto-approve
set -e
git add *.tf terraform.tfstate
git commit -m "terraform $cmd run" || true
git pull --rebase
git push
)
