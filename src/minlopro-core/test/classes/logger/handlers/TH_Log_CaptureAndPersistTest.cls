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
        List<LogData> sampleLogDataItems = generateLogData(logsAmount);
        Assert.isFalse(sampleLogDataItems.isEmpty());
        Assert.areEqual(logsAmount, sampleLogDataItems.size());
        // Publish PEs;
        List<Log__e> sampleLogEvents = castToEvents(sampleLogDataItems);
        Assert.areEqual(logsAmount, sampleLogEvents.size());
        Test.startTest();
        EventBus.publish(sampleLogEvents);
        Test.stopTest();
        // Do assertions;
        List<LogEntry__c> insertedLogEntries = new List<LogEntry__c>(
            [
                SELECT
                    Id,
                    Name,
                    Message__c,
                    Quiddity__c,
                    ApexClassMethod__c,
                    Author__c,
                    TransactionId__c,
                    Level__c,
                    ApexClass__c,
                    ApexClassLine__c
                FROM LogEntry__c
                ORDER BY CreatedDate ASC
            ]
        );
        Assert.isFalse(insertedLogEntries.isEmpty());
        for (Integer i = 0; i < insertedLogEntries.size(); i++) {
            LogData originalLogDataItem = sampleLogDataItems[i];
            Log__e logEventItem = sampleLogEvents[i];
            LogEntry__c logEntryItem = insertedLogEntries[i];
            LogData castedLogDataItem = new LogData(logEntryItem);
            // Verify field-driven properties;
            Assert.areEqual(originalLogDataItem.transactionId, logEventItem.TransactionId__c);
            Assert.areEqual(logEventItem.TransactionId__c, logEntryItem.TransactionId__c);
            // Verify data-managed properties;
            Assert.areEqual(originalLogDataItem.message, castedLogDataItem.message);
            Assert.areEqual(originalLogDataItem.stackTrace.methodName, castedLogDataItem.stackTrace.methodName);
            Assert.areEqual(originalLogDataItem.quiddity, castedLogDataItem.quiddity);
        }
    }

    private static List<LogData> generateLogData(Integer numOfLogs) {
        List<LogData> logs = new List<LogData>();
        for (Integer i = 0; i < numOfLogs; i++) {
            LogData logItem = new LogData();
            logItem.authorId = UserInfo.getUserId();
            logItem.authorProfileId = UserInfo.getProfileId();
            logItem.transactionId = Request.getCurrent().getRequestId();
            logItem.level = System.LoggingLevel.DEBUG;
            logItem.quiddity = Request.getCurrent().getQuiddity();
            logItem.stackTrace = new LogData.StackTrace('Class' + i, 'method' + i, i);
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
