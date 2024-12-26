#!/usr/bin/env bash

# Inspired by https://medium.com/git-happy/navigating-git-branches-like-a-pro-the-git-branch-command-f190eb7eb7b6
# How to use:
# - bash ./scripts/util/prune_obsolete_git_branches.sh

mainBranchName="main"

for k in $(git branch --format="%(refname:short)" --merged "$mainBranchName" -r); do
  if (($(git log -1 --since='2 month ago' -s "$k" | wc -l) == 0)); then
    # Remove 'echo' below in order to prune obsolete branch
    echo "Obsolete branch = $k"
    # git branch -d $k && git push origin --delete $k
  fi
done

# Purges local branches linked to non-existing remote branches
# git fetch --prune
