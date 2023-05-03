#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
apexScriptFile="./scripts/apex/enable_debug_mode.cls"

sfdx apex run --target-org $targetOrg --file $apexScriptFile
