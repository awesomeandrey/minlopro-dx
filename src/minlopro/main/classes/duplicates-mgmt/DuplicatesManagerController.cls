/**
 * The idea is to leverage native Salesforce (de)duplication tool to identify identical records in Contact object.
 *
 * Contact matching logic will be based on the following fields:
 * - Contact.FirstName (fuzzy matching)
 * - Contact.LastName (fuzzy matching)
 * - Contact.Phone (exact matching)
 *
 * SF docs - https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Datacloud_FindDuplicates.htm
 */
public with sharing class DuplicatesManagerController {
    @AuraEnabled
    public static List<Contact> findDuplicates(Contact contactToCheck) {
        try {
            List<Contact> contactsToCheck = new List<Contact>{ contactToCheck };
            // Invoke platform API;
            List<Datacloud.FindDuplicatesResult> foundDupResults = Datacloud.FindDuplicates.findDuplicates(contactsToCheck);
            Assert.areEqual(contactsToCheck.size(), foundDupResults.size());

            // Process duplicates of any;
            Datacloud.FindDuplicatesResult findDuplicatesResult = foundDupResults.get(0);
            List<Datacloud.DuplicateResult> duplicateResults = findDuplicatesResult.getDuplicateResults();
            if (duplicateResults.isEmpty()) {
                return new List<Contact>();
            }
            Datacloud.DuplicateResult duplicateResult = duplicateResults[0];
            Datacloud.MatchResult matchResult = duplicateResult.getMatchResults()[0];
            List<Datacloud.MatchRecord> matchRecords = matchResult.getMatchRecords();
            List<SObject> duplicates = new List<SObject>();
            for (Datacloud.MatchRecord matchRecord : matchRecords) {
                duplicates.add(matchRecord.getRecord());
            }
            return [SELECT Id, AccountId, Email, Phone, CheckIfDuplicate__c FROM Contact WHERE Id IN :duplicates LIMIT 100];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Id upsertContact(Contact contactToUpsert) {
        try {
            upsert contactToUpsert;
            return contactToUpsert.Id;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
