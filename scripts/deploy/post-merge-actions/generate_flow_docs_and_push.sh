#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post-merge-actions/generate_flow_docs_and_push.sh

docs_dir="assets/docs/hardis/flow2markdown/flows"

bash ./scripts/util/hardis/generate_flow_docs.sh
git add "$docs_dir"

if git status --short "$docs_dir" | grep -q "$docs_dir"; then
  # Flows markup files were changed
  git status --porcelain
  git commit -m "Automation: Generated Flows Docs 📑"
  git push origin HEAD
else
  echo "⚪ No changes detected, flows docs are up-to-date."
fi
