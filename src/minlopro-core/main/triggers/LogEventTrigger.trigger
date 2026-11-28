trigger LogEventTrigger on LogEvent__e(after insert) {
    // Explicitly disable logging because it will cause unwanted PE recursion;
    TriggerDispatcher.debugModeEnabled = false;
    TriggerDispatcher.setContext(LogEvent__e.SObjectType).run();
}
