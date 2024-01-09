#!/bin/bash

# How to use:
# - bash ./scripts/deploy/pre/custom/minify_global_styles.sh

CSS_FILE="./src/minlopro-core/main/staticresources/GlobalStyles/globalStyles.css"

echo "🔵 Minifying [$CSS_FILE]..."

cleancss --version

if [[ -f "$CSS_FILE" ]]; then
    cleancss -o "$CSS_FILE" "$CSS_FILE"
    echo "Done!"
else
    echo "⚪ File not found: [$CSS_FILE]."
fi
