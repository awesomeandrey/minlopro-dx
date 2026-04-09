/**
 * Batch job that merges duplicate records for a given DuplicateRule.
 *
 * IMPORTANT: This batch MUST be invoked with a scope of exactly 1 record.
 *
 * Sample: Database.executeBatch(new MergeDuplicatesBatch(ruleId, fieldSetApiName, soqlClause), 1);
 */
public without sharing class MergeDuplicatesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {
    private DuplicateRule rule;
    private String mergeFieldsSetName;
    private String soqlClause;

    private Integer totalDrsProcessed = 0;
    private Integer totalDrsSkipped = 0;
    private Integer totalMergesSucceeded = 0;
    private Integer totalMergesFailed = 0;

    public MergeDuplicatesBatch(Id duplicateRuleId, String mergeFieldsSetApiName, String soqlClause) {
        this.rule = this.selectAndValidateDuplicateRule(duplicateRuleId);
        this.mergeFieldsSetName = this.selectAndValidateFieldSetName(mergeFieldsSetApiName).getName();
        this.soqlClause = soqlClause;
        Logger.debug(
            'MergeDuplicatesBatch initialised. Rule: {0}, SObjectType: {1}, FieldSet Name: {2}',
            Lists.of(this.rule.DeveloperName, this.rule.SobjectType, this.mergeFieldsSetName)
        );
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM DuplicateRecordSet WHERE DuplicateRuleId = \'' + this.rule.Id + '\' AND RecordCount > 1 ';
        if (String.isNotBlank(this.soqlClause)) {
            query += this.soqlClause;
        }
        Logger.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> records) {
        // Enforce limit of 1 record because 'merge' DML will consume transaction limits
        final Integer BATCH_SCOPE_LIMIT = 1;
        if (records.size() > BATCH_SCOPE_LIMIT) {
            IllegalArgumentException ex = new IllegalArgumentException(
                String.format(
                    'Batch scope of {0} exceeds the hard limit of {1} imposed by "merge" DML load. Chunk skipped.',
                    new List<Object>{ records.size(), BATCH_SCOPE_LIMIT }
                )
            );
            Logger.error(ex);
            throw ex;
        }

        this.totalDrsProcessed += records.size();

        // Prepare runtime
        final DuplicateRecordSet drs = (DuplicateRecordSet) records[0];
        final Schema.SObjectType objectType = Schema.getGlobalDescribe().get(this.rule.SobjectType);
        final Schema.FieldSet mergeFieldSetDef = this.selectAndValidateFieldSetName(this.mergeFieldsSetName);
        final List<SObjectField> fieldDefs = this.collectMergeFieldDefs(mergeFieldSetDef);
        final List<String> fieldApiNames = this.collectFieldApiNames(fieldDefs);
        final String fieldApiNamesAsSoqlClause = String.join(fieldApiNames, ', ');
        // Logger.debug('objectType = {0} | fieldApiNames = {1}', Lists.of(objectType.toString(), fieldApiNames.size().toString()));

        // Collect DRI records making sure the entities are not deleted
        String query = 'SELECT ' + fieldApiNamesAsSoqlClause + ' FROM ' + objectType.getDescribe().getName();
        query += ' WHERE Id IN (SELECT RecordId FROM DuplicateRecordItem WHERE DuplicateRecordSetId = \'' + drs.Id + '\')';
        query += ' AND IsDeleted = FALSE';
        query += ' ORDER BY LastModifiedDate DESC';
        // Logger.debug('query = {0}', Lists.of(query));
        List<SObject> recordsToMerge = Security.stripInaccessible(AccessType.UPDATABLE, Database.query(query)).getRecords();
        Logger.debug('recordsToMerge = {0}', Lists.of(recordsToMerge.size().toString()));
        if (recordsToMerge.size() < 2) {
            this.totalDrsSkipped += 1;
            return;
        }

        // Run merge DML operation
        try {
            SObject masterRecord = recordsToMerge[0];
            for (Integer i = 1; i < recordsToMerge.size(); i++) {
                SObject mergeRecord = recordsToMerge[i];
                masterRecord = this.cloneMergeFieldValues(masterRecord, mergeRecord, fieldDefs);
                Database.merge(masterRecord, new List<SObject>{ mergeRecord }, true);
            }
            delete [SELECT Id FROM DuplicateRecordSet WHERE Id = :drs.Id];
            this.totalMergesSucceeded += 1;
        } catch (Exception ex) {
            this.totalMergesFailed += 1;
            Logger.error(ex);
        }
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug(
            'MergeDuplicatesBatch finished. SObjectType: {0} | DRS processed: {1} | DRS skipped: {2} | Merges succeeded: {3} | Merges failed: {4}',
            new List<Object>{
                this.rule.SobjectType,
                this.totalDrsProcessed,
                this.totalDrsSkipped,
                this.totalMergesSucceeded,
                this.totalMergesFailed
            }
        );
    }

    // ---

    private DuplicateRule selectAndValidateDuplicateRule(Id ruleId) {
        List<DuplicateRule> rules = [
            SELECT Id, IsActive, SobjectType, DeveloperName
            FROM DuplicateRule
            WHERE Id = :ruleId
            LIMIT 1
        ];
        if (rules.isEmpty()) {
            throw new IllegalArgumentException('DuplicateRule not found for ID: ' + ruleId);
        }
        return rules[0];
    }

    private Schema.FieldSet selectAndValidateFieldSetName(String fsApiName) {
        String objectName = this.rule.SobjectType;
        DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        if (!objectDescribe.fieldSets.getMap().containsKey(fsApiName)) {
            throw new IllegalArgumentException(
                String.format('{0} object has no field set named \'{1}\'', new List<String>{ objectName, fsApiName })
            );
        }
        return objectDescribe.fieldSets.getMap().get(fsApiName);
    }

    private List<SObjectField> collectMergeFieldDefs(Schema.FieldSet fieldSetDef) {
        List<SObjectField> fieldDefs = new List<SObjectField>();
        for (Schema.FieldSetMember fieldItem : fieldSetDef.getFields()) {
            if (!fieldItem.getSObjectField().getDescribe().isUpdateable()) {
                continue;
            }
            if (fieldItem.getSObjectField().getDescribe().isIdLookup()) {
                continue;
            }
            if (fieldItem.getSObjectField().getDescribe().isCalculated()) {
                continue;
            }
            if (fieldItem.getSObjectField().getDescribe().isAggregatable()) {
                continue;
            }
            if (fieldItem.getSObjectField().getDescribe().isAutoNumber()) {
                continue;
            }
            fieldDefs.add(fieldItem.getSObjectField());
        }
        return fieldDefs;
    }

    private List<String> collectFieldApiNames(List<SObjectField> fieldDefs) {
        List<String> fieldApiNames = new List<String>();
        for (SObjectField fieldDef : fieldDefs) {
            fieldApiNames.add(fieldDef.getDescribe().getName());
        }
        return fieldApiNames;
    }

    private SObject cloneMergeFieldValues(SObject masterRecord, SObject mergeRecord, List<SObjectField> fieldDefs) {
        for (SObjectField fieldDef : fieldDefs) {
            if (masterRecord.get(fieldDef) != null) {
                masterRecord.put(fieldDef, mergeRecord.get(fieldDef));
            }
        }
        return masterRecord;
    }
}
