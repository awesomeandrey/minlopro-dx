trigger EmailMessageTrigger on EmailMessage(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerDispatcher.setContext(EmailMessage.SObjectType).run();
}
