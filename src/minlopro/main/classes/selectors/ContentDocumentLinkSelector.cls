public with sharing class ContentDocumentLinkSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return ContentDocumentLink.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentDocumentLink.Id,
            ContentDocumentLink.ContentDocumentId,
            ContentDocumentLink.LinkedEntityId,
            ContentDocumentLink.ShareType,
            ContentDocumentLink.Visibility
        };
    }

    public List<Id> collectLinkedEntityIds(List<ContentDocumentLink> links) {
        Set<Id> linkedEntityIds = new Set<Id>();
        for (ContentDocumentLink linkItem : links) {
            linkedEntityIds.add(linkItem.LinkedEntityId);
        }
        return Lists.of(linkedEntityIds);
    }

    public List<Id> collectContentDocumentIds(List<ContentDocumentLink> links) {
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink linkItem : links) {
            contentDocumentIds.add(linkItem.ContentDocumentId);
        }
        return Lists.of(contentDocumentIds);
    }

    public List<ContentDocumentLink> selectByLinkedEntityIds(List<Id> linkedEntityIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('LinkedEntityId IN :linkedEntityIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'linkedEntityIds' => linkedEntityIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
