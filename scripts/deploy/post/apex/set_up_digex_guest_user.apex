final String SITE_NAME = 'DigEx';

List<Site> sitesList = [
    SELECT Id, Name, GuestUserId, GuestUser.Name, GuestUser.UserType
    FROM Site
    WHERE Name = :SITE_NAME
    LIMIT 1
];
if (sitesList.isEmpty()) {
    System.debug(String.format('\n\n ❌ Site was not found: [{0}] \n', Lists.of(SITE_NAME)));
    return;
}

final User guestUser = sitesList[0].GuestUser;

// Assign specific PS/PSGs to site guest user;
List<String> permSetAndPsgNames = new List<String>{ 'Minlopro_PSG_DigExUser' };
List<PermissionSet> customPermissionSetsAndGroups = [
    SELECT Id, Name, PermissionSetGroupId, IsCustom, Type, License.Name
    FROM PermissionSet
    WHERE IsCustom = TRUE AND Name IN :permSetAndPsgNames
];
List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (PermissionSet permissionSetItem : customPermissionSetsAndGroups) {
    if (permissionSetItem.Type.equalsIgnoreCase('Regular')) {
        assignments.add(new PermissionSetAssignment(PermissionSetId = permissionSetItem.Id, AssigneeId = guestUser.Id));
    } else if (permissionSetItem.Type.equalsIgnoreCase('Group')) {
        assignments.add(
            new PermissionSetAssignment(PermissionSetGroupId = permissionSetItem.PermissionSetGroupId, AssigneeId = guestUser.Id)
        );
    }
}
Boolean hasFailedPsAssignment = false;
for (Database.SaveResult saveResultItem : Database.insert(assignments, false)) {
    if (!saveResultItem.isSuccess()) {
        Database.Error errorItem = saveResultItem.getErrors().get(0);
        if (errorItem.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
            hasFailedPsAssignment = true;
            System.debug('\n\n ❌ Unexpected Assignment Error => ' + errorItem + '\n');
        }
    }
}
if (hasFailedPsAssignment) {
    System.debug(
        String.format(
            '\n\n ❌ Some of Permission Set and/or PSG were NOT assigned to [{0}] user. \n',
            Lists.of(JSON.serializePretty(guestUser))
        )
    );
} else {
    System.debug(
        String.format(
            '\n\n ✅ All Permission Sets and/or PSGs were successfully assigned to [{0}] user. \n',
            Lists.of(JSON.serializePretty(guestUser))
        )
    );
}
