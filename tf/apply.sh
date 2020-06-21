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

no_unstashed_changes() {
  git update-index --refresh
  git diff-index --quiet HEAD --
}

set -x
( cd "$script_dir/"  # make sure we are in the tf directory for this part
terraform validate   # also, config better be valid or abort asap
terraform fmt
git add *.tf
if [ -f ./terraform.tfstate ]; then
  git add terraform.tfstate
fi
git commit -m "pre terraform $cmd" || true
if no_unstashed_changes ; then
  git pull --rebase
else
  git stash push
  git pull --rebase || git stash pop && echo 'failed to git pull' && exit 1
  git stash pop
fi
tf_opts="-auto-approve -var=allowed_ips=[\"$(curl -4 https://canhazip.com)\"]"
terraform "$cmd" $tf_opts
set +e
terraform refresh  # sync instance ips which don't update after eip assignment
set -e
git add *.tf terraform.tfstate
git commit -m <<EOF || true
terraform $cmd run

opts: $tf_opts
EOF

if no_unstashed_changes ; then
  git pull --rebase
else
  git stash push
  git pull --rebase || git stash pop && echo 'failed to git pull' && exit 1
  git stash pop
fi
git push
)
