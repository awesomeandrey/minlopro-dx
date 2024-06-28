public without sharing class Roles {
    private static final Map<Id, UserRole> userRolesMap {
        get {
            if (userRolesMap == null) {
                userRolesMap = new Map<Id, UserRole>([SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole]);
            }
            return userRolesMap;
        }
        set;
    }
    private static final Map<String, UserRole> userRolesByDeveloperNameMap {
        get {
            if (userRolesByDeveloperNameMap == null) {
                userRolesByDeveloperNameMap = new Map<String, UserRole>();
                for (UserRole role : userRolesMap.values()) {
                    userRolesByDeveloperNameMap.put(role.DeveloperName, role);
                }
            }
            return userRolesByDeveloperNameMap;
        }
        set;
    }
    // Memoization technique;
    private static final Map<Id, List<UserRole>> memoizedChildRoles = new Map<Id, List<UserRole>>();

    // Public API;

    public static UserRole getRoleByDeveloperName(String roleDevName) {
        return userRolesByDeveloperNameMap.get(roleDevName);
    }

    public static Map<String, UserRole> getRolesByDeveloperName(List<String> roleDevNames) {
        Map<String, UserRole> targetRoles = new Map<String, UserRole>();
        for (String roleDevName : roleDevNames) {
            if (userRolesByDeveloperNameMap.containsKey(roleDevName)) {
                targetRoles.put(roleDevName, userRolesByDeveloperNameMap.get(roleDevName));
            }
        }
        return targetRoles;
    }

    public static List<UserRole> getChildRoles(Id rootRoleId) {
        if (!userRolesMap.containsKey(rootRoleId)) {
            throw new IllegalArgumentException('Non-existing role ID passed.');
        }

        if (memoizedChildRoles.containsKey(rootRoleId)) {
            return memoizedChildRoles.get(rootRoleId);
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

        // Memoize method calculation result;
        memoizedChildRoles.put(rootRoleId, childRoles);

        return childRoles;
    }
}
