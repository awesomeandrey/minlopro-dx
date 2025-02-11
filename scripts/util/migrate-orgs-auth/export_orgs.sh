#!/bin/bash
# export_orgs.sh: Exports a separate JSON auth file for each authenticated org.

# Directory to store exported files
EXPORT_DIR="org_auth_files"
mkdir -p "$EXPORT_DIR"

# Get a list of all authenticated orgs
ORG_ALIASES=$(sf org list --json | jq -r '.result.nonScratchOrgs[].alias')

if [ -z "$ORG_ALIASES" ]; then
  echo "No authenticated orgs found."
  exit 1
fi

# Loop through each org alias and export the authentication file
for ORG_ALIAS in $ORG_ALIASES; do
  echo "Exporting authentication file for org: $ORG_ALIAS"
  if sf org display --target-org "$ORG_ALIAS" --verbose --json > "$EXPORT_DIR/${ORG_ALIAS}.json"; then
    echo "Exported: $EXPORT_DIR/${ORG_ALIAS}.json"
  else
    echo "Failed to export authentication for org: $ORG_ALIAS"
  fi
done

echo "All org authentication files have been exported to: $EXPORT_DIR"