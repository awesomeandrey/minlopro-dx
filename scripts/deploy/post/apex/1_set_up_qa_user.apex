// Lookup QA user by alias;
final String qaUserAlias = 'qauser';
List<User> foundUsers = [SELECT Id FROM User WHERE Alias = :qaUserAlias AND IsActive = TRUE LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug(String.format('\n\n QA User with [{0}] alias was not found. \n', Lists.of(qaUserAlias)));
    return;
}

// Lookup custom profile by name;
final String profileName = 'Minlopro User';
List<Profile> foundProfiles = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
if (foundProfiles.isEmpty()) {
    System.debug(String.format('\n\n Profile with [{0}] name was not found. \n', Lists.of(profileName)));
    return;
}

// Set up QA user;
User qaUser = foundUsers[0];
Profile minloproProfile = foundProfiles.get(0);

// Switch to custom profile;
update new User(Id = qaUser.Id, ProfileId = minloproProfile.Id);

// Assign PSG intended for internal users;
PermissionSetService service = PermissionSetService.getInstance();
service.assign(qaUser.Id, Sets.of('Minlopro_PSG_InternalUser', 'Survey_Force_Guest'));
