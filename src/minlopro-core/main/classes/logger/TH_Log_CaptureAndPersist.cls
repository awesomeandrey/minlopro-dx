public without sharing class TH_Log_CaptureAndPersist extends BasicTriggerHandler {
    public override Integer getMaxLoopCount() {
        return 1;
    }

    public override void afterInsert(List<SObject> newRecords) {
        List<LogEntry__c> logEntries = new List<LogEntry__c>();
        for (Log__e logEvent : (List<Log__e>) newRecords) {
            logEntries.add(new LogData(logEvent).castToEntry());
        }
        if (!logEntries.isEmpty()) {
            insert logEntries;
        }
    }
}
