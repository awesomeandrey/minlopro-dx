#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/custom/1_push_pre_deploy_metadata.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/1_push_pre_deploy_metadata.sh

set -e

read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
echo "🔵 Pushing PRE-DEPLOY metadata to [$TARGET_ORG_ALIAS] organization..."

sf project generate manifest \
  --name "manifests/package.xml" \
  --metadata "Certificate:Minlopro" \
  --metadata "ApexClass:AxiomSamlJitHandlerStub"

npx dotenv -e "scripts/.env.manifest" -- sf project deploy start \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "manifests/package.xml" \
  --wait 10
