public inherited sharing class SObjectRepository implements Repository {
    public List<SObject> query(String soqlQuery) {
        return Database.query(soqlQuery);
    }

    public List<SObject> queryWithBinds(
        String soqlQuery,
        Map<String, Object> binds,
        AccessLevel accessLevel
    ) {
        return Database.queryWithBinds(soqlQuery, binds, accessLevel);
    }

    public List<List<SObject>> search(String soslQuery) {
        return Search.query(soslQuery);
    }
}
