// Customize Admin user settings;
final Id userId = UserInfo.getUserId();
UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'DX_Admin' LIMIT 1][0];
update new User(
    Id = userId,
    UserRoleId = adminRole.Id,
    FirstName = 'Minlopro',
    LastName = 'Admin',
    Title = 'Administrator',
    UserPreferencesUserDebugModePref = true,
    Country = 'United States',
    FederationIdentifier = UserInfo.getUserName(),
    ExternalId__c = UserInfo.getUserName(),
    UserPreferencesHasSentWarningEmail = true,
    UserPermissionsKnowledgeUser = true
);
User runningUser = [
    SELECT
        Name,
        UserPreferencesUserDebugModePref,
        Country,
        UserRole.Name,
        UserType,
        UserPermissionsKnowledgeUser,
        FederationIdentifier,
        ExternalId__c,
        TimeZoneSidKey
    FROM User
    WHERE Id = :userId
    LIMIT 1
][0];

// Add user to 'Org Admins' public group;
Group targetGroup = [SELECT Id FROM Group WHERE DeveloperName = 'OrgAdmins' LIMIT 1];
GroupMember gm = new GroupMember(GroupId = targetGroup.Id, UserOrGroupId = userId);
Database.insert(gm, false);

DebugTableFormatter formatter = new DebugTableFormatter(
    new List<String>{ 'Id', 'Name', 'UserRole.Name', 'Country', 'FederationIdentifier', 'ExternalId__c', 'TimeZoneSidKey' },
    Lists.of(runningUser)
);
formatter.log(String.format('⚪ Successfully set up [{0}] user:\n', Lists.of(runningUser.Name)));
