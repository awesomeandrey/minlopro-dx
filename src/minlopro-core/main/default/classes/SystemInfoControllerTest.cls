@IsTest
private class SystemInfoControllerTest {
    @IsTest
    static void testGetOrgLimits() {
        List<Map<String, Object>> orgLimits = SystemInfoController.getOrgLimits();
        Assert.isTrue(orgLimits.isEmpty()); // Cannot retrieve org limits in Apex Test context;
    }

    @IsTest
    static void testGetRunningUserInfo() {
        User runningUser = SystemInfoController.getRunningUserInfo();
        Assert.areEqual(UserInfo.getUserId(), runningUser.Id);
    }
}
