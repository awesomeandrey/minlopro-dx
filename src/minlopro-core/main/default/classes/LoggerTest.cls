@IsTest
private class LoggerTest {
    @IsTest
    private static void debug() {
        // Setup
        enableLogEvents(System.today());
        // Execute
        Logger.debug('{0}=={1}:{2}', new List<Object>{ 1, '2', false });
        // Verify
        Log__e log = Logger.currentEvent();
        System.assertEquals(UserInfo.getUserId(), log.AuthorId__c);
        System.assertEquals(LoggingLevel.DEBUG.name(), log.Level__c);
        System.assertEquals(Request.getCurrent().getRequestId(), log.Context__c);
        Map<String, Object> data = data(log);
        System.assertEquals(Request.getCurrent().getQuiddity().name(), (String) data.get('Quiddity'));
        System.assertEquals('1==2:false', (String) data.get('Message'));
        System.assertEquals(thisClassName(), (String) data.get('Class'));
        System.assertEquals('debug', (String) data.get('Method'));
        System.assertEquals(1, (Integer) data.get('DMLRows')); // 1x Settings__c
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
        System.assertNotEquals(null, Logger.currentEvent().Context__c);
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

    private static Map<String, Object> data(Log__e log) {
        return (Map<String, Object>) JSON.deserializeUntyped(log.Data__c);
    }
}
