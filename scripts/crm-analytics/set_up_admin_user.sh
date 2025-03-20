#!/usr/bin/env bash

# How to use:
# - bash ./scripts/crm-analytics/set_up_admin_user.sh
# - echo "ORG_ALIAS" | bash ./scripts/crm-analytics/set_up_admin_user.sh

read -r -p "🔶 Enter target org alias: " SCRATCH_ORG_ALIAS
echo "🔵 Setting up ADMIN user at [$SCRATCH_ORG_ALIAS] organization..."

# Grab newly created scratch org username
sf config set target-org "$SCRATCH_ORG_ALIAS"
adminUsername=$(bash ./scripts/util/get_target_org_username.sh)
echo "CRMA SO admin username: $adminUsername"

# Fetch admin user ID
adminUserId=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "User" \
  --where "Username='$adminUsername'" \
  --json | jq -r '.result.Id')
echo "Admin User ID: $adminUserId"

# Set custom user name
sf data update record \
    --sobject "User" \
    --where "Id='$adminUserId'" \
    --values "FirstName='Admin' LastName='CRMA' Country='United States'" \
    --target-org "$SCRATCH_ORG_ALIAS"

# Assign custom permission set(s)
sf org assign permset \
    --name "CrmAnalyticsAdmin" \
    --name "CrmAnalyticsReadOnlyAccess" \
    --target-org "$SCRATCH_ORG_ALIAS" \
    --on-behalf-of "$adminUsername"

# Fetch 'CRMA_Users' public group ID
publicGroupId=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "Group" \
  --where "DeveloperName='CrmAnalyticsUsers'" \
  --json | jq -r '.result.Id')
echo "Public Group ID: $publicGroupId"

# Add user to 'CRMA_Users' public group
sf data create record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "GroupMember" \
  --values "GroupId='$publicGroupId' UserOrGroupId='$adminUserId'"

# Fetch CEO role
ceoUserRoleId=$(sf data get record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "UserRole" \
  --where "DeveloperName='CEO'" \
  --json | jq -r '.result.Id')
echo "CEO Role ID: $ceoUserRoleId"

# Assign role
sf data update record \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --sobject "User" \
  --record-id "$adminUserId" \
  --values "UserRoleId='$ceoUserRoleId'"
