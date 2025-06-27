public without sharing class UserMonitorController {
    @AuraEnabled
    public static List<Permission> getPermissions() {
        try {
            List<Permission> permissions = new List<Permission>();
            permissions.addAll(collectSystemPermissions());
            permissions.addAll(collectCustomPermissions());
            permissions.addAll(collectUserPermissions());
            return permissions;
        } catch (Exception ex) {
            Logger.error(ex);
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<EntityDefinition> searchObjectsByKeyword(String keyword) {
        try {
            if (String.isBlank(keyword) || keyword.trim().length() < 2) {
                return [
                    SELECT Label, DeveloperName, QualifiedApiName, NamespacePrefix
                    FROM EntityDefinition
                    ORDER BY DeveloperName ASC
                    LIMIT 15
                ];
            }
            List<List<SObject>> results = Search.query(
                'FIND :keyword IN ALL FIELDS RETURNING EntityDefinition (Label, DeveloperName, QualifiedApiName, NamespacePrefix) LIMIT 15'
            );
            List<EntityDefinition> foundObjects = new List<EntityDefinition>();
            for (SObject record : results[0]) {
                foundObjects.add((EntityDefinition) record);
            }
            return foundObjects;
        } catch (Exception ex) {
            Logger.error(ex);
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    private static List<Permission> collectSystemPermissions() {
        List<Permission> systemPermissions = new List<Permission>();
        UserPermissionAccess upaRecord = [SELECT FIELDS(STANDARD) FROM UserPermissionAccess LIMIT 1];
        for (Schema.SObjectField field : UserPermissionAccess.SObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (
                fieldDescribe.getType().equals(Schema.DisplayType.BOOLEAN) &&
                fieldDescribe.getName().startsWithIgnoreCase('permission')
            ) {
                systemPermissions.add(
                    new Permission('system', fieldDescribe.getLabel(), fieldDescribe.getName(), (Boolean) upaRecord.get(field))
                );
            }
        }
        return systemPermissions;
    }

    private static List<Permission> collectCustomPermissions() {
        List<Permission> customPermissions = new List<Permission>();
        for (CustomPermission cp : [SELECT Id, MasterLabel, NamespacePrefix, DeveloperName, Description FROM CustomPermission]) {
            String apiName = String.isNotBlank(cp.NamespacePrefix)
                ? cp.NamespacePrefix + '.' + cp.DeveloperName
                : cp.DeveloperName;
            customPermissions.add(new Permission('custom', cp.MasterLabel, apiName, FeatureManagement.checkPermission(apiName)));
        }
        return customPermissions;
    }

    private static List<Permission> collectUserPermissions() {
        List<Permission> userPermissions = new List<Permission>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.User.fields.getMap();
        List<String> userPermissionFields = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            if (
                fieldsMap.get(fieldName).getDescribe().getType().equals(Schema.DisplayType.BOOLEAN) &&
                fieldName.startsWithIgnoreCase('UserPermission')
            ) {
                userPermissionFields.add(fieldName);
            }
        }
        Id runningUserId = UserInfo.getUserId();
        User runningUser = Database.query(
            String.format(
                'SELECT {0} FROM User WHERE Id = :runningUserId LIMIT 1',
                Lists.of(String.join(userPermissionFields, ', '))
            )
        );
        for (String fieldName : userPermissionFields) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            userPermissions.add(
                new Permission('user', fieldDescribe.getLabel(), fieldDescribe.getName(), (Boolean) runningUser.get(fieldName))
            );
        }
        return userPermissions;
    }

    public class Permission {
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean value;

        private Permission() {
        }

        public Permission(String type, String label, String name, Boolean value) {
            this();
            this.type = type;
            this.label = label;
            this.name = name;
            this.value = value;
        }
    }
}
