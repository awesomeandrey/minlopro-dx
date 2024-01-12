public class ExternalObjectsDemo {
    /**
     * Pre-requisites:
     * 1. Configure 'SalesforceRestApi' named credentials (legacy ones)
     * 2. Configure External Data Source
     * 3. Run SOQL queries against external objects
     */
    public void run() {
        try {
            List<SalesforceContact__x> externalContacts = [
                SELECT ExternalId, Id, Name__c, DisplayUrl, SalesforceOwnerId__r.Name
                FROM SalesforceContact__x
                LIMIT 2
                OFFSET 5
            ];
            Logger.debug(externalContacts.size());
            Logger.debug(externalContacts);
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
