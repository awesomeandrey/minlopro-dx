public class ExternalObjectsDemo {
    /**
     * Pre-requisites:
     * 1. Configure 'SalesforceRestApi1' named credential (Legacy one)
     * 2. Configure External Data Source
     * 3. Run SOQL queries against external objects
     */
    public void run() {
        try {
            Logger.debug('Querying SalesforceContact__x object...');
            List<SalesforceContact__x> externalContacts = [
                SELECT ExternalId, Id, Name__c, DisplayUrl, SalesforceOwnerId__r.Name
                FROM SalesforceContact__x
                LIMIT 2
                OFFSET 5
            ];
            Assert.isFalse(externalContacts.isEmpty());
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
