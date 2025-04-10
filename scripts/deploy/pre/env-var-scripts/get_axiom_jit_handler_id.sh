#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/env-var-scripts/get_axiom_jit_handler_id.sh
# - echo $ORG_ALIAS | bash ./scripts/deploy/pre/env-var-scripts/get_axiom_jit_handler_id.sh

trap 'echo "null"' ERR
set -e

read -r -p "🔶 Enter target org alias: " targetOrgAlias

stubApexClassId=$(
  sf data query \
    --query "SELECT Id, Name FROM ApexClass WHERE Name = 'AxiomSamlJitHandlerStub' LIMIT 1" \
    --target-org "$targetOrgAlias" \
    --json | jq -r '.result.records[0].Id'
)

apexClassId=$(
  sf data query \
  --query "SELECT Id, Name FROM ApexClass WHERE Name = 'AxiomSamlJitHandler' LIMIT 1" \
  --target-org "$targetOrgAlias" \
  --json | jq -r '.result.records[0].Id'
)

if [ -z "$apexClassId" ] || [ "null" == "$apexClassId" ]; then
  apexClassId="$stubApexClassId"
fi

echo "${apexClassId:0:15}"
