public interface Repository {
    List<SObject> query(String soqlQuery);
    List<SObject> queryWithBinds(String soqlQuery, Map<String, Object> binds, System.AccessLevel accessLevel);
    List<List<SObject>> search(String query);
}
