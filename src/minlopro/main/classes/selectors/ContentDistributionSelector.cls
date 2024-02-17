public with sharing class ContentDistributionSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return ContentDistribution.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ContentDistribution.Name,
            ContentDistribution.ContentDocumentId,
            ContentDistribution.ContentDownloadUrl,
            ContentDistribution.ContentVersionId,
            ContentDistribution.PreferencesAllowViewInBrowser,
            ContentDistribution.PreferencesLinkLatestVersion,
            ContentDistribution.PreferencesNotifyOnVisit,
            ContentDistribution.PreferencesPasswordRequired,
            ContentDistribution.PreferencesAllowOriginalDownload,
            ContentDistribution.PreferencesAllowPDFDownload,
            ContentDistribution.ExpiryDate,
            ContentDistribution.DistributionPublicUrl,
            ContentDistribution.PdfDownloadUrl,
            ContentDistribution.Password,
            ContentDistribution.ViewCount,
            ContentDistribution.OwnerId
        };
    }

    public List<ContentDistribution> selectByContentVersionIds(List<Id> contentVersionIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('ContentVersionId IN :contentVersionIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'contentVersionIds' => contentVersionIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
