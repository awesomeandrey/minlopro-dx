// Lookup QA user by profile name;
final String minloproUserProfileName = 'Minlopro User';
List<User> foundUsers = [SELECT Id FROM User WHERE Profile.Name = :minloproUserProfileName LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug(String.format('\n\n QA User with [{0}] profile name was not found. \n', Lists.of(minloproUserProfileName)));
    return;
}

// Query all Minlopro PSs & PSGs;
Map<Id, PermissionSet> permissionSetsByIds = new Map<Id, PermissionSet>(
        [SELECT Id FROM PermissionSet WHERE Name LIKE 'Minlopro_%']
);

// Assign them to the running user (aka Admin);
User qaUser = foundUsers[0];
PermissionSetService service = PermissionSetService.getInstance();
service.assign(qaUser.Id, permissionSetsByIds.keySet());
