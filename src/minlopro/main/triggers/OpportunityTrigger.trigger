trigger OpportunityTrigger on Opportunity(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerDispatcher.setContext(Schema.Opportunity.SObjectType).run();
}
