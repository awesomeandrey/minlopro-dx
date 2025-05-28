#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/run_prettier_check_against_changed_files.sh
# - echo "develop" | bash ./scripts/deploy/validations/run_prettier_check_against_changed_files.sh

set -e

read -r -p "🔶 Enter target branch name to compare changes against: " baseRef

echo "🔵 Running Prettier checks against baseRef [$baseRef]..."

bash ./scripts/deploy/validations/copy_changed_files.sh "$baseRef"

copiedSrcFolder="build/src"
if [ -z "$(ls $copiedSrcFolder)" ]; then
  echo "⚪ No changed files detected in [$copiedSrcFolder] folder!"
  exit 0
fi

npx prettier --check "$copiedSrcFolder/**" --ignore-path ".prettierignore"
