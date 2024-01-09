#!/bin/bash

# How to use:
# - bash ./scripts/util/prettify_working_directory_files.sh

# Get a list of changed files that are tracked by git
files=$(git diff --name-only --diff-filter=ACM)

# Check if there are any files to process
if [ -z "$files" ]; then
    echo "⚪ No files have changed."
else
    # Run Prettier check on each changed file
    echo "🔵 Prettifying changed files in directory..."
    for file in $files; do
        if [[ -f $file ]]; then
            prettier --write "$file"
        fi
    done
fi
