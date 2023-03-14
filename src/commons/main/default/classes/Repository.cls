public interface Repository {
    List<SObject> query(String soqlQuery);
    List<List<SObject>> search(String query);
}
