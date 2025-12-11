#!/usr/bin/env bash

set -e

# How to use:
# - bash ./scripts/deploy/validations/run_code_analyzer.sh
# - git diff --name-only "ecf9...7a57" HEAD | grep -iE "^src" | bash ./scripts/deploy/validations/run_code_analyzer.sh

BUILD_DIR="build"
SRC_DIR="src"

mkdir -p "$BUILD_DIR"

# Populate default flags
FLAGS_DIR=$(mktemp -d) && trap 'rm -rf $FLAGS_DIR' EXIT
touch "$FLAGS_DIR/severity-threshold"; echo "2" > "$FLAGS_DIR/severity-threshold"
touch "$FLAGS_DIR/output-file"; {
  echo "$BUILD_DIR/code-scan-results.csv"
  echo "$BUILD_DIR/code-scan-results.html"
  echo "$BUILD_DIR/code-scan-results.json"
  echo "$BUILD_DIR/code-scan-results.sarif"
} > "$FLAGS_DIR/output-file"
touch "$FLAGS_DIR/rule-selector"; echo "all" > "$FLAGS_DIR/rule-selector"
touch "$FLAGS_DIR/target"

# Check if stdin has data (-t 0 stands for empty stdin)
if [[ -t 0 ]]; then
  # Scan whole codebase selecting narrow set of metadata types
  {
    echo "$SRC_DIR/**/aura/**"
    echo "$SRC_DIR/**/classes/**"
    echo "$SRC_DIR/**/flows/**"
    echo "$SRC_DIR/**/lwc/**"
  } > "$FLAGS_DIR/target"
else
  # Scan passed files only (covering all metadata types within the list)
  while IFS= read -r filepath; do
    if [[ -f "$filepath" ]]; then
      echo "$filepath" >> "$FLAGS_DIR/target"
    else
      echo "Skipping unknown file: $filepath"
    fi
  done < <(cat) # Take stdin data
fi

sf code-analyzer run --flags-dir "$FLAGS_DIR"
