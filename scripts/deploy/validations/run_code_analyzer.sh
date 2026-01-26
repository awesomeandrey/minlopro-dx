#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/run_code_analyzer.sh
# - git diff --name-only develop HEAD | grep -iE "^src" | bash ./scripts/deploy/validations/run_code_analyzer.sh

BUILD_DIR="build"
FLAGS_DIR="$BUILD_DIR/code-scan-flags-dir"
SRC_DIR="src"

mkdir -p "$BUILD_DIR"
rm -rf "$FLAGS_DIR"
mkdir -p "$FLAGS_DIR"

touch "$FLAGS_DIR/severity-threshold"; echo "2" > "$FLAGS_DIR/severity-threshold"

touch "$FLAGS_DIR/output-file"; {
  echo "$BUILD_DIR/code-scan-result.csv"
  echo "$BUILD_DIR/code-scan-result.html"
  echo "$BUILD_DIR/code-scan-result.json"
  echo "$BUILD_DIR/code-scan-result.sarif"
} > "$FLAGS_DIR/output-file"

touch "$FLAGS_DIR/rule-selector"; {
  echo "all:1"
  echo "all:2"
  echo "all:3"
  echo "all:4"
  echo "all:5"
} > "$FLAGS_DIR/rule-selector"

touch "$FLAGS_DIR/target" # Check if stdin has data (-t 0 stands for empty stdin)
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
