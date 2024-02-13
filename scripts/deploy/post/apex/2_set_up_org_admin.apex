// Customize Admin user settings;
final Id userId = UserInfo.getUserId();
UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'DX_Admin' LIMIT 1][0];
update new User(
    Id = userId,
    UserRoleId = adminRole.Id,
    FirstName = 'Org',
    LastName = 'Admin',
    UserPreferencesUserDebugModePref = true,
    Country = 'United States',
    UserPermissionsKnowledgeUser = true,
    ExternalId__c = UserInfo.getUserName()
);
User runningUser = [
    SELECT
        Name,
        UserPreferencesUserDebugModePref,
        Country,
        UserRole.Name,
        UserType,
        UserPermissionsKnowledgeUser,
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
    new List<String>{
        'Id',
        'Name',
        'UserPreferencesUserDebugModePref',
        'Country',
        'UserPermissionsKnowledgeUser',
        'ExternalId__c',
        'TimeZoneSidKey'
    },
    Lists.of(runningUser)
);
formatter.log(String.format('⚪ Successfully set up [{0}] user:\n', Lists.of(runningUser.Name)));
