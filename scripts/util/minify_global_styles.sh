#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/minify_global_styles.sh

# src/minlopro-core/../staticresources/../globalStyles.css
CSS_FILE="$(find "src" -type f -name "globalStyles.css" | head -n 1)"

echo "🔵 Minifying [$CSS_FILE]..."
npx cleancss --version

if [[ -f "$CSS_FILE" ]]; then
    npx cleancss -o "$CSS_FILE" "$CSS_FILE"
    git status --porcelain
    echo "Done!"
else
    echo "⚪ File not found: [$CSS_FILE]."
fi
