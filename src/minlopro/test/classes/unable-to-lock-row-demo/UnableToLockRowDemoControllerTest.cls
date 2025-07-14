@IsTest
private class UnableToLockRowDemoControllerTest {
    @IsTest
    static void testUpdateAccountSsn() {
        final Integer syntheticDelay = 5000;
        User regularUser = TestDataFactory.createRegularUser();
        System.runAs(regularUser) {
            Account sampleAccount = TestDataFactory.createAccount();
            insert sampleAccount;
            sampleAccount = selectAccount(sampleAccount.Id);
            Assert.isTrue(String.isBlank(sampleAccount.SSN__c));
            // Measure execution time;
            Long startTime = System.currentTimeMillis();
            UnableToLockRowDemoController.updateAccountSsn(sampleAccount.Id, syntheticDelay);
            Long endTime = System.currentTimeMillis();
            Long duration = endTime - startTime;
            Assert.isTrue(
                duration >= syntheticDelay,
                'Expected execution to take longer than predefined delay: ' + syntheticDelay.toString()
            );
            sampleAccount = selectAccount(sampleAccount.Id);
            Assert.isFalse(String.isBlank(sampleAccount.SSN__c));
        }
    }

    @IsTest
    static void testUpdateAccountSsnError() {
        User regularUser = TestDataFactory.createRegularUser();
        System.runAs(regularUser) {
            try {
                Id fakeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
                UnableToLockRowDemoController.updateAccountSsn(fakeAccountId, 10000);
                Assert.fail('Exception should have been caught!');
            } catch (Exception ex) {
                Assert.isInstanceOfType(ex.getCause(), DmlException.class);
            }
        }
    }

    static Account selectAccount(Id accountId) {
        return [SELECT Id, Name, SSN__c FROM Account WHERE Id = :accountId LIMIT 1];
    }
}
