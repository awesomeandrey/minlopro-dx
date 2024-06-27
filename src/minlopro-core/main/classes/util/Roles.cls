public without sharing class Roles {
    private static Map<Id, UserRole> userRolesMap {
        get {
            if (userRolesMap == null) {
                userRolesMap = new Map<Id, UserRole>([SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole]);
            }
            return userRolesMap;
        }
        set;
    }

    public static List<UserRole> getChildRoles(Id rootRoleId) {
        if (!userRolesMap.containsKey(rootRoleId)) {
            throw new IllegalArgumentException('Non-existing role ID passed.');
        }
        UserRole parentRole = userRolesMap.get(rootRoleId);
        List<UserRole> childRoles = new List<UserRole>();

        // Initialize a set to hold the role IDs to process;
        Set<Id> roleIdsToProcess = new Set<Id>{ parentRole.Id };

        // Process roles to find all children (recursively);
        while (!roleIdsToProcess.isEmpty()) {
            Set<Id> nextRoleIdsToProcess = new Set<Id>();
            for (UserRole role : userRolesMap.values()) {
                if (roleIdsToProcess.contains(role.ParentRoleId)) {
                    childRoles.add(role);
                    nextRoleIdsToProcess.add(role.Id);
                }
            }
            // Reset role IDs to process moving deeper within role hierarchy tree;
            roleIdsToProcess = nextRoleIdsToProcess;
        }
        return childRoles;
    }
}
