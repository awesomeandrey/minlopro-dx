trigger BatchApexErrorEventTrigger on BatchApexErrorEvent(after insert) {
    TriggerDispatcher.setContext(BatchApexErrorEvent.SObjectType).run();
}
