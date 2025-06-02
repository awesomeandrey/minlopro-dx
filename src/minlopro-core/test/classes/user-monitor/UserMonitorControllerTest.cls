@IsTest
private class UserMonitorControllerTest {
    @IsTest
    static void testGetPermissions() {
        User autoProc = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        System.runAs(autoProc) {
            List<UserMonitorController.Permission> permissions = UserMonitorController.getPermissions();
            Assert.isNotNull(permissions);
            Assert.isFalse(permissions.isEmpty());
            Assert.isTrue(containsPermissionByType(permissions, 'system'));
            Assert.isTrue(containsPermissionByType(permissions, 'custom'));
            Assert.isTrue(containsPermissionByType(permissions, 'user'));
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
