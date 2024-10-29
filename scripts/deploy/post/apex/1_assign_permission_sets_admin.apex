// Assign PSG intended for internal users & admin permission set;
Set<String> psOrPsgNames = new Set<String>{
    'Minlopro_PSG_InternalUser',
    'Minlopro_PSG_DigExUser',
    'Minlopro_Admin',
    'Survey_Force_Admin',
    'Survey_Force_SuperAdmin'
};
PermissionSetService service = PermissionSetService.getInstance();
service.assign(UserInfo.getUserId(), psOrPsgNames);
