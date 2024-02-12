#!/bin/bash

# How to use:
# - bash ./scripts/util/minify_global_styles.sh

CSS_FILE="./src/minlopro-core/main/staticresources/GlobalStyles/globalStyles.css"

echo "🔵 Minifying [$CSS_FILE]..."

npx cleancss --version

if [[ -f "$CSS_FILE" ]]; then
    npx cleancss -o "$CSS_FILE" "$CSS_FILE"
    git status --porcelain
    echo "Done!"
else
    echo "⚪ File not found: [$CSS_FILE]."
fi
echo
