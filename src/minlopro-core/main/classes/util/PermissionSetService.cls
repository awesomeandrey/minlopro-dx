public inherited sharing class PermissionSetService {
    private static PermissionSetService instance;
    private Boolean allOrNothing = false;

    private Map<Id, PermissionSet> permissionSetByIdMap;
    private Map<String, PermissionSet> permissionSetByNameMap {
        get {
            if (this.permissionSetByNameMap == null) {
                Map<String, PermissionSet> resultMap = new Map<String, PermissionSet>();
                for (PermissionSet ps : this.permissionSetByIdMap.values()) {
                    resultMap.put(ps.Name, ps);
                }
                this.permissionSetByNameMap = resultMap;
            }
            return this.permissionSetByNameMap;
        }
        set;
    }

    public static PermissionSetService getInstance() {
        if (instance == null) {
            instance = new PermissionSetService();
        }
        return instance;
    }

    private PermissionSetService() {
        this.permissionSetByIdMap = new Map<Id, PermissionSet>();
        for (PermissionSet ps : [
            SELECT Id, Name, PermissionSetGroupId, IsCustom, Type, License.Name
            FROM PermissionSet
            LIMIT 300
        ]) {
            if (this.isGroup(ps)) {
                this.permissionSetByIdMap.put(ps.PermissionSetGroupId, ps);
            }
            this.permissionSetByIdMap.put(ps.Id, ps);
        }
    }

    public PermissionSetService enforceAllOrNothing(Boolean allOrNothing) {
        this.allOrNothing = allOrNothing;
        return this;
    }

    public List<Database.UpsertResult> assign(Id userId, Set<String> permissionSetOrGroupNames) {
        Set<Id> permissionSetOrGroupIds = this.collectPermissionSetOrGroupIds(permissionSetOrGroupNames);
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (Id psOrPsgId : permissionSetOrGroupIds) {
            PermissionSet ps = this.permissionSetByIdMap.get(psOrPsgId);
            if (this.isRegular(ps) || this.isStandard(ps)) {
                assignments.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId));
            } else if (this.isGroup(ps)) {
                assignments.add(new PermissionSetAssignment(PermissionSetGroupId = ps.PermissionSetGroupId, AssigneeId = userId));
            } else {
                throw new IllegalArgumentException(
                    String.format(
                        'Only permission sets with the following types are allowed: [{0}].',
                        Lists.of(Lists.of('Regular', 'Group', 'Standard').toString())
                    )
                );
            }
        }
        List<Database.UpsertResult> upsertResults = Database.upsert(assignments, this.allOrNothing);
        // Log DML results in tabular format;
        this.log(userId, assignments, upsertResults);
        return upsertResults;
    }

    public List<Database.DeleteResult> unassign(Id userId, Set<String> permissionSetOrGroupNames) {
        Set<Id> permissionSetOrGroupIds = this.collectPermissionSetOrGroupIds(permissionSetOrGroupNames);
        return Database.delete(
            [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE
                    AssigneeId = :userId
                    AND (PermissionSetId IN :permissionSetOrGroupIds
                    OR PermissionSetGroupId IN :permissionSetOrGroupIds)
            ]
        );
    }

    public Id assignAsync(Id userId, Set<String> permissionSetOrGroupNames) {
        // Used to overcome 'MIXED_DML_OPERATION' errors;
        return System.enqueueJob(new PermissionSetServiceWorker(instance, userId, permissionSetOrGroupNames));
    }

    private void log(Id userId, List<PermissionSetAssignment> assignments, List<Database.UpsertResult> upsertResults) {
        List<Map<String, String>> assignmentsData = new List<Map<String, String>>();
        for (Integer index = 0; index < upsertResults.size(); index++) {
            Database.UpsertResult dmlResult = upsertResults[index];
            PermissionSetAssignment assignment = assignments[index];
            PermissionSet ps = this.permissionSetByIdMap.get(this.extractIdFromAssignment(assignment));
            Map<String, String> resultInfo = new Map<String, String>{
                'PermissionSetId' => this.extractIdFromAssignment(assignment),
                'PermissionSetName' => ps.Name,
                'Type' => ps.Type,
                'Success' => this.getStatusAsText(dmlResult),
                'Error' => this.getErrorAsText(dmlResult)
            };
            assignmentsData.add(resultInfo);
        }
        User targetUser = [SELECT Username FROM User WHERE Id = :userId LIMIT 1];
        List<String> fieldNames = Lists.of(assignmentsData[0].keySet());
        DebugTableFormatter formatter = new DebugTableFormatter(fieldNames, assignmentsData);
        formatter.log(String.format('⚪ Assignment results for [{0}] user:\n', Lists.of(targetUser.Username)));
    }

    private Boolean isRegular(PermissionSet ps) {
        return ps.Type.equalsIgnoreCase('Regular');
    }

    private Boolean isGroup(PermissionSet ps) {
        return ps.Type.equalsIgnoreCase('Group');
    }

    private Boolean isStandard(PermissionSet ps) {
        return ps.Type.equalsIgnoreCase('Standard');
    }

    private Set<Id> collectPermissionSetOrGroupIds(Set<String> permissionSetOrGroupNames) {
        Set<Id> permissionSetOrGroupIds = new Set<Id>();
        if (Sets.isNotEmpty(permissionSetOrGroupNames)) {
            Map<String, PermissionSet> localMap = this.permissionSetByNameMap;
            for (String psOrPsgName : permissionSetOrGroupNames) {
                if (!localMap.containsKey(psOrPsgName)) {
                    throw new IllegalArgumentException(
                        String.format('Unknown permission set or group API name provided: [{0}].', Lists.of(psOrPsgName))
                    );
                }
                permissionSetOrGroupIds.add(localMap.get(psOrPsgName).Id);
            }
        }
        return permissionSetOrGroupIds;
    }

    private Id extractIdFromAssignment(PermissionSetAssignment assignment) {
        if (String.isNotBlank(assignment.PermissionSetGroupId)) {
            return assignment.PermissionSetGroupId;
        }
        return assignment.PermissionSetId;
    }

    private String getStatusAsText(Database.UpsertResult dmlResult) {
        if (!dmlResult.isSuccess() && dmlResult.getErrors()[0].getStatusCode().equals(StatusCode.DUPLICATE_VALUE)) {
            return '🔶 duplicate (true)';
        }
        return dmlResult.isSuccess() ? '✅ true' : '❌ false';
    }

    private String getErrorAsText(Database.UpsertResult dmlResult) {
        if (!dmlResult.isSuccess()) {
            Database.Error error = dmlResult.getErrors()[0];
            return String.format('{0} = {1}', Lists.of(error.getStatusCode().name(), error.getMessage()));
        }
        return '';
    }

    private class PermissionSetServiceWorker implements Queueable {
        private final PermissionSetService instance;
        private final Id userId;
        private final Set<String> permissionSetOrGroupNames;

        private PermissionSetServiceWorker(PermissionSetService instance, Id userId, Set<String> permissionSetOrGroupNames) {
            this.instance = instance;
            this.userId = userId;
            this.permissionSetOrGroupNames = permissionSetOrGroupNames;
        }

        public void execute(QueueableContext context) {
            try {
                this.instance.assign(this.userId, this.permissionSetOrGroupNames);
            } catch (Exception ex) {
                Logger.error(ex);
            }
        }
    }
}
