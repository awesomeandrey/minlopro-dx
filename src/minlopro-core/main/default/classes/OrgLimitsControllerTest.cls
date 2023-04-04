@IsTest
private class OrgLimitsControllerTest {
    @IsTest
    static void testGetAll() {
        List<Map<String, Object>> orgLimits = OrgLimitsController.getAll();
        Assert.isFalse(orgLimits.isEmpty());
    }
}
