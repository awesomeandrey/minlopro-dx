public class CM_DTO {
    public String name;
    public String prop1;
    public String prop2;

    public CM_DTO(Contact contactRecord) {
        this.name = contactRecord.Name;
        this.prop1 = contactRecord.Id;
        this.prop2 = contactRecord.GenderIdentity;
    }

    public override String toString() {
        return 'CM_DTO:{' + 'name=\'' + name + '\'' + ', prop1=\'' + prop1 + '\'' + ', prop2=\'' + prop2 + '\'' + '}';
    }
}
