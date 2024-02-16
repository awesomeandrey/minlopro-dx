public with sharing class ContentWorkspacePermissionSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return ContentWorkspacePermission.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentWorkspacePermission.Id,
            ContentWorkspacePermission.Description,
            ContentWorkspacePermission.PermissionsAddComment,
            ContentWorkspacePermission.PermissionsAddContent,
            ContentWorkspacePermission.PermissionsDeleteContent,
            ContentWorkspacePermission.PermissionsDeliverContent,
            ContentWorkspacePermission.PermissionsManageWorkspace,
            ContentWorkspacePermission.PermissionsOrganizeFileAndFolder,
            ContentWorkspacePermission.Type
        };
    }

    public List<ContentWorkspacePermission> selectByType(String permissionType) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('Type = :permissionType');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'permissionType' => permissionType },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
