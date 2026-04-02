public without sharing class MergeDuplicatesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {
    private DuplicateRule rule;
    private Schema.FieldSet mergeFieldsSet;
    private String soqlCondition;

    private Integer totalDrsProcessed = 0;
    private Integer totalMergesSucceeded = 0;
    private Integer totalMergesFailed = 0;

    public MergeDuplicatesBatch(Id duplicateRuleId, String mergeFieldsSetApiName, String soqlCondition) {
        this.rule = this.selectAndValidateDuplicateRule(duplicateRuleId);
        this.mergeFieldsSet = this.selectAndValidateFieldSet(mergeFieldsSetApiName);
        this.soqlCondition = soqlCondition;
        Logger.debug(
            'MergeDuplicatesBatch initialised. Rule: {0}, SObjectType: {1}, FieldSet Name: {2}',
            Lists.of(this.rule.DeveloperName, this.rule.SobjectType, this.mergeFieldsSet.getName())
        );
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = String.format(
            'SELECT Id FROM DuplicateRecordSet WHERE DuplicateRuleId = \'{0}\' AND RecordCount > 1',
            new List<String>{ this.rule.Id }
        );
        if (String.isNotBlank(this.soqlCondition)) {
            query += ' WHERE ' + this.soqlCondition;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> records) {
        //        this.totalDrsProcessed++;
        //        Id drsId = records[0].Id;
        //
        //        // --- Step 1: Load DuplicateRecordItem children to get target record IDs ---
        //        List<DuplicateRecordItem> driRecords = [
        //            SELECT RecordId
        //            FROM DuplicateRecordItem
        //            WHERE DuplicateRecordSetId = :drsId
        //        ];
        //        if (driRecords.size() < 2) {
        //            Logger.debug('DRS {0} has fewer than 2 items, skipping.', new List<Object>{ drsId });
        //            return;
        //        }
        //
        //        Set<Id> recordIds = new Set<Id>();
        //        for (DuplicateRecordItem dri : driRecords) {
        //            recordIds.add(dri.RecordId);
        //        }
        //
        //        // --- Step 2: Query target SObjects with all updateable fields, oldest first ---
        //        String soql =
        //            'SELECT Id, LastModifiedDate, ' +
        //            String.join(this.updateableFieldNames, ', ') +
        //            ' FROM ' +
        //            sObjectTypeName +
        //            ' WHERE Id IN :recordIds ORDER BY LastModifiedDate ASC';
        //        List<SObject> sObjects = Security.stripInaccessible(AccessType.UPDATABLE, Database.query(soql)).getRecords();
        //
        //        if (sObjects.size() < 2) {
        //            Logger.debug('DRS {0}: fewer than 2 live records found, skipping.', new List<Object>{ drsId });
        //            return;
        //        }
        //
        //        // --- Step 3: Master = oldest record; fill blank fields from each duplicate ---
        //        SObject masterRecord = sObjects[0];
        //        for (Integer i = 1; i < sObjects.size(); i++) {
        //            masterRecord = this.resolveMergeFields(masterRecord, sObjects[i]);
        //        }
        //
        //        // --- Step 4: Merge duplicates into master in chunks of 2 (platform limit) ---
        //        List<Id> dupeIds = new List<Id>();
        //        for (Integer i = 1; i < sObjects.size(); i++) {
        //            dupeIds.add(sObjects[i].Id);
        //        }
        //
        //        TriggerDispatcher.bypass(Account.SObjectType, 'TH_Account_Sample2');
        //
        //        Boolean mergeSucceeded = true;
        //        Integer chunkStart = 0;
        //        while (chunkStart < dupeIds.size()) {
        //            List<Id> chunk = new List<Id>();
        //            for (Integer i = chunkStart; i < Math.min(chunkStart + 2, dupeIds.size()); i++) {
        //                chunk.add(dupeIds[i]);
        //            }
        //            List<Database.MergeResult> mergeResults = Database.merge(masterRecord, chunk, false);
        //            for (Database.MergeResult mr : mergeResults) {
        //                if (!mr.isSuccess()) {
        //                    Logger.error(
        //                        'Merge failed for DRS {0}, master {1}: {2}',
        //                        new List<Object>{ drsId, masterRecord.Id, JSON.serialize(mr.getErrors()) }
        //                    );
        //                    mergeSucceeded = false;
        //                }
        //            }
        //            if (!mergeSucceeded) {
        //                break;
        //            }
        //            chunkStart += 2;
        //        }
        //
        //        // --- Step 5: On full success, clean up DRS + DRI records ---
        //        if (mergeSucceeded) {
        //            this.totalMergesSucceeded++;
        //            delete driRecords;
        //            delete records[0];
        //        } else {
        //            this.totalMergesFailed++;
        //        }
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug(
            'MergeDuplicatesBatch finished. SObjectType: {0} | DRS processed: {1} | Merges succeeded: {2} | Merges failed: {3}',
            new List<Object>{ this.rule.SobjectType, this.totalDrsProcessed, this.totalMergesSucceeded, this.totalMergesFailed }
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

    private Schema.FieldSet selectAndValidateFieldSet(String fsApiName) {
        String objectName = this.rule.SobjectType;
        DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        if (!objectDescribe.fieldSets.getMap().containsKey(fsApiName)) {
            throw new IllegalArgumentException(
                String.format('{0} object has no field set named \'{1}\'', new List<String>{ objectName, fsApiName })
            );
        }
        return objectDescribe.fieldSets.getMap().get(fsApiName);
    }

    private List<SObjectField> collectMergeFieldDefs() {
        List<SObjectField> fieldDefs = new List<SObjectField>();
        for (Schema.FieldSetMember fieldItem : this.mergeFieldsSet.getFields()) {
            fieldDefs.add(fieldItem.getSObjectField());
        }
        return fieldDefs;
    }

    private SObject cloneMergeFieldValue(SObject masterRecord, SObject mergeRecord) {
        for (SObjectField fieldDef : this.collectMergeFieldDefs()) {
            if (masterRecord.get(fieldDef) != null) {
                masterRecord.put(fieldDef, mergeRecord.get(fieldDef));
            }
        }
        return masterRecord;
    }
}
