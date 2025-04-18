public inherited sharing class ContentDocumentSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);
    private final ContentDocumentLinkSelector documentLinkSelector = (ContentDocumentLinkSelector) Application.Selector.newInstance(
        ContentDocumentLink.SObjectType
    );

    public SObjectType getSObjectType() {
        return ContentDocument.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentDocument.Id,
            ContentDocument.Title,
            ContentDocument.Description,
            ContentDocument.FileType,
            ContentDocument.ContentSize,
            ContentDocument.FileExtension,
            ContentDocument.LastViewedDate,
            ContentDocument.LatestPublishedVersionId,
            ContentDocument.ParentId,
            ContentDocument.PublishStatus,
            ContentDocument.SharingOption,
            ContentDocument.SharingPrivacy,
            ContentDocument.OwnerId
        };
    }

    public List<ContentDocument> selectByWorkspaceIds(List<Id> workspaceIds) {
        // Collect file IDs nested within workspace;
        List<ContentDocumentLink> links = this.documentLinkSelector.selectByLinkedEntityIds(workspaceIds);
        List<Id> contentDocumentIds = this.documentLinkSelector.collectContentDocumentIds(links);
        // Collect content document IDs within folder;
        if (contentDocumentIds.isEmpty()) {
            return new List<ContentDocument>();
        }
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('Id IN :contentDocumentIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'contentDocumentIds' => contentDocumentIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }

    public List<ContentDocument> selectByParentIds(List<Id> parentIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('ParentId IN :parentIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'parentIds' => parentIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }

    public List<ContentDocument> selectByOwnerIds(List<Id> ownerIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('OwnerId IN :ownerIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'ownerIds' => ownerIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
