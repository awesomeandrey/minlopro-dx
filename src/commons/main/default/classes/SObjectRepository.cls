public inherited sharing class SObjectRepository implements Repository {
    public List<SObject> query(String soqlQuery) {
        return Database.query(soqlQuery);
    }

    public List<List<SObject>> search(String soslQuery) {
        return Search.query(soslQuery);
    }
}
