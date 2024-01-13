// Query all Minlopro PSs & PSGs;
Map<Id, PermissionSet> permissionSetsByIds = new Map<Id, PermissionSet>(
    [SELECT Id FROM PermissionSet WHERE Name LIKE 'Minlopro_%']
);

// Assign them to the running user (aka Admin);
PermissionSetService service = PermissionSetService.getInstance();
service.assign(UserInfo.getUserId(), permissionSetsByIds.keySet());
