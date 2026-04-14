@IsTest
private class LmTestPlayground {
    @IsTest
    static void testDataScope() {
        DebugTableFormatter formatter = new DebugTableFormatter(
            Lists.of('Name', 'Username', 'Email'),
            [SELECT Id, Name, Username, Email FROM User]
        );
        formatter.log('=== Users In Apex Test Context ===');
        Assert.isTrue(true);
    }

    @IsTest
    static void testCreatePermissionSetGroup() {
        User admin = TestDataFactory.createAdmin();
        User rep = TestDataFactory.createRegularUser();
        final String psgName = 'SamplePSG';
        System.runAs(admin) {
            PermissionSetGroup psg = new PermissionSetGroup(MasterLabel = psgName, DeveloperName = psgName);
            insert psg;
            Assert.isNotNull(psg.Id);
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = rep.Id, PermissionSetGroupId = psg.Id);
            insert psa;
            Assert.isNotNull(psa.Id);
        }
        List<PermissionSetAssignment> psaList = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetGroup.DeveloperName = :psgName
        ];
        Assert.isFalse(psaList.isEmpty());
    }

    @IsTest
    static void testCreatePublicGroup() {
        User admin = TestDataFactory.createAdmin();
        final String groupName = 'SampleGroup';
        System.runAs(admin) {
            Group gr = new Group(Name = groupName, DeveloperName = groupName);
            insert gr;
            Assert.isNotNull(gr.Id);
            User rep = TestDataFactory.createRegularUser();
            GroupMember gm = new GroupMember(GroupId = gr.Id, UserOrGroupId = rep.Id);
            insert gm;
            Assert.isNotNull(gm.Id);
        }
        // To overcome MIXED_DML_OPERATION exception, insert non-setup object records in separate 'runAs' clause
        System.runAs(admin) {
            insert TestDataFactory.createLeads(10);
            insert TestDataFactory.createAccounts(10);
        }
    }
}
