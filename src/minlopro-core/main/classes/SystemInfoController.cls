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
            Logger.error(ex);
            String exceptionDetails = Exceptions.getDetails(ex).toString();
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
            Logger.error(ex);
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled
    public static String getRunningUserInfoAsPdf() {
        try {
            Blob b = Page.digex_RunningUserInfoAsPdf.getContentAsPDF();
            return EncodingUtil.base64Encode(b);
        } catch (Exception ex) {
            Logger.error(ex);
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean isSandbox() {
        try {
            Organization org = [SELECT IsSandbox, OrganizationType, InstanceName FROM Organization LIMIT 1];
            return org.IsSandbox;
        } catch (Exception ex) {
            Logger.error(ex);
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            throw new AuraHandledException(exceptionDetails);
        }
    }
}
