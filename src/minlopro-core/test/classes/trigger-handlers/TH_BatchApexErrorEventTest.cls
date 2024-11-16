@IsTest
private class TH_BatchApexErrorEventTest {
    @IsTest
    static void testErrorEventCapturing() {
        // Create log settings for Automated Process user;
        User autoProc = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        Assert.isNotNull(autoProc);
        insert new LoggerSettings__c(SetupOwnerId = autoProc.Id, LogsEmissionDate__c = Date.today());
        TriggerDispatcher.enableObjectHandler(BatchApexErrorEvent.SObjectType, TH_BatchApexErrorEvent.class.getName());
        try {
            Test.startTest();
            Database.executeBatch(new SampleFailingBatch(), 200);
            Test.stopTest(); // This line causes exception to occur;
            Assert.fail('The code should have failed earlier');
        } catch (Exception ex) {
            Assert.isNotNull(ex, 'Exception should have been caught');
        }
        Test.getEventBus().deliver(); // Deliver events;
        LogData log = new LogData(Logger.currentEvent());
        Assert.areEqual(
            TH_BatchApexErrorEvent.class.getName(),
            log.stackTrace.className,
            'The error event should originate from trigger handler class!'
        );
        Assert.areEqual(autoProc.Id, log.authorId, 'The error event should be emitted by Automated Process user!');
    }
}
