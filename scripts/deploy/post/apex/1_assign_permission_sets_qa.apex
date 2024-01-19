// Lookup QA user by profile name;
final String minloproUserProfileName = 'Minlopro User';
List<User> foundUsers = [SELECT Id FROM User WHERE Profile.Name = :minloproUserProfileName LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug(String.format('\n\n QA User with [{0}] profile name was not found. \n', Lists.of(minloproUserProfileName)));
    return;
}

// Assign PSG intended for internal users;
User qaUser = foundUsers[0];
PermissionSetService service = PermissionSetService.getInstance();
service.assign(qaUser.Id, Sets.of('Minlopro_PSG_InternalUser'));
