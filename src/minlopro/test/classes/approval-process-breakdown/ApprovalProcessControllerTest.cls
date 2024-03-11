@IsTest
private class ApprovalProcessControllerTest {
    @IsTest
    static void testGetProcessInstancesByRecordId() {
        Id fakeOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<ProcessInstance> foundProcessInstances = ApprovalProcessController.getProcessInstancesByRecordId(fakeOppId);
        Assert.isTrue(foundProcessInstances.isEmpty());
    }

    @IsTest
    static void testToggleLock() {
        Opportunity testOpp = getTestOpportunity();
        Assert.isFalse(ApprovalProcessController.isLocked(testOpp.Id), 'Newly created Opportunity should not be locked.');
        ApprovalProcessController.lock(testOpp.Id);
        Assert.isTrue(ApprovalProcessController.isLocked(testOpp.Id), 'Opportunity should have been locked.');
        ApprovalProcessController.unlock(testOpp.Id);
        Assert.isFalse(ApprovalProcessController.isLocked(testOpp.Id), 'Opportunity should have been unlocked.');
    }

    @IsTest
    static void testSubmitOpportunityForApprovalAndGenerateGraph() {
        // Create & submit Opportunity for approval;
        Opportunity testOpp = getTestOpportunity();
        String serializedResult = ApprovalProcessController.submitOpportunityForApproval(testOpp.Id, UserInfo.getUserId(), true);
        Assert.isFalse(String.isBlank(serializedResult));
        // Verify that corresponding Process Instance record was created;
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :testOpp.Id];
        Assert.isFalse(processInstances.isEmpty(), 'Process Instance record should have been created.');
        ApprovalProcessController.Node rootNode = ApprovalProcessController.generateHierarchyGraph(processInstances[0].Id);
        Assert.areEqual(ProcessInstance.SObjectType, rootNode.sObjectType);
        Assert.isNotNull(rootNode.recordId);
        Assert.isNotNull(rootNode.objectName);
        Assert.isNotNull(rootNode.displayName);
        Iterator<ApprovalProcessController.Node> it = rootNode.children.iterator();
        while (it.hasNext()) {
            Assert.isNotNull(it.next().displayName);
        }
    }

    static Opportunity getTestOpportunity() {
        Account testAccount = TestDataFactory.createAccounts(1).get(0);
        insert testAccount;
        Opportunity testOpp = TestDataFactory.createOpportunities(1, testAccount.Id).get(0);
        insert testOpp;
        return testOpp;
    }
}
