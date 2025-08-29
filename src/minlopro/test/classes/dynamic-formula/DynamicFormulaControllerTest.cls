@IsTest
private class DynamicFormulaControllerTest {
    @IsTest
    static void testSObjectFormulas() {
        DynamicFormulaController.Inputs formulaInputs = new DynamicFormulaController.Inputs();
        System.runAs(TestDataFactory.createAdmin()) {
            // Case #1 - Lead formula;
            Lead sampleLead = TestDataFactory.createLeads(1)[0];
            insert sampleLead;
            formulaInputs.record = sampleLead;
            formulaInputs.formulaReturnTypeName = FormulaEval.FormulaReturnType.INTEGER.name();
            formulaInputs.formulaExpression = 'DAYOFYEAR(DATEVALUE(CreatedDate))';
            Integer leadFormulaResult = Integer.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.areEqual(Date.today().dayOfYear(), leadFormulaResult, 'Lead formula was calculated incorrectly');

            // Case #2 - Account PROTOTYPE formula;
            Account sampleAcc = TestDataFactory.createAccounts(1)[0];
            formulaInputs.record = sampleAcc;
            formulaInputs.formulaReturnTypeName = FormulaEval.FormulaReturnType.STRING.name();
            formulaInputs.formulaExpression = 'LOWER(TEXT(Industry))';
            String accountFormulaResult = String.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.areEqual(sampleAcc.Industry.toLowerCase(), accountFormulaResult, 'Account formula was calculated incorrectly');

            // Case #3 - User formula;
            User sampleUser = TestDataFactory.createRegularUser();
            Profile minloproUserProfile = TestDataFactory.selectMinloproUserProfile();
            formulaInputs.record = sampleUser;
            formulaInputs.formulaReturnTypeName = FormulaEval.FormulaReturnType.BOOLEAN.name();
            formulaInputs.formulaExpression = 'ProfileId = \'' + minloproUserProfile.Id + '\'';
            Boolean userFormulaResult = Boolean.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.isTrue(userFormulaResult, 'User formula was calculated incorrectly');
        }
    }

    @IsTest
    static void testInvalidSObjectFormula() {
        System.runAs(TestDataFactory.createAdmin()) {
            Account sampleAcc = TestDataFactory.createAccounts(1)[0];
            insert sampleAcc;
            Opportunity sampleOpp = TestDataFactory.createOpportunities(1, sampleAcc.Id)[0];
            insert sampleOpp;
            DynamicFormulaController.Inputs formulaInputs = new DynamicFormulaController.Inputs();
            formulaInputs.record = sampleOpp;
            formulaInputs.formulaReturnTypeName = FormulaEval.FormulaReturnType.INTEGER.name();
            formulaInputs.formulaExpression = 'DOY(CloseeDatee)';
            try {
                // There is no fflib selector for Opportunities;
                DynamicFormulaController.evaluate(formulaInputs);
                Assert.fail('Exception should have been thrown');
            } catch (Exception ex) {
                Assert.isNotNull(ex, 'Exception should have been caught');
            }
        }
    }
}
