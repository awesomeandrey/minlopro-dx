#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post-merge-actions/create_tag_and_push.sh

set -e

day_name=$(date +%d)
month_name=$(date +%B)
year_name=$(date +%Y)

tag_name="$month_name-$year_name"
full_tag_name="$day_name-$month_name-$year_name"

# Create tag (force overwrite if name already exists)
git tag --annotate "$tag_name" --message "Automated tag ☑️($full_tag_name)" --force

# Delete tag via `git tag -d "$tag_name"`

# List last 5 tags
git tag --sort=-creatordate -n | head -n 5

# Push tag
git push origin "$tag_name" --force
