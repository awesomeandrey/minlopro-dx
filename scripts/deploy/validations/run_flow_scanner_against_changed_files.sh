#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/run_flow_scanner_against_changed_files.sh
# - echo "develop" | bash ./scripts/deploy/validations/run_flow_scanner_against_changed_files.sh

set -e

read -r -p "🔶 Enter target branch name to compare changes against: " baseRef

echo "🔵 Running Flow Scanner checks against baseRef [$baseRef]..."

bash ./scripts/deploy/validations/copy_changed_files.sh "$baseRef"

# https://github.com/Lightning-Flow-Scanner/lightning-flow-scanner-core
set -o pipefail
sf flow scan \
  --directory "build/src" \
  --failon "error" \
  --config ".flow-scanner.json" | tee "build/flow-scanner-results.txt"
