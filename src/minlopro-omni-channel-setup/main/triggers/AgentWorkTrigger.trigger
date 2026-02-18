trigger AgentWorkTrigger on AgentWork(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerDispatcher.setContext(Schema.AgentWork.SObjectType).run();
}
