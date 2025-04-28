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
            formulaInputs.formulaReturnType = FormulaEval.FormulaReturnType.INTEGER;
            formulaInputs.formulaExpression = 'DAYOFYEAR(DATEVALUE(CreatedDate))';
            Integer leadFormulaResult = Integer.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.areEqual(Date.today().dayOfYear(), leadFormulaResult, 'Lead formula was calculated incorrectly');

            // Case #2 - Account PROTOTYPE formula;
            Account sampleAcc = TestDataFactory.createAccounts(1)[0];
            formulaInputs.record = sampleAcc;
            formulaInputs.formulaReturnType = FormulaEval.FormulaReturnType.STRING;
            formulaInputs.formulaExpression = 'LOWER(TEXT(Industry))';
            String accountFormulaResult = String.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.areEqual(sampleAcc.Industry.toLowerCase(), accountFormulaResult, 'Account formula was calculated incorrectly');

            // Case #3 - User formula;
            User sampleUser = TestDataFactory.createRegularUser();
            Profile minloproUserProfile = TestDataFactory.selectMinloproUserProfile();
            Assert.areEqual(minloproUserProfile.Id, sampleUser.ProfileId);
            formulaInputs.record = sampleUser;
            formulaInputs.formulaReturnType = FormulaEval.FormulaReturnType.BOOLEAN;
            formulaInputs.formulaExpression = 'ProfileId = \'' + minloproUserProfile.Id + '\'';
            Boolean userFormulaResult = Boolean.valueOf(DynamicFormulaController.evaluate(formulaInputs));
            Assert.isTrue(userFormulaResult, 'User formula was calculated incorrectly');
        }
    }

    @IsTest
    static void testUnsupportedSObjectSelector() {
        System.runAs(TestDataFactory.createAdmin()) {
            Account sampleAcc = TestDataFactory.createAccounts(1)[0];
            insert sampleAcc;
            Opportunity sampleOpp = TestDataFactory.createOpportunities(1, sampleAcc.Id)[0];
            insert sampleOpp;
            DynamicFormulaController.Inputs formulaInputs = new DynamicFormulaController.Inputs();
            formulaInputs.record = sampleOpp;
            formulaInputs.formulaReturnType = FormulaEval.FormulaReturnType.INTEGER;
            formulaInputs.formulaExpression = 'DAYOFYEAR(CloseDate)';
            Boolean exceptionCaught = false;
            try {
                // There is no fflib selector for Opportunities;
                DynamicFormulaController.evaluate(formulaInputs);
            } catch (Exception ex) {
                exceptionCaught = true;
            }
            Assert.isTrue(exceptionCaught, 'Exception should have been caught');
        }
    }
}
