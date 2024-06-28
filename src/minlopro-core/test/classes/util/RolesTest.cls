@IsTest
private class RolesTest {
    @IsTest
    static void testRolesUtilityMethods() {
        final String ceoRoleDevName = 'CEO';
        UserRole ceoRole = Roles.getRoleByDeveloperName(ceoRoleDevName);
        Assert.areEqual(ceoRoleDevName, ceoRole.DeveloperName);
        final String cfoRoleDevName = 'CFO';
        UserRole cfoRole = Roles.getRoleByDeveloperName(cfoRoleDevName);
        Assert.areEqual(cfoRoleDevName, cfoRole.DeveloperName);
        Map<String, UserRole> targetRoles = Roles.getRolesByDeveloperName(Lists.of(ceoRoleDevName, cfoRoleDevName));
        Assert.areEqual(2, targetRoles.size());

        // Verify memoization;
        Assert.isTrue(Roles.memoizedChildRoles.isEmpty());
        List<UserRole> childRoles1 = Roles.getChildRoles(ceoRole.Id);
        Assert.isTrue(childRoles1.size() > 3);
        List<UserRole> childRoles2 = Roles.getChildRoles(ceoRole.Id);
        Assert.areEqual(childRoles1, childRoles2);
        Assert.isFalse(Roles.memoizedChildRoles.isEmpty());
    }
}
