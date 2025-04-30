public inherited sharing class LeadSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            Lead.Id,
            Lead.Name,
            Lead.Company,
            Lead.AnnualRevenue,
            Lead.Email,
            Lead.GenderIdentity,
            Lead.CurrencyIsoCode,
            Lead.CreatedDate,
            Lead.LastModifiedDate,
            Lead.LeadSource,
            Lead.Status,
            Lead.Phone,
            Lead.MobilePhone,
            Lead.FirstName,
            Lead.LastName,
            Lead.Title,
            Lead.Website,
            Lead.IsConverted,
            Lead.IsUnreadByOwner,
            Lead.OwnerId,
            Lead.ConvertedContactId,
            Lead.ConvertedAccountId,
            Lead.ConvertedOpportunityId
        };
    }

    public List<Lead> selectMineNonConverted() {
        return this.selectMineWithCondition('IsConverted = FALSE');
    }

    public List<Lead> selectMineConverted() {
        return this.selectMineWithCondition('IsConverted = TRUE');
    }

    public List<Lead> selectMineWithCondition(String condition) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, true, true);
        queryFactory.setScope('mine');
        queryFactory.setCondition(condition);
        queryFactory.setLimit(10);
        queryFactory.setOrdering(Lead.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING);
        return this.repository.query(queryFactory.toSOQL());
    }
}
