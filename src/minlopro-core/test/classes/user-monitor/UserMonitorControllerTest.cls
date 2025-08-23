@IsTest
private class UserMonitorControllerTest {
    @IsTest
    static void testGetPermissions() {
        User autoProc = Constants.Users.AutomatedProcessUser;
        System.runAs(autoProc) {
            List<UserMonitorController.Permission> permissions = UserMonitorController.getPermissions();
            Assert.isNotNull(permissions);
            Assert.isFalse(permissions.isEmpty());
            Assert.isTrue(containsPermissionByType(permissions, 'system'));
            Assert.isTrue(containsPermissionByType(permissions, 'custom'));
            Assert.isTrue(containsPermissionByType(permissions, 'user'));
        }
    }

    @IsTest
    static void testSearchObjectsByKeyword() {
        User autoProc = Constants.Users.AutomatedProcessUser;
        System.runAs(autoProc) {
            List<EntityDefinition> searchedObjects = UserMonitorController.searchObjectsByKeyword(null);
            Assert.isFalse(searchedObjects.isEmpty(), 'Empty search keyword should produce output');
            searchedObjects = UserMonitorController.searchObjectsByKeyword('account');
            Assert.areEqual(1, searchedObjects.size(), 'Strict search by object API name should match to 1 result exactly');
            searchedObjects = UserMonitorController.searchObjectsByKeyword('acc*');
            Assert.isTrue(searchedObjects.size() > 1, 'Glob searches should produce multi-result set');
        }
    }

    static Boolean containsPermissionByType(List<UserMonitorController.Permission> permissions, String type) {
        for (UserMonitorController.Permission perm : permissions) {
            if (perm.type.equalsIgnoreCase(type)) {
                return true;
            }
        }
        return false;
    }
}
