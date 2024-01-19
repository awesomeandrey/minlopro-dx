// Assign PSG intended for internal users & admin permission set;
PermissionSetService service = PermissionSetService.getInstance();
service.assign(UserInfo.getUserId(), Sets.of('Minlopro_PSG_InternalUser', 'Minlopro_PSG_DigExUser', 'Minlopro_Admin'));
