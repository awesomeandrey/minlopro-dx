public inherited sharing class Users extends fflib_SObjectDomain {
    private final UserSelector userSelector = (UserSelector) Application.Selector.newInstance(User.SObjectType);

    public Users(List<User> userRecords) {
        super(userRecords);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> userRecords) {
            return new Users(userRecords);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> usersById) {
        // Custom logic goes here;
    }
}
