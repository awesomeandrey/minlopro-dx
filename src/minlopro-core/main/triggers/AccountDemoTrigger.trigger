trigger AccountDemoTrigger on Account(before insert, before update, after insert, after update) {
    TriggerDispatcher.setContext(Account.SObjectType).run();
}
