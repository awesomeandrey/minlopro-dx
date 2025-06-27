// Lookup QA user by alias;
final String qaUserAlias = 'qauser';
List<User> foundUsers = [SELECT Id FROM User WHERE Alias = :qaUserAlias AND IsActive = TRUE LIMIT 1];
if (foundUsers.isEmpty()) {
    System.debug(String.format('\n\n QA User with [{0}] alias was not found. \n', Lists.of(qaUserAlias)));
    return;
}

// Set up QA user;
User qaUser = foundUsers[0];

// Switch to custom profile + update QA user details;
UserRole qaUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'DX_User' LIMIT 1][0];
update new User(
    Id = qaUser.Id,
    UserRoleId = qaUserRole.Id,
    Profile = new Profile(Name = 'Minlopro User'),
    UserPermissionsKnowledgeUser = true,
    UserPreferencesUserDebugModePref = true
);

// Add user to public groups;
List<GroupMember> gMembers = new List<GroupMember>();
for (Group targetGroup : [SELECT Id FROM Group WHERE DeveloperName IN ('OrgUsers', 'LogsViewers')]) {
    gMembers.add(new GroupMember(GroupId = targetGroup.Id, UserOrGroupId = qaUser.Id));
}
Database.insert(gMembers, false);

// Assign PSG intended for internal users;
PermissionSetService service = PermissionSetService.getInstance();
service.assign(qaUser.Id, Sets.of('Minlopro_PSG_InternalUser'));
