public inherited sharing class AccountSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            Account.Id,
            Account.Name,
            Account.AnnualRevenue,
            Account.Industry,
            Account.PersonEmail,
            Account.PersonTitle,
            Account.CheckIfDuplicate__pc
        };
    }

    public List<Account> selectByIdWithMode(List<Id> accountIds, AccessLevel level) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('Id IN :accountIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'accountIds' => accountIds },
            level
        );
    }
}
