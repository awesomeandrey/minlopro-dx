#!/bin/bash

# How to use:
# - bash ./scripts/util/run_apex_script.sh SO set_up_org_admin
# - bash ./scripts/util/run_apex_script.sh SO set_up_digex_guest_user

# Define constants;
targetOrg=$1          #Mandatory parameter!
apexScriptFileName=$2 #Mandatory parameter!
apexScriptFilePath="scripts/apex/$2.apex"

echo "🔵 Running Apex Script [$2] against [$targetOrg] organization..."
echo
sf apex run --target-org $targetOrg --file $apexScriptFilePath
