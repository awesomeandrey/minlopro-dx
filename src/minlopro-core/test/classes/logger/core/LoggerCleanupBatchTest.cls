@IsTest
private class LoggerCleanupBatchTest {
    final static Integer TEST_LOGS_AMOUNT = 250;

    @TestSetup
    static void createLogEntries() {
        List<LogEntry__c> logEntries = new List<LogEntry__c>();
        for (Integer i = 0; i < TEST_LOGS_AMOUNT; i++) {
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
        for (Integer i = 0; i < logEntries.size(); i++) {
            LogEntry__c logEntry = logEntries[i];
            if (Math.mod(i, 2) == 0) {
                // Even
                Test.setCreatedDate(logEntry.Id, Datetime.now().addDays(-10));
            } else {
                // Odd
                Test.setCreatedDate(logEntry.Id, Datetime.now().addDays(-5));
            }
        }
        List<LogEntry__c> allEntries = fetchAllLogEntries();
        Assert.areEqual(TEST_LOGS_AMOUNT, allEntries.size(), 'Test all log entries amount mismatched');
        List<LogEntry__c> entriesOlderThan10Days = fetchOlderThanOrEqualDate(Date.today().addDays(-7));
        Assert.areEqual(
            TEST_LOGS_AMOUNT / 2,
            entriesOlderThan10Days.size(),
            'Test older than or equal 10 days log entries amount mismatched'
        );
    }

    @IsTest
    static void testBatchJobToDeleteLogsByThreshold() {
        Integer customThreshold = 150;
        Assert.isTrue(customThreshold < TEST_LOGS_AMOUNT);
        Test.startTest();
        Database.executeBatch(new LoggerCleanupBatch(customThreshold));
        Test.stopTest();
        Assert.areEqual(customThreshold, fetchAllLogEntries().size(), 'Mismatch in remaining log entries');
        Assert.isTrue(fetchAllDeletedLogEntries().isEmpty(), 'Recycle bin should gave been cleaned up');
    }

    @IsTest
    static void testScheduledJobEnqueue() {
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
        Id firstSysCronId = (Id) System.schedule('TestJob1' + System.now(), '0 0 * * * ?', new LoggerCleanupBatch());
        Id secondSysCronId = (Id) System.schedule('TestJob2' + System.now(), '0 15 * * * ?', new LoggerCleanupBatch());
        Id thirdSysCronId = (Id) System.schedule('TestJob3' + System.now(), '0 30 * * * ?', new LoggerCleanupBatch());
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
        return [SELECT Id, CreatedDate FROM LogEntry__c];
    }

    static List<LogEntry__c> fetchAllDeletedLogEntries() {
        return [SELECT Id, CreatedDate FROM LogEntry__c WHERE IsDeleted = TRUE];
    }

    static List<LogEntry__c> fetchOlderThanOrEqualDate(Date olderThanDate) {
        return [SELECT Id, CreatedDate FROM LogEntry__c WHERE CreatedDate <= :olderThanDate];
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
