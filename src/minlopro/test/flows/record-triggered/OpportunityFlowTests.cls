@IsTest
private class OpportunityFlowTests {
    @IsTest
    static void testBeforeInsert() {
        System.runAs(TestDataFactory.createRegularUser()) {
            // Verify 'CloseDate' value gets predefined if not explicitly set;
            Account sampleAcc = TestDataFactory.createAccounts(10)[0];
            insert sampleAcc;
            Opportunity sampleOpp = TestDataFactory.createOpportunities(1, sampleAcc.Id)[0];
            sampleOpp.CloseDate = null;
            Assert.isNull(sampleOpp.CloseDate);
            insert sampleOpp;
            sampleOpp = selectOpportunityById(sampleOpp.Id);
            Assert.isNotNull(sampleOpp.CloseDate);
            Assert.areEqual(Date.today().addDays(5), sampleOpp.CloseDate, '[CloseDate] should have been set to 2 days ahead.');
        }
    }

    @IsTest
    static void testBeforeSave() {
        System.runAs(TestDataFactory.createRegularUser()) {
            // Verify there is a date-range limit applied to 'CloseDate';
            Account sampleAcc = TestDataFactory.createAccounts(10)[0];
            insert sampleAcc;
            Opportunity sampleOpp = TestDataFactory.createOpportunities(1, sampleAcc.Id)[0];
            insert sampleOpp;
            sampleOpp = selectOpportunityById(sampleOpp.Id);
            Assert.isNotNull(sampleOpp.CloseDate);
            sampleOpp.CloseDate = Date.today().addDays(100);
            Database.SaveResult oppSaveResult = Database.update(sampleOpp, false);
            Assert.isFalse(oppSaveResult.isSuccess(), 'RTF should have marked Opportunity record with error');
        }
    }

    static Opportunity selectOpportunityById(Id recordId) {
        return selectOpportunitiesByIds(Lists.of(recordId))[0];
    }

    static List<Opportunity> selectOpportunitiesByIds(List<Id> recordIds) {
        return [SELECT Id, Name, CloseDate, IsClosed, StageName FROM Opportunity WHERE Id IN :recordIds];
    }
}
