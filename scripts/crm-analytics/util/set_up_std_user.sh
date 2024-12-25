#!/usr/bin/env bash

# How to use:
# - bash ./scripts/crm-analytics/util/set_up_std_user.sh
# - echo "ORG_ALIAS" | bash ./scripts/crm-analytics/util/set_up_std_user.sh

read -p "🔶 Enter CRMA scratch org alias: " SCRATCH_ORG_ALIAS
echo "🔵 Setting up STD user at [$SCRATCH_ORG_ALIAS] organization..."

# Create standard user
sf org create user \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --definition-file "config/users/std-user-def.json"

# Fetch standard user ID/username
stdUserDef=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "User" \
  --where "Alias='stduser' IsActive=TRUE" \
  --json)
stdUserId=$(echo "$stdUserDef" | jq -r '.result.Id')
echo "Standard User ID: $stdUserId"
stdUserUsername=$(echo "$stdUserDef" | jq -r '.result.Username')
echo "Standard User Username: $stdUserUsername"

# Assign OOO permission set(s)
sf org assign permset \
    --name "EinsteinAnalyticsPlusUser" \
    --target-org "$SCRATCH_ORG_ALIAS" \
    --on-behalf-of "$stdUserUsername"

# Fetch 'CRMA_Users' public group ID
publicGroupId=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "Group" \
  --where "DeveloperName='CRMA_Users'" \
  --json | jq -r '.result.Id')
echo "Public Group ID: $publicGroupId"

# Add user to 'CRMA_Users' public group
sf data create record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "GroupMember" \
  --values "GroupId='$publicGroupId' UserOrGroupId='$stdUserId'"

# Fetch role from lower level (VP Marketing)
vpMarketingUserRolId=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "UserRole" \
  --where "DeveloperName='VPMarketing'" \
  --json | jq -r '.result.Id')
echo "VP Marketing Role ID: $vpMarketingUserRolId"

# Assign role
sf data update record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "User" \
  --record-id "$stdUserId" \
  --values "UserRoleId='$vpMarketingUserRolId'"
