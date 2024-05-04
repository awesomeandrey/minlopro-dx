@IsTest
private class LoggerTest {
    @IsTest
    private static void debug() {
        // Setup
        enableLogEvents(System.today());
        // Execute
        Logger.debug('{0}=={1}:{2}', new List<Object>{ 1, '2', false });
        // Verify
        Log__e logEvent = Logger.currentEvent();
        LogData logData = new LogData(logEvent);
        System.assertEquals(UserInfo.getUserId(), logData.authorId);
        System.assertEquals(LoggingLevel.DEBUG, logData.level);
        System.assertEquals(Request.getCurrent().getRequestId(), logData.transactionId);
        System.assertEquals(Request.getCurrent().getQuiddity(), logData.quiddity);
        System.assertEquals('1==2:false', logData.message);
        System.assertEquals(thisClassName(), logData.stackTrace.className);
        System.assertEquals('debug', logData.stackTrace.methodName);
        System.assert(String.isNotBlank((String) logData.getData('QueryRows')));
    }

    @IsTest
    private static void error() {
        // Setup
        enableLogEvents(System.today());
        // Execute
        Logger.error('');
        // Verify
        System.assertEquals(LoggingLevel.ERROR.name(), Logger.currentEvent().Level__c);
    }

    @IsTest
    private static void timestampWhenNoContextId() {
        // Setup
        enableLogEvents(System.today());
        // Execute
        Logger.debug('');
        // Verify
        System.assertNotEquals(null, Logger.currentEvent().TransactionId__c);
    }

    @IsTest
    private static void noEventsSendWhenDisabled() {
        // Execute
        Logger.debug('');
        // Verify
        System.assertEquals(null, Logger.currentEvent());
    }

    @IsTest
    private static void noEventsWhenExpired() {
        // Setup
        enableLogEvents(yesterday());
        // Execute
        Logger.debug('');
        // Verify
        System.assertEquals(null, Logger.currentEvent());
    }

    private static void enableLogEvents(Date day) {
        insert new LoggerSettings__c(SetupOwnerId = UserInfo.getUserId(), LogsEmissionDate__c = day);
    }

    private static Date yesterday() {
        return System.today().addDays(-1);
    }

    private static String thisClassName() {
        String ns = [SELECT NamespacePrefix FROM Organization].NamespacePrefix + '.';
        return LoggerTest.class.getName().removeStart(ns);
    }
}
