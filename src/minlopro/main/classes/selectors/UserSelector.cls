public inherited sharing class UserSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return User.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            User.Id,
            User.FirstName,
            User.LastName,
            User.Name,
            User.IsActive,
            User.Username,
            User.ProfileId
        };
    }

    public override List<SObject> selectSObjectsById(Set<Id> userIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, true, true);
        queryFactory.setCondition('Id IN :userIds');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'userIds' => userIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }
}
