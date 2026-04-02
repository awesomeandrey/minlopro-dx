/**
 * Batch job that detects duplicate records for a given DuplicateRule and persists
 * the findings as DuplicateRecordSet / DuplicateRecordItem entries.
 *
 * IMPORTANT: This batch MUST be invoked with a scope of exactly 50 records to comply
 * with the hard platform limit of Datacloud.FindDuplicates.findDuplicates():
 *
 * Sample: Database.executeBatch(new DetectDuplicatesBatch(ruleId), 50);
 */

/**
 * TODO - handle errors; ideally send email with data stats?
 */
public without sharing class DetectDuplicatesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {
    private DuplicateRule rule;
    private String soqlCondition;

    private Integer totalRecordsProcessed = 0;
    private Integer totalDrsCreated = 0;

    public DetectDuplicatesBatch(Id duplicateRuleId, String soqlCondition) {
        this.rule = this.selectAndValidateDuplicateRule(duplicateRuleId);
        this.soqlCondition = soqlCondition;
        Logger.debug(
            'DetectDuplicatesBatch initialised. Rule: {0}, SObjectType: {1}',
            Lists.of(this.rule.DeveloperName, this.rule.SobjectType)
        );
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM ' + this.rule.SobjectType;
        if (String.isNotBlank(this.soqlCondition)) {
            query += ' WHERE ' + this.soqlCondition;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> records) {
        // Enforce limit of 50 records because of FindDuplicates API
        final Integer BATCH_SCOPE_LIMIT = 50;
        if (records.size() > BATCH_SCOPE_LIMIT) {
            IllegalArgumentException ex = new IllegalArgumentException(
                String.format(
                    'Batch scope of {0} exceeds the hard limit of {1} imposed by Datacloud.FindDuplicates.findDuplicates(). Chunk skipped.',
                    new List<Object>{ records.size(), BATCH_SCOPE_LIMIT }
                )
            );
            Logger.error(ex);
            throw ex;
        }

        this.totalRecordsProcessed += records.size();

        // --- Step 1: Find duplicates via platform API ---
        List<Datacloud.FindDuplicatesResult> findResults = Datacloud.FindDuplicates.findDuplicates(records);

        // --- Step 2: Cast 'findResult's into manageable structure (this step also de-dupes DRSs within current batch chunk) ---
        List<DetectDuplicatesBatch.RecordSet> recordSets = this.collectRecordSets(records, findResults);

        // --- Step 3: Collect record IDs that correspond to existing 'DuplicateRecordItem' entries ---
        Set<Id> existingRecordIdsAsDuplicateRecordItems = this.collectRecordIdsInExistingDuplicateRuleItems(recordSets);

        // --- Step 4: Compose final list of DRSs to insert ---
        List<DetectDuplicatesBatch.RecordSet> recordSetsToInsert = new List<DetectDuplicatesBatch.RecordSet>();
        for (DetectDuplicatesBatch.RecordSet recordSetToValidate : recordSets) {
            // Check if recordItem already exists in DB
            if (existingRecordIdsAsDuplicateRecordItems.contains(recordSetToValidate.sourceRecordId)) {
                continue;
            }
            recordSetsToInsert.add(recordSetToValidate);
        }
        Logger.debug('recordSetsToInsert = {0}', Lists.of(recordSetsToInsert.size().toString()));
        if (recordSetsToInsert.isEmpty()) {
            return;
        }

        // --- Step 5: Insert DRSs ---
        List<DuplicateRecordSet> duplicateRecordSets = new List<DuplicateRecordSet>();
        for (DetectDuplicatesBatch.RecordSet recordSetEntry : recordSetsToInsert) {
            duplicateRecordSets.add(recordSetEntry.composeDuplicateRecordSet(this.rule.Id));
        }
        insert duplicateRecordSets;

        List<DuplicateRecordItem> duplicateRecordItems = new List<DuplicateRecordItem>();
        for (Integer i = 0; i < duplicateRecordSets.size(); i++) {
            DuplicateRecordSet drsRecord = duplicateRecordSets[i];
            DetectDuplicatesBatch.RecordSet recordSetEntry = recordSetsToInsert[i];
            duplicateRecordItems.addAll(recordSetEntry.composeDuplicateRecordItems(drsRecord.Id));
        }
        insert duplicateRecordItems;

        this.totalDrsCreated += duplicateRecordSets.size();
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug(
            'DetectDuplicatesBatch finished. SObjectType: {0} | Records processed: {1} | DuplicateRecordSet records created: {2}',
            Lists.of(this.rule.SobjectType, this.totalRecordsProcessed.toString(), this.totalDrsCreated.toString())
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
        DuplicateRule rule = rules[0];
        if (!rule.IsActive) {
            throw new IllegalArgumentException('DuplicateRule is inactive: ' + rule.DeveloperName);
        }
        return rule;
    }

    private List<DetectDuplicatesBatch.RecordSet> collectRecordSets(
        List<SObject> records,
        List<Datacloud.FindDuplicatesResult> findResults
    ) {
        List<DetectDuplicatesBatch.RecordSet> recordSets = new List<DetectDuplicatesBatch.RecordSet>();
        Set<Id> allRecordIds = new Set<Id>();
        for (Integer i = 0; i < findResults.size(); i++) {
            Datacloud.FindDuplicatesResult findResult = findResults[i];
            Id sourceRecordId = records[i].Id;
            for (Datacloud.DuplicateResult dupeResult : findResult.getDuplicateResults()) {
                // Filter: only process results belonging to the configured rule
                if (!dupeResult.getDuplicateRule().equalsIgnoreCase(this.rule.DeveloperName)) {
                    continue;
                }
                // Record set should have 2 records at least
                DetectDuplicatesBatch.RecordSet recordSetEntry = new DetectDuplicatesBatch.RecordSet(sourceRecordId, dupeResult);
                if (!recordSetEntry.isValid()) {
                    continue;
                }
                // Guardrail to prevent adding {B,A,C} record set when {A,B,C} is already there
                if (allRecordIds.containsAll(recordSetEntry.dupeRecordIds)) {
                    continue;
                }
                allRecordIds.addAll(recordSetEntry.dupeRecordIds);
                recordSets.add(recordSetEntry);
            }
        }
        return recordSets;
    }

    private Set<Id> collectRecordIdsInExistingDuplicateRuleItems(List<DetectDuplicatesBatch.RecordSet> recordSets) {
        Set<Id> matchedRecordIdsInRecordSets = new Set<Id>();
        for (DetectDuplicatesBatch.RecordSet recordSetEntry : recordSets) {
            matchedRecordIdsInRecordSets.addAll(recordSetEntry.dupeRecordIds);
        }
        Set<Id> existingRecordIdsAsDuplicateRecordItems = new Set<Id>();
        for (DuplicateRecordItem item : [
            SELECT Id, RecordId
            FROM DuplicateRecordItem
            WHERE RecordId IN :matchedRecordIdsInRecordSets AND DuplicateRecordSet.DuplicateRuleId = :this.rule.Id
        ]) {
            existingRecordIdsAsDuplicateRecordItems.add(item.RecordId);
        }
        return existingRecordIdsAsDuplicateRecordItems;
    }

    private class RecordSet {
        private final Id sourceRecordId;
        private final Set<Id> dupeRecordIds;

        private RecordSet(Id sourceRecordId, Datacloud.DuplicateResult dupeResult) {
            this.sourceRecordId = sourceRecordId;
            this.dupeRecordIds = new Set<Id>{ this.sourceRecordId }; // Initialize with source record ID immediately

            // Collect the source record + all matched records for this duplicate set
            for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                    this.dupeRecordIds.add(matchRecord.getRecord().Id);
                }
            }
        }

        private Boolean isValid() {
            // Only create a set when there is at least one matched counterpart
            return this.dupeRecordIds.size() > 1;
        }

        private DuplicateRecordSet composeDuplicateRecordSet(Id ruleId) {
            return new DuplicateRecordSet(DuplicateRuleId = ruleId);
        }

        private List<DuplicateRecordItem> composeDuplicateRecordItems(Id recordSetId) {
            List<DuplicateRecordItem> items = new List<DuplicateRecordItem>();
            for (Id recordId : this.dupeRecordIds) {
                items.add(new DuplicateRecordItem(DuplicateRecordSetId = recordSetId, RecordId = recordId));
            }
            return items;
        }
    }
}
