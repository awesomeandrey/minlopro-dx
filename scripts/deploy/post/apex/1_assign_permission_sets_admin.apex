// Assign PSG intended for internal users & admin permission set;
Set<String> psOrPsgNames = new Set<String>{
    'Minlopro_PSG_InternalUser',
    'Minlopro_PSG_DigExUser',
    'Minlopro_Admin',
    // 'Survey Force' unmanaged package permission sets;
    'Survey_Force_Admin',
    'Survey_Force_SuperAdmin',
    // 'DLRS' managed package permission sets;
    'LookupRollupSummariesFull',
    'LookupRollupSummariesReadOnly'
};
PermissionSetService service = PermissionSetService.getInstance();
service.assign(UserInfo.getUserId(), psOrPsgNames);
