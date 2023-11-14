@IsTest
public class ContactLockingTest {
    /**
     * Users with Modify All Data or Modify All for given object permission
     * can update locked records and bypass Approval.Lock API
     */

    /*
    @IsTest
    public static void testContactLockingAsAdmin() {
        // Create test user;
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user1 = TestDataFactory.createUser('1User1', 'Test', profile.Id);
        insert user1;

        // Create permission set that grants View All access to Contact object;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet ps = setupContactPermissionSet();
            // Assign PS to User1;
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = user1.Id);
        }

        Test.startTest();
        // Create Contact record;
        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert contact;
        // Share Contact with User 1 (granting read-write access)
        ContactShare contactShare = new ContactShare(
                ContactId = contact.Id,
                UserOrGroupId = user1.Id,
                ContactAccessLevel = 'Edit',
                RowCause = 'Manual'
        );
        insert contactShare;
        Test.stopTest();

        List<ContactShare> shares = [SELECT ContactAccessLevel, RowCause, UserOrGroup.Name FROM ContactShare WHERE ContactId = :contact.Id];
        Assert.areEqual(2, shares.size(), 'There should be 2 share records only > Owner & Manual');
        System.debug('\n\n shares => ' + shares + '\n');

        UserRecordAccess uraAsAdmin = [
                SELECT RecordId, HasEditAccess, HasTransferAccess, HasReadAccess
                FROM UserRecordAccess
                WHERE RecordId = :contact.Id AND UserId = :UserInfo.getUserId()
                LIMIT 1
        ];
        Assert.isTrue(uraAsAdmin.HasReadAccess, 'Admin has no Read access');
        Assert.isTrue(uraAsAdmin.HasEditAccess, 'Admin has no Edit access');
        Assert.isTrue(uraAsAdmin.HasTransferAccess, 'Admin has no Transfer access');
        UserRecordAccess uraAsUser1 = [
                SELECT RecordId, HasEditAccess, HasReadAccess, HasTransferAccess

                FROM UserRecordAccess
                WHERE RecordId = :contact.Id AND UserId = :user1.Id
                LIMIT 1
        ];
        Assert.isTrue(uraAsUser1.HasReadAccess, 'User1 has no Read access');
//        Assert.isTrue(uraAsUser1.HasEditAccess, 'User1 has no Edit access');
        Assert.isFalse(uraAsUser1.HasTransferAccess, 'User1 has Transfer access (but should not)');

        // Lock the record;
        Approval.LockResult lockResult = Approval.lock(contact.Id);
        System.assertEquals(true, lockResult.isSuccess(), 'Contact should have been locked successfully');
        Assert.isTrue(Approval.isLocked(contact), 'The contact is not locked!');

        System.runAs(user1) {
            Assert.areEqual(user1.Id, UserInfo.getUserId());
            Contact queriedContact = [SELECT Id, LastName FROM Contact WHERE Id = :contact.Id LIMIT 1];
            Assert.isTrue(Approval.isLocked(queriedContact), 'The contact is not locked!');
        }
    }
    */

    private static PermissionSet setupContactPermissionSet() {
        PermissionSet ps = new PermissionSet(Name = 'GrantContactViewAllAccess', Label = 'GrantContactViewAllAccess');
        insert ps;
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(
            new ObjectPermissions(
                ParentId = ps.Id,
                SobjectType = 'Contact',
                PermissionsRead = true,
                PermissionsViewAllRecords = true,
                PermissionsEdit = true
            )
        );
        insert op;
        return ps;
    }
}
