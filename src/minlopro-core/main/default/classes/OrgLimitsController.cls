public without sharing class OrgLimitsController {
    @AuraEnabled
    public static List<Map<String, Object>> getAll() {
        try {
            List<Map<String, Object>> orgLimitsMap = new List<Map<String, Object>>();
            for (System.OrgLimit limitItem : System.OrgLimits.getAll()) {
                Map<String, Object> limitDescribeMap = new Map<String, Object>();
                limitDescribeMap.put('name', limitItem.getName());
                limitDescribeMap.put('limit', limitItem.getLimit());
                limitDescribeMap.put('value', limitItem.getValue());
                orgLimitsMap.add(limitDescribeMap);
            }
            Logger.debug('Retrieved Org Limits -> {0} items', Lists.of(String.valueOf(orgLimitsMap.size())));
            return orgLimitsMap;
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }
}
