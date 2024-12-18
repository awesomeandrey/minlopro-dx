public class CM_Iterable implements Iterable<CM_DTO> {
    private final List<CM_DTO> records = new List<CM_DTO>();

    public void add(List<Contact> contacts) {
        for (Contact item : contacts) {
            this.records.add(new CM_DTO(item));
        }
    }

    public Iterator<CM_DTO> iterator() {
        return this.records.iterator();
    }
}
