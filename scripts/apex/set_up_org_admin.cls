final Id userId = UserInfo.getUserId();
UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'DX_Admin' LIMIT 1][0];
update new User(
        Id = userId,
        UserRoleId = adminRole.Id,
        FirstName = 'Org',
        LastName = 'Admin',
        UserPreferencesUserDebugModePref = true,
        Country = 'United States'
);
User runningUser = [
        SELECT Name, UserPreferencesUserDebugModePref, Country, UserRole.Name
        FROM User
        WHERE Id = :userId
        LIMIT 1
][0];
System.debug('\n\n Running User Info => ' + runningUser + '\n');
System.debug(String.format('\n\n Successfully set up admin user. \n', Lists.of(UserInfo.getName())));
// Auto assign all custom PS/PSGs;
List<PermissionSet> customPermissionSets = [
        SELECT Id, Name, PermissionSetGroupId, IsCustom, Type, License.Name
        FROM PermissionSet
        WHERE IsCustom = TRUE
        AND Type IN ( 'Regular', 'Group')
        AND License.Name IN ( NULL, 'Salesforce')
];
List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (PermissionSet permissionSetItem : customPermissionSets) {
    if (permissionSetItem.Type.equalsIgnoreCase('Regular')) {
        assignments.add(new PermissionSetAssignment(
                PermissionSetId = permissionSetItem.Id,
                AssigneeId = userId
        ));
    } else if (permissionSetItem.Type.equalsIgnoreCase('Group')) {
        assignments.add(new PermissionSetAssignment(
                PermissionSetGroupId = permissionSetItem.PermissionSetGroupId,
                AssigneeId = userId
        ));
    }
}
Boolean hasFailedPsAssignment = false;
for (Database.SaveResult saveResultItem : Database.insert(assignments, false)) {
    if (!saveResultItem.isSuccess()) {
        Database.Error errorItem = saveResultItem.getErrors().get(0);
        if (errorItem.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
            hasFailedPsAssignment = true;
            System.debug('\n\n Unexpected Assignment Error => ' + errorItem + '\n');
        }
    }
}
if (hasFailedPsAssignment) {
    System.debug('\n\n Some of Permission Set and/or PSG were NOT assigned.\n');
} else {
    System.debug('\n\n All Permission Sets and/or PSGs were successfully assigned.\n');
}