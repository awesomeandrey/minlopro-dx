public without sharing class UnableToLockRowDemoController {
    @AuraEnabled
    public static void updateAccountSsn(Id recordId, Integer syntheticDelay) {
        try {
            String randomSSN = String.format(
                '{0}-{1}-{2}',
                Lists.of(
                    TestDataFactory.generateRandomDecimal(100, 999).toString(),
                    TestDataFactory.generateRandomDecimal(10, 99).toString(),
                    TestDataFactory.generateRandomDecimal(1000, 9999).toString()
                )
            );
            update new Account(Id = recordId, SSN__c = randomSSN);
            Runtime.sleep(Math.max(1, syntheticDelay));
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw auraEx;
        }
    }
}
