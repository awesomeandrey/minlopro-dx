#!/bin/bash

# How to use:
# - bash ./scripts/util/run_apex_script.sh SO enable_debug_mode

# Define constants;
targetOrg=$1          #Mandatory parameter!
apexScriptFileName=$2 #Mandatory parameter!
apexScriptFilePath="scripts/apex/$2.cls"

sfdx apex run --target-org $targetOrg --file $apexScriptFilePath
