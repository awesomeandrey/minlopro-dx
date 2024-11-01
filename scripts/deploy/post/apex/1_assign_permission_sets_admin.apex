// Assign PSG intended for internal users & admin permission set;
Set<String> psOrPsgNames = new Set<String>{ 'Minlopro_PSG_InternalUser', 'Minlopro_PSG_DigExUser', 'Minlopro_PSG_Admin' };
PermissionSetService service = PermissionSetService.getInstance();
service.assign(UserInfo.getUserId(), psOrPsgNames);
