@IsTest
private class LscOppInsertTest {
    //    @TestSetup
    //    static void setupTestUser() {
    //        User drcRep = DRCTestDataFactory.createSalesRepUser('OppChangeEvt_TH_DRCEnterSfmcJourney@test.com', 'n1239456', 'TstAlias');
    //        PermissionSetAssignment permSetAssignment = DRCTestDataFactory.createDRCAdvisorPermSetAssignment(drcRep.Id);
    //        insert permSetAssignment;
    //    }
    //
    //    @IsTest
    //    static void testInsertNewDrcOpportunityAsRep() {
    //        System.runAs(findDrcRep()) {
    //            Test.enableChangeDataCapture();
    //            Test.startTest();
    //            Account testAccount = DRCTestDataFactory.createPersonAccount();
    //            insert testAccount;
    //            List<Opportunity> testOpportunities = DRCTestDataFactory.createOppsForAccount(testAccount, 20);
    //            insert testOpportunities; // This should trigger 'OpportunityChangeEvent' trigger;
    //            testOpportunities = findOpportunitiesById(testOpportunities);
    //            assertDrcFlagOnOpportunities(testOpportunities);
    //            assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by default;
    //            Test.stopTest();
    //
    //            List<AsyncApexJob> jobs = selectQueueableJobs();
    //            /**
    //             * Actually, the 'DRCOpportunitySfmcFlagSwitcher' queueable should enqueue itself 2nd time
    //             * to disable the 'IsDrcSfmcJourney__c' flag, but with CDC event triggers the 3rd level 'enqueue operation'
    //             * is not caught in tests. For that reason, a separate unit test is created to test queueable solely.
    //             */
    //            Assert.areEqual(1, jobs.size(), 'There should be 1 queueable jobs invoked');
    //            testOpportunities = findOpportunitiesById(testOpportunities);
    //            assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by default;
    //        }
    //    }
    //
    //    @IsTest
    //    static void testSfmcFlagSwitcherQueueable() {
    //        /**
    //         * Intentionally disable CDC trigger to test queueable solely.
    //         * `Test.enableChangeDataCapture();` line must be commented
    //         */
    //        // Test.enableChangeDataCapture();
    //        System.runAs(findDrcRep()) {
    //            Test.startTest();
    //            Account testAccount = DRCTestDataFactory.createPersonAccount();
    //            insert testAccount;
    //            List<Opportunity> testOpportunities = DRCTestDataFactory.createOppsForAccount(testAccount, 20);
    //            insert testOpportunities;
    //            testOpportunities = findOpportunitiesById(testOpportunities);
    //            assertDrcFlagOnOpportunities(testOpportunities);
    //            assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by default;
    //            List<Id> opportunityIds = new List<Id>(new Map<Id, Opportunity>(testOpportunities).keySet());
    //            System.enqueueJob(new DRCOpportunitySfmcFlagSwitcher(opportunityIds));
    //            Test.stopTest();
    //
    //            List<AsyncApexJob> jobs = selectQueueableJobs();
    //            Assert.areEqual(2, jobs.size(), '"DRCOpportunitySfmcFlagSwitcher" queueable should have enqueued itself resulting in 2 jobs in total');
    //            testOpportunities = findOpportunitiesById(testOpportunities);
    //            assertSfmcFlagOnOpportunities(testOpportunities, false); // The flag should be disabled by the 2nd job;
    //        }
    //    }
    //
    //    static User findDrcRep() {
    //        return [SELECT Id FROM User WHERE Username = 'OppChangeEvt_TH_DRCEnterSfmcJourney@test.com' LIMIT 1];
    //    }
    //
    //    static List<Opportunity> findOpportunitiesById(List<Opportunity> opportunities) {
    //        return [SELECT Id, Name, IsDRC__c, IsDrcSfmcJourney__c FROM Opportunity WHERE Id = :opportunities];
    //    }
    //
    //    static List<AsyncApexJob> selectQueueableJobs() {
    //        String queueableApexName = DRCOpportunitySfmcFlagSwitcher.class.getName();
    //        return [SELECT Id FROM AsyncApexJob WHERE JobType = 'Queueable' AND ApexClass.Name = :queueableApexName];
    //    }
    //
    //    static void assertDrcFlagOnOpportunities(List<Opportunity> opportunities) {
    //        for (Opportunity record : opportunities) {
    //            Assert.isTrue(record.IsDRC__c, 'The opportunity must be of DRC type');
    //        }
    //    }
    //
    //    static void assertSfmcFlagOnOpportunities(List<Opportunity> opportunities, Boolean valueToAssert) {
    //        for (Opportunity record : opportunities) {
    //            Assert.areEqual(valueToAssert, record.IsDrcSfmcJourney__c, 'Invalid value for IsDrcSfmcJourney__c flag');
    //        }
    //    }
}
