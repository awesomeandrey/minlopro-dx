@IsTest
private class DatatableContactsControllerTest {
    private static final Integer CONTACTS_AMOUNT = 10;

    @TestSetup
    static void createContacts() {
        List<Contact> contactsToCreate = new List<Contact>();
        for (Integer i = 0; i < CONTACTS_AMOUNT; i++) {
            contactsToCreate.add(
                new Contact(FirstName = 'TestFirstName' + i, LastName = 'TestLastName' + i, MobilePhone = '123456789')
            );
        }
        insert contactsToCreate;
    }

    @IsTest
    static void testGetContactsCount() {
        Integer contactsTotalCount = DatatableContactsController.getContactsCount();
        Assert.areEqual(CONTACTS_AMOUNT, contactsTotalCount, 'Total contacts count did not match!');
    }

    @IsTest
    static void testGetContacts() {
        DatatableContactsController.Query queryInfo = new DatatableContactsController.Query();
        queryInfo.offsetValue = 7;
        queryInfo.limitValue = 10;
        List<Contact> fetchedContacts = DatatableContactsController.getContacts(queryInfo);
        Assert.areEqual(3, fetchedContacts.size(), 'Offset/Limit criteria was not applied!');
    }

    @IsTest
    static void testGetContactsWithInvalidFieldApiName() {
        DatatableContactsController.Query queryInfo = new DatatableContactsController.Query();
        queryInfo.fieldApiNames = Lists.of('InvalidFieldApiName__c');
        Boolean exceptionCaught = false;
        try {
            DatatableContactsController.getContacts(queryInfo);
        } catch (Exception ex) {
            exceptionCaught = true;
        }
        Assert.isTrue(exceptionCaught, 'Exception should have occurred!');
    }
}
