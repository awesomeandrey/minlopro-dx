public without sharing class SystemInfoController {
    @AuraEnabled
    public static List<Map<String, Object>> getOrgLimits() {
        Logger.debug('Requesting Org Limits');
        try {
            List<Map<String, Object>> orgLimitsMap = new List<Map<String, Object>>();
            if (Test.isRunningTest()) {
                return orgLimitsMap;
            }
            for (System.OrgLimit limitItem : System.OrgLimits.getAll()) {
                Map<String, Object> limitDescribeMap = new Map<String, Object>();
                limitDescribeMap.put('name', limitItem.getName());
                limitDescribeMap.put('limit', limitItem.getLimit());
                limitDescribeMap.put('value', limitItem.getValue());
                orgLimitsMap.add(limitDescribeMap);
            }
            return orgLimitsMap;
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled(Cacheable=true)
    public static User getUserInfoById(Id userId) {
        Logger.debug('Requesting User Info');
        if (String.isBlank(userId)) {
            userId = UserInfo.getUserId();
        }
        try {
            return [
                SELECT Id, Name, Email, Username, UserType, IsPortalEnabled, ProfileId, Profile.Name, Profile.UserLicense.Name
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ][0];
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled
    public static String getRunningUserInfoAsPdf() {
        Blob b = Page.digex_RunningUserInfoAsPdf.getContentAsPDF();
        return EncodingUtil.base64Encode(b);
    }
}
