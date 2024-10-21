@IsTest
private class LscOppInsertTest {
    @IsTest
    static void testInsertNewDrcOpportunityAsRep() {
        Test.enableChangeDataCapture();
        Test.startTest();
        Account testAccount = TestDataFactory.createAccounts(1)[0];
        insert testAccount;

        List<Opportunity> testOpportunities = TestDataFactory.createOpportunities(10, testAccount.Id);
        insert testOpportunities; // This should trigger 'OpportunityChangeEvent' trigger;

        List<Opportunity> testOpportunities2 = TestDataFactory.createOpportunities(10, testAccount.Id);
        insert testOpportunities2; // This should trigger 'OpportunityChangeEvent' trigger;

        testOpportunities = findOpportunitiesById(testOpportunities);
        assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by default;
        Test.stopTest();

        List<AsyncApexJob> jobs = selectQueueableJobs();
        DebugTableFormatter formatter = new DebugTableFormatter(Lists.of('Status', 'CreatedBy.Alias', 'ApexClass.Name'), jobs);
        formatter.log('JOBS');
        /**
         * Actually, the 'DRCOpportunitySfmcFlagSwitcher' queueable should enqueue itself 2nd time
         * to disable the 'IsDrcSfmcJourney__c' flag, but with CDC event triggers the 3rd level 'enqueue operation'
         * is not caught in tests. For that reason, a separate unit test is created to test queueable solely.
         */
        Assert.areEqual(1, jobs.size(), 'There should be 1 queueable jobs invoked');
    }

    @IsTest
    static void testSfmcFlagSwitcherQueueable() {
        /**
         * Intentionally disable CDC trigger to test queueable solely.
         * `Test.enableChangeDataCapture();` line must be commented
         */
        // Test.enableChangeDataCapture();
        Test.startTest();
        Account testAccount = TestDataFactory.createAccounts(1)[0];
        insert testAccount;
        List<Opportunity> testOpportunities = TestDataFactory.createOpportunities(10, testAccount.Id);
        insert testOpportunities;
        testOpportunities = findOpportunitiesById(testOpportunities);
        assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by default;
        List<Id> opportunityIds = new List<Id>(new Map<Id, Opportunity>(testOpportunities).keySet());
        System.enqueueJob(new LscOpportunityQueueable(opportunityIds));
        Test.stopTest();

        List<AsyncApexJob> jobs = selectQueueableJobs();
        Assert.areEqual(
            2,
            jobs.size(),
            '"DRCOpportunitySfmcFlagSwitcher" queueable should have enqueued itself resulting in 2 jobs in total'
        );
        testOpportunities = findOpportunitiesById(testOpportunities);
        assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by the 2nd job;
    }

    static List<Opportunity> findOpportunitiesById(List<Opportunity> opportunities) {
        return [SELECT Id, Name, IsDrcSfmcJourney__c, LastModifiedBy.Name FROM Opportunity WHERE Id = :opportunities];
    }

    static List<AsyncApexJob> selectQueueableJobs() {
        String queueableApexName = LscOpportunityQueueable.class.getName();
        return [
            SELECT Id, Status, CreatedBy.Alias, ApexClass.Name, CreatedBy.Username
            FROM AsyncApexJob
            WHERE JobType = 'Queueable' AND ApexClass.Name = :queueableApexName
        ];
    }

    static void assertSfmcFlagOnOpportunities(List<Opportunity> opportunities, Boolean valueToAssert) {
        for (Opportunity record : opportunities) {
            Assert.areEqual(valueToAssert, record.IsDrcSfmcJourney__c, 'Invalid value for IsDrcSfmcJourney__c flag');
        }
    }
}
