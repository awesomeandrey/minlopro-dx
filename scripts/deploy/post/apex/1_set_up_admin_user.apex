public without sharing class ScriptWorker {
    void setup() {
        final Id adminUserId = UserInfo.getUserId();

        // Assign PSGs
        Set<String> psOrPsgNames = new Set<String>{ 'Minlopro_PSG_Admin', 'Minlopro_PSG_DigExUser' };
        PermissionSetService service = PermissionSetService.getInstance();
        service.assign(adminUserId, psOrPsgNames);

        // Customize Admin user settings
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'DX_Admin' LIMIT 1][0];
        update new User(
            Id = adminUserId,
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
        User adminUser = [
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
            WHERE Id = :adminUserId
            LIMIT 1
        ][0];

        // Add user to public groups
        List<GroupMember> gMembers = new List<GroupMember>();
        for (Group targetGroup : [SELECT Id FROM Group WHERE DeveloperName IN ('OrgAdmins', 'OrgUsers', 'LogsViewers')]) {
            gMembers.add(new GroupMember(GroupId = targetGroup.Id, UserOrGroupId = adminUserId));
        }
        Database.insert(gMembers, false);

        // Check user details
        DebugTableFormatter formatter = new DebugTableFormatter(
            new List<String>{
                'Id',
                'Name',
                'UserRole.Name',
                'Country',
                'FederationIdentifier',
                'ExternalId__c',
                'TimeZoneSidKey'
            },
            Lists.of(adminUser)
        );
        formatter.log(String.format('⚪ Successfully set up [{0}] user:\n', Lists.of(adminUser.Name)));
    }
}
new ScriptWorker().setup();
