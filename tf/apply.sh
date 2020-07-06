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

pull_if_behind() {
  git remote update
  UPSTREAM='@{u}'
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
    return 0
  elif [ $LOCAL = $BASE ]; then
    git pull --rebase
    return 0
  elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
    return 0
  else
    git pull --rebase
    return 0
    #echo "Diverged" && exit 1
  fi
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
  pull_if_behind
else
  git stash push
  pull_if_behind || { git stash pop && echo 'failed to pull' && exit 1; }
  git stash pop
fi
tf_opts="-auto-approve -var=allowed_ips=[\"$(curl -4 https://canhazip.com)\"]"
terraform "$cmd" $tf_opts || true
terraform refresh  || true  # sync instance ips which don't update after eip assignment
git add *.tf terraform.tfstate
git commit -m "terraform $cmd run" -m "opts: $tf_opts" || true
if no_unstashed_changes ; then
  git pull --rebase
else
  git stash push
  pull_if_behind || { git stash pop && echo 'failed to git pull' && exit 1; }
  git stash pop
fi
git push
)
