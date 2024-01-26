public without sharing class DatatableController {
    private static final SObjectRepository repository = (SObjectRepository) Application.Service.newInstance(Repository.class);

    @AuraEnabled(Cacheable=true)
    public static Integer getContactsCount() {
        try {
            Integer totalCount = [SELECT COUNT() FROM Contact];
            return totalCount;
        } catch (Exception ex) {
            Logger.error(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<Contact> getContacts(Query query) {
        try {
            fflib_QueryFactory factory = new fflib_QueryFactory(Contact.SObjectType);
            factory.selectFields(query.fieldApiNames);
            factory.setOffset(query.offsetValue);
            factory.setLimit(query.limitValue);
            factory.setOrdering(Contact.Title, fflib_QueryFactory.SortOrder.ASCENDING);
            return (List<Contact>) repository.query(factory.toSOQL());
        } catch (Exception ex) {
            Logger.error(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class Query {
        @AuraEnabled
        public List<String> fieldApiNames { get; set; }
        @AuraEnabled
        public Integer offsetValue { get; set; }
        @AuraEnabled
        public Integer limitValue { get; set; }

        public Query() {
            this.fieldApiNames = Lists.of('Id', 'Name');
            this.offsetValue = 0;
            this.limitValue = 10;
        }
    }
}
