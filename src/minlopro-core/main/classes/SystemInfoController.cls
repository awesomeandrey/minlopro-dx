public without sharing class SystemInfoController {
    @AuraEnabled
    public static List<Map<String, Object>> getOrgLimits() {
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
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static User getUserInfoById(Id userId) {
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
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    @AuraEnabled
    public static String getRunningUserInfoAsPdf() {
        try {
            Blob b = Page.digex_RunningUserInfoAsPdf.getContentAsPDF();
            return EncodingUtil.base64Encode(b);
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean isSandbox() {
        try {
            Organization org = [SELECT IsSandbox, OrganizationType, InstanceName FROM Organization LIMIT 1];
            return org.IsSandbox;
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    @AuraEnabled
    public static Map<String, Object> getAuthConfiguration() {
        try {
            Id networkId = Network.getNetworkId();
            Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
            return new Map<String, Object>{
                'usernamePasswordEnabled' => authConfig.getUsernamePasswordEnabled(),
                'selfRegistrationEnabled' => authConfig.getSelfRegistrationEnabled(),
                'selfRegistrationUrl' => authConfig.getSelfRegistrationUrl(),
                'forgotPasswordUrl' => authConfig.getForgotPasswordUrl()
            };
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<User> getAdmins() {
        Id adminsGroupId = getAdminsGroup()?.Id;
        return [
            SELECT Id, Name, Email, Username, Alias
            FROM User
            WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :adminsGroupId)
        ];
    }

    public static Set<Id> getAdminIds() {
        return new Map<Id, User>(getAdmins()).keySet();
    }

    public static Group getAdminsGroup() {
        return [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'OrgAdmins' LIMIT 1];
    }
}
