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
            Assert.areEqual(Date.today().addDays(2), sampleOpp.CloseDate, '[CloseDate] should have been set to 2 days ahead.');
        }
    }

    static Opportunity selectOpportunityById(Id recordId) {
        return selectOpportunitiesByIds(Lists.of(recordId))[0];
    }

    static List<Opportunity> selectOpportunitiesByIds(List<Id> recordIds) {
        return [SELECT Id, Name, CloseDate, IsClosed, StageName FROM Opportunity WHERE Id IN :recordIds];
    }
}
