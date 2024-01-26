@IsTest
private class DatatableControllerTest {
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
        Integer contactsTotalCount = DatatableController.getContactsCount();
        Assert.areEqual(CONTACTS_AMOUNT, contactsTotalCount, 'Total contacts count did not match!');
    }

    @IsTest
    static void testGetContacts() {
        DatatableController.Query queryInfo = new DatatableController.Query();
        queryInfo.offsetValue = 7;
        queryInfo.limitValue = 10;
        List<Contact> fetchedContacts = DatatableController.getContacts(queryInfo);
        Assert.areEqual(3, fetchedContacts.size(), 'Offset/Limit criteria was not applied!');
    }

    @IsTest
    static void testGetContactsWithInvalidFieldApiName() {
        DatatableController.Query queryInfo = new DatatableController.Query();
        queryInfo.fieldApiNames = Lists.of('InvalidFieldApiName__c');
        Boolean exceptionCaught = false;
        try {
            DatatableController.getContacts(queryInfo);
        } catch (Exception ex) {
            exceptionCaught = true;
        }
        Assert.isTrue(exceptionCaught, 'Exception should have occurred!');
    }
}
