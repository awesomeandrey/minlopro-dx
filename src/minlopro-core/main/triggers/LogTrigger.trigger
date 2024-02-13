trigger LogTrigger on Log__e(after insert) {
    // Explicitly disable logging because it will cause unwanted PE recursion;
    TriggerDispatcher.debugModeEnabled = false;
    TriggerDispatcher.setContext(Log__e.SObjectType).run();
}
