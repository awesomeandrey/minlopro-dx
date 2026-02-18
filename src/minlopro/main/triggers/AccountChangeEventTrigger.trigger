trigger AccountChangeEventTrigger on AccountChangeEvent(after insert) {
    TriggerDispatcher.setContext(Schema.AccountChangeEvent.SObjectType).run();
}
