/**
 * The idea is to leverage native Salesforce (de)duplication tool
 * to identify identical records in Contact object.
 *
 * Contact matching logic will be based on the following fields:
 * - Contact.FirstName
 * - Contact.LastName
 * - Contact.Phone
 */
public with sharing class DuplicatesManagerController {
    @AuraEnabled
    public static Object checkDuplicate(Contact contactToCheck) {
        try {
            // TODO - custom logic that validates Contact;
            // https://sachithradangalla.medium.com/using-duplicate-rules-in-apex-salesforce-131249ecfb4
            return false;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
