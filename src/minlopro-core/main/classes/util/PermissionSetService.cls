public inherited sharing class PermissionSetService {
    private static PermissionSetService instance;

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
            LIMIT 100
        ]) {
            if (this.isGroup(ps)) {
                this.permissionSetByIdMap.put(ps.PermissionSetGroupId, ps);
            }
            this.permissionSetByIdMap.put(ps.Id, ps);
        }
    }

    public List<Database.UpsertResult> assign(Id userId, Set<String> permissionSetOrGroupNames) {
        Set<Id> permissionSetOrGroupIds = new Set<Id>();
        if (Sets.isNotEmpty(permissionSetOrGroupNames)) {
            Map<String, PermissionSet> localMap = this.permissionSetByNameMap;
            for (String psOrPsgName : permissionSetOrGroupNames) {
                permissionSetOrGroupIds.add(localMap.get(psOrPsgName).Id);
            }
        }
        return this.assign(userId, permissionSetOrGroupIds);
    }

    public List<Database.UpsertResult> assign(Id userId, Set<Id> permissionSetOrGroupIds) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (Id psOrPsgId : permissionSetOrGroupIds) {
            PermissionSet ps = this.permissionSetByIdMap.get(psOrPsgId);
            if (this.isRegular(ps)) {
                assignments.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId));
            } else if (this.isGroup(ps)) {
                assignments.add(new PermissionSetAssignment(PermissionSetGroupId = ps.PermissionSetGroupId, AssigneeId = userId));
            } else {
                throw new IllegalArgumentException('Only permission sets with "Regular" or "Group" types can be assigned!');
            }
        }
        List<Database.UpsertResult> upsertResults = Database.upsert(assignments, false);
        // Log DML results in tabular format;
        this.log(userId, assignments, upsertResults);
        return upsertResults;
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
        List<String> fieldNames = Lists.of(assignmentsData[0].keySet());
        DebugTableFormatter formatter = new DebugTableFormatter(fieldNames, assignmentsData);
        formatter.log(String.format('⚪ Assignment results for [{0}] user:\n', Lists.of(userId)));
    }

    private Boolean isRegular(PermissionSet ps) {
        return ps.Type.equalsIgnoreCase('Regular');
    }

    private Boolean isGroup(PermissionSet ps) {
        return ps.Type.equalsIgnoreCase('Group');
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
}
