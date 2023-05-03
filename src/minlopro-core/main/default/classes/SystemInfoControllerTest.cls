@IsTest
private class SystemInfoControllerTest {
    @IsTest
    static void testGetOrgLimits() {
        List<Map<String, Object>> orgLimits = SystemInfoController.getOrgLimits();
        Assert.isTrue(orgLimits.isEmpty()); // Cannot retrieve org limits in Apex Test context;
    }

    @IsTest
    static void testGetUserInfoById() {
        User runningUser = SystemInfoController.getUserInfoById(UserInfo.getUserId());
        Assert.areEqual(UserInfo.getUserId(), runningUser.Id);
    }
}
