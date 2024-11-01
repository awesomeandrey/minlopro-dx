trigger AccountChangeEventTrigger on AccountChangeEvent(after insert) {
    TriggerDispatcher.setContext(AccountChangeEvent.SObjectType).run();
}
