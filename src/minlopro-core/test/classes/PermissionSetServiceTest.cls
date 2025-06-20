@IsTest
private class PermissionSetServiceTest {
    final static Id USER_ID = UserInfo.getUserId();
    final static Set<String> PERMISSION_SET_NAMES = new Set<String>{
        'Minlopro_Core', // custom permission set
        'Minlopro_Logger', // custom permission set
        'Minlopro_PSG_InternalUser', // custom permission set group
        'SalesConsoleUser' // standard permission set
    };

    @IsTest
    static void testAssign() {
        PermissionSetService service = PermissionSetService.getInstance().enforceAllOrNothing(true);
        Test.startTest();
        List<Database.UpsertResult> upsertResults = service.assign(USER_ID, PERMISSION_SET_NAMES);
        Test.stopTest();
        Assert.isFalse(upsertResults.isEmpty(), 'Service should have inserted PermissionSetAssignment records');
        Assert.areEqual(PERMISSION_SET_NAMES.size(), upsertResults.size());
        for (Database.UpsertResult dmlResult : upsertResults) {
            Assert.isTrue(dmlResult.isSuccess());
            Assert.isTrue(dmlResult.isCreated());
        }
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, true);
    }

    @IsTest
    static void testAssignAsync() {
        PermissionSetService service = PermissionSetService.getInstance();
        Test.startTest();
        Id jobId = service.assignAsync(USER_ID, PERMISSION_SET_NAMES);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id FROM AsyncApexJob WHERE Id = :jobId];
        Assert.isNotNull(job, 'Async job should have been enqueued to process PSAs');
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, true);
    }

    @IsTest
    static void testAssignInvalid() {
        try {
            PermissionSetService.getInstance().assign(USER_ID, Sets.of('Minlopro_INVALID_PS_NAME'));
            Assert.fail('Invalid permission set name should have caused runtime exception');
        } catch (Exception ex) {
            Logger.error(ex);
            Assert.isInstanceOfType(ex, IllegalArgumentException.class);
        }
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, false);
    }

    @IsTest
    static void testAssignUnsupported() {
        try {
            PermissionSet unsupportedPermissionSet = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = 'sfdc_scrt2' AND Type = 'Session'
                LIMIT 1
            ];
            Assert.isNotNull(unsupportedPermissionSet);
            PermissionSetService.getInstance().assign(USER_ID, Sets.of(unsupportedPermissionSet.Name));
            Assert.fail('Unsupported permission set name should have caused runtime exception');
        } catch (Exception ex) {
            Logger.error(ex);
            Assert.isInstanceOfType(ex, IllegalArgumentException.class);
        }
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, false);
    }

    @IsTest
    static void testUnassign() {
        Test.startTest();
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, false);
        PermissionSetService service = PermissionSetService.getInstance();
        service.assign(USER_ID, PERMISSION_SET_NAMES);
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, true);
        service.unassign(USER_ID, PERMISSION_SET_NAMES);
        assertPermissionSetAssignments(USER_ID, PERMISSION_SET_NAMES, false);
        Test.stopTest();
    }

    static void assertPermissionSetAssignments(Id userId, Set<String> permissionSetNames, Boolean areAssigned) {
        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId AND PermissionSet.Name IN :permissionSetNames
        ];
        if (areAssigned) {
            Assert.isFalse(assignments.isEmpty(), 'PSAs should have been assigned');
            Assert.areEqual(permissionSetNames.size(), assignments.size(), 'PSA assignment mismatch detected');
        } else {
            Assert.isTrue(assignments.isEmpty(), 'No PSAs should have been assigned');
        }
    }
}
