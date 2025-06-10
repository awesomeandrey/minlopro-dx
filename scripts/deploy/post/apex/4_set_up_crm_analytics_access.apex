// Check if target salesforce org has CRM Analytics licenses
final String crmAnalyticsLicenseName = 'EinsteinAnalyticsPlusPsl';
if ([SELECT Id FROM PermissionSetLicense WHERE DeveloperName = :crmAnalyticsLicenseName LIMIT 1].isEmpty()) {
    System.debug(
        String.format(
            '\n\n ⚪ [{0}] org has no CRM Analytics licenses: {1}. \n',
            Lists.of(UserInfo.getOrganizationName(), crmAnalyticsLicenseName)
        )
    );
    return;
}

// Query users
User adminUser = new User(Id = UserInfo.getUserId());
List<User> foundUsers = [SELECT Id FROM User WHERE Alias = 'qauser' AND IsActive = TRUE LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug(String.format('\n\n QA User with [{0}] alias was not found. \n', Lists.of('qauser')));
    return;
}
User qaUser = foundUsers[0];
foundUsers = [SELECT Id FROM User WHERE Profile.Name = 'Analytics Cloud Integration User' AND IsActive = TRUE LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug('\n\n CRM Analytics Integration User was not found. \n');
    return;
}
User analyticsIntegrationUser = foundUsers[0];

// Add user to public groups
List<GroupMember> gMembers = new List<GroupMember>();
for (Group targetGroup : [SELECT Id FROM Group WHERE DeveloperName IN ('CrmAnalyticsUsers')]) {
    gMembers.add(new GroupMember(GroupId = targetGroup.Id, UserOrGroupId = adminUser.Id));
    gMembers.add(new GroupMember(GroupId = targetGroup.Id, UserOrGroupId = qaUser.Id));
}
Database.insert(gMembers, false);

// Assign permission set(s)
PermissionSetService service = PermissionSetService.getInstance();
service.assign(adminUser.Id, Sets.of('EinsteinAnalyticsPlusAdmin', 'CrmAnalyticsAdmin', 'CrmAnalyticsReadOnlyAccess'));
service.assign(qaUser.Id, Sets.of('EinsteinAnalyticsPlusUser'));
service.assign(analyticsIntegrationUser.Id, Sets.of('CrmAnalyticsReadOnlyAccess'));
