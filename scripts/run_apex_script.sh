#!/bin/bash

# Define constants;
targetOrg=$1          #Mandatory parameter!
apexScriptFileName=$2 #Mandatory parameter!
apexScriptFilePath="./scripts/apex/$2.cls"

sfdx apex run --target-org $targetOrg --file $apexScriptFilePath

# Usages:
# bash ./scripts/run_apex_script.sh SO assign_minlopro_digex_psg
# bash ./scripts/run_apex_script.sh SO assign_minlopro_psg
# bash ./scripts/run_apex_script.sh SO enable_debug_mode
