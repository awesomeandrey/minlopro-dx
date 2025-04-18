public inherited sharing class ContentVersionSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return ContentVersion.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentVersion.Id,
            ContentVersion.Title,
            ContentVersion.ContentDocumentId,
            ContentVersion.Description,
            ContentVersion.FileType,
            ContentVersion.ContentSize,
            ContentVersion.FileExtension,
            ContentVersion.PublishStatus,
            ContentVersion.SharingOption,
            ContentVersion.SharingPrivacy,
            ContentVersion.OwnerId,
            ContentVersion.VersionData
        };
    }

    public List<ContentVersion> selectByTypeWithLimit(List<String> fileTypes, Integer count) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('FileType IN :fileTypes AND IsLatest = TRUE');
        queryFactory.setLimit(count);
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'fileTypes' => fileTypes },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
