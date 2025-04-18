public inherited sharing class ContentWorkspaceSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return ContentWorkspace.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentWorkspace.Id,
            ContentWorkspace.Description,
            ContentWorkspace.DeveloperName,
            ContentWorkspace.IsRestrictContentTypes,
            ContentWorkspace.Name,
            ContentWorkspace.RootContentFolderId,
            ContentWorkspace.WorkspaceType
        };
    }

    public List<ContentWorkspace> selectByDeveloperNames(List<String> developerNames) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('DeveloperName IN :developerNames');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'developerNames' => developerNames },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
