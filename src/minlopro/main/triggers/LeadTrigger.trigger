trigger LeadTrigger on Lead(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerDispatcher.setContext(Lead.SObjectType).run();
}
