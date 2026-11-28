public without sharing class TH_LogEvent_CaptureAndPersist extends BasicTriggerHandler {
    public override Integer getMaxLoopCount() {
        return 1;
    }

    public override void afterInsert(List<SObject> newRecords) {
        List<LogEntry__c> logEntriesToInsert = new List<LogEntry__c>();
        for (LogEvent__e logEvent : (List<LogEvent__e>) newRecords) {
            logEntriesToInsert.add(new LogData(logEvent).castToEntry());
        }
        insert logEntriesToInsert;
    }
}
