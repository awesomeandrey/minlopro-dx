@IsTest
private class LoggerCleanupBatchTest {
    final static Integer LOGS_AMOUNT = 50;

    @TestSetup
    static void createLogEntries() {
        List<LogEntry__c> logEntries = new List<LogEntry__c>();
        for (Integer i = 0; i < LOGS_AMOUNT; i++) {
            LogData logItem = new LogData();
            logItem.authorId = UserInfo.getUserId();
            logItem.authorProfileId = UserInfo.getProfileId();
            logItem.transactionId = Request.getCurrent().getRequestId();
            logItem.level = System.LoggingLevel.DEBUG;
            logItem.quiddity = Request.getCurrent().getQuiddity();
            logItem.stackTrace = new LogData.StackTrace('Class' + i, 'method' + i, i);
            logItem.message = 'Test Message #' + i;
            logItem.addData('prop1', 'value1').addData('prop2', 'value2');
            logEntries.add(logItem.castToEntry());
        }
        insert logEntries;
        for (LogEntry__c logEntry : logEntries) {
            // Alter 'CreatedDate' field value;
            Test.setCreatedDate(logEntry.Id, Date.today().addMonths(-5));
        }
        List<LogEntry__c> entries = fetchAllLogEntries();
        Assert.areEqual(LOGS_AMOUNT, entries.size(), 'Test log entries amount mismatched');
    }

    @IsTest
    static void testBatchJob() {
        List<LogEntry__c> entriesToDelete = fetchAllLogEntries();
        Assert.areEqual(LOGS_AMOUNT, entriesToDelete.size(), 'Test log entries amount mismatched');
        Test.startTest();
        Database.executeBatch(new LoggerCleanupBatch());
        Test.stopTest();
        entriesToDelete = fetchAllLogEntries();
        Assert.areEqual(0, entriesToDelete.size(), 'Test log entries should have been deleted');
        entriesToDelete = fetchAllDeletedLogEntries();
        Assert.areEqual(0, entriesToDelete.size(), 'Test log entries should have been purged from recycle bin');
    }

    @IsTest
    static void testScheduledJob() {
        // Invoke schedulable multiple times via different methods;
        Test.startTest();
        Id firstCronId = new LoggerCleanupBatch().run().CronTriggerId;
        Assert.isNotNull(firstCronId, 'First invocation should result in successful schedule');
        Id secondCronId = new LoggerCleanupBatch().run().CronTriggerId; // Should be skipped;
        Assert.areEqual(
            firstCronId,
            secondCronId,
            'Repetitive invocation should be skipped and resolve to previously enqueued job'
        );
        Date deleteBeforeDate = Date.today().addDays(-7);
        Id firstSysCronId = (Id) System.schedule(
            'TestJob1' + System.now(),
            '0 0 * * * ?',
            new LoggerCleanupBatch(deleteBeforeDate)
        );
        Id secondSysCronId = (Id) System.schedule(
            'TestJob2' + System.now(),
            '0 15 * * * ?',
            new LoggerCleanupBatch(deleteBeforeDate)
        );
        Id thirdSysCronId = (Id) System.schedule(
            'TestJob3' + System.now(),
            '0 30 * * * ?',
            new LoggerCleanupBatch(deleteBeforeDate)
        );
        Test.stopTest();

        // Collect CRON Ids;
        List<Id> cronTriggerIds = new List<Id>{ firstCronId, secondCronId, firstSysCronId, secondSysCronId, thirdSysCronId };
        Map<Id, AsyncApexJob> asyncJobByCronId = getAsyncApexJobIdByCronTriggerIds(cronTriggerIds);

        Assert.areEqual(4, asyncJobByCronId.size(), 'There should be 4 attempts to schedule a job in total');
        Assert.areEqual('Aborted', asyncJobByCronId.get(firstCronId).Status, 'Preceding job should be self-aborted');
        Assert.areEqual('Aborted', asyncJobByCronId.get(firstSysCronId).Status, 'Preceding job should be self-aborted');
        Assert.areEqual('Aborted', asyncJobByCronId.get(secondSysCronId).Status, 'Preceding job should be self-aborted');
        Assert.areEqual('Queued', asyncJobByCronId.get(thirdSysCronId).Status, 'Only the last enqueued job should be run');
    }

    static List<LogEntry__c> fetchAllLogEntries() {
        return [SELECT Id FROM LogEntry__c];
    }

    static List<LogEntry__c> fetchAllDeletedLogEntries() {
        return [SELECT Id FROM LogEntry__c WHERE IsDeleted = TRUE];
    }

    static Map<Id, AsyncApexJob> getAsyncApexJobIdByCronTriggerIds(List<Id> cronTriggerIds) {
        Map<Id, AsyncApexJob> resultMap = new Map<Id, AsyncApexJob>();
        for (AsyncApexJob jobInfo : [
            SELECT Id, CronTriggerId, Status
            FROM AsyncApexJob
            WHERE CronTriggerId IN :cronTriggerIds AND CronTriggerId != NULL
        ]) {
            resultMap.put(jobInfo.CronTriggerId, jobInfo);
        }
        return resultMap;
    }
}
