#!/bin/bash
# import_orgs_with_alias.sh: Authenticates each org using its corresponding JSON file and assigns aliases.

# Directory containing JSON auth files
IMPORT_DIR="org_auth_files"

if [ ! -d "$IMPORT_DIR" ]; then
  echo "Directory $IMPORT_DIR does not exist. Please copy the JSON files to this directory."
  exit 1
fi

# Authenticate each org using its JSON file and assign its alias
for JSON_FILE in "$IMPORT_DIR"/*.json; do
  ORG_ALIAS=$(basename "$JSON_FILE" .json)
  echo "Authenticating org: $ORG_ALIAS with alias: $ORG_ALIAS"

  # Authenticate the org with alias
  if sf org login sfdx-url --sfdx-url-file "$JSON_FILE" --alias "$ORG_ALIAS"; then
    echo "Successfully authenticated org: $ORG_ALIAS with alias: $ORG_ALIAS"
  else
    echo "Failed to authenticate org: $ORG_ALIAS"
  fi
done

echo "All orgs have been processed with their aliases."