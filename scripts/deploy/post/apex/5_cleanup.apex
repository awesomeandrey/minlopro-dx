// Make sure admin user does not have 'Minlopro_PSG_InternalUser' assigned;
final Id adminUserId = UserInfo.getUserId();
PermissionSetService service = PermissionSetService.getInstance();
service.unassign(adminUserId, Sets.of('Minlopro_PSG_InternalUser'));
