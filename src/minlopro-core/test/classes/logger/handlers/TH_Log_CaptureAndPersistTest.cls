@IsTest
private class TH_Log_CaptureAndPersistTest {
    @IsTest
    static void testInsertLogEntry() {
        final Integer logsAmount = 50;
        // Turn on selective mode;
        TriggerDispatcher.debugModeEnabled = true;
        Assert.isFalse(TriggerDispatcher.isSelectiveMode());
        TriggerDispatcher.enableObjectHandler(Log__e.SObjectType, TH_Log_CaptureAndPersist.class.getName());
        Assert.isTrue(TriggerDispatcher.isSelectiveMode());
        // Generate sample logs;
        List<LogData> sampleLogs = generateLogData(logsAmount);
        Assert.isFalse(sampleLogs.isEmpty());
        Assert.areEqual(logsAmount, sampleLogs.size());
        // Publish PEs;
        List<Log__e> logEvents = castToEvents(sampleLogs);
        Assert.areEqual(logsAmount, logEvents.size());
        Test.startTest();
        EventBus.publish(logEvents);
        Test.stopTest();
        // Do assertions;
        List<LogEntry__c> logEntries = new List<LogEntry__c>(
            [SELECT Id, Name, Message__c FROM LogEntry__c ORDER BY CreatedDate ASC]
        );
        Assert.isFalse(logEntries.isEmpty());
        for (Integer i = 0; i < logEntries.size(); i++) {
            LogEntry__c logEntryItem = logEntries[i];
            LogEntry__c casted = sampleLogs[i].castToEntry();
            Assert.areEqual(logEntryItem.Message__c, casted.Message__c);
        }
    }

    private static List<LogData> generateLogData(Integer numOfLogs) {
        List<LogData> logs = new List<LogData>();
        for (Integer i = 0; i < numOfLogs; i++) {
            LogData logItem = new LogData();
            logItem.authorId = UserInfo.getUserId();
            logItem.authorProfileId = UserInfo.getProfileId();
            logItem.context = Request.getCurrent().getRequestId();
            logItem.level = System.LoggingLevel.DEBUG;
            logItem.quiddity = Request.getCurrent().getQuiddity();
            logItem.stackTrace = new LogData.StackTrace();
            logItem.message = 'Test Message #' + i;
            logItem.addData('prop1', 'value1').addData('prop2', 'value2');
            logs.add(logItem);
        }
        return logs;
    }

    private static List<Log__e> castToEvents(List<LogData> logItems) {
        List<Log__e> logEvents = new List<Log__e>();
        for (LogData logItem : logItems) {
            logEvents.add(logItem.castToEvent());
        }
        return logEvents;
    }
}
