@IsTest
private class KeysetPaginationControllerTest {
    @IsTest
    static void testGetTotalContactsCount() {
        Integer recordsCount = 15;
        insert TestDataFactory.createContacts(recordsCount);
        Integer expectedCount = [SELECT COUNT() FROM Contact];
        Assert.areEqual(recordsCount, expectedCount);
        Integer actualCount = KeysetPaginationController.getTotalContactsCount();
        Assert.areEqual(expectedCount, actualCount, 'Total contacts count is incorrect');
    }

    @IsTest
    static void testGetContactRecords_AscByFirstName() {
        final Integer pageSize = 4;
        final Integer totalRecordsCount = 11; // This results in 3 pages (4 + 4 + 3);
        final Integer lastPageSize = 3;

        // Create test data;
        List<Contact> contacts = TestDataFactory.createContacts(totalRecordsCount - 1); // 10 contacts with 'FirstName' populated;
        Contact contactWithNullFirstName = TestDataFactory.createContacts(1)[0]; // 1 contact with 'FirstName' = NULL;
        contactWithNullFirstName.FirstName = null;
        contacts.add(contactWithNullFirstName);
        insert contacts;
        contacts = [SELECT Id, FirstName FROM Contact ORDER BY FirstName ASC NULLS FIRST, Id ASC NULLS FIRST];
        Assert.areEqual(contactWithNullFirstName.Id, contacts[0].Id, 'The first test Contact should have FirstName = NULL');
        Assert.isNull(contacts[0].FirstName, 'The first test Contact should have FirstName = NULL');

        // Contact record references below correspond to the first & last record on the given page;
        Contact firstPage_FirstContact = contacts[0];
        Contact firstPage_LastContact = contacts[3];

        Contact secondPage_FirstContact = contacts[4];
        Contact secondPage_LastContact = contacts[7];

        Contact lastPage_FirstContact = contacts[8];
        Contact lastPage_LastContact = contacts[totalRecordsCount - 1];

        // Create query request putting static params;
        KeysetPaginationController.QueryRequest queryRequest = new KeysetPaginationController.QueryRequest();
        queryRequest.totalRecordsCount = totalRecordsCount;
        queryRequest.pageSize = pageSize;
        queryRequest.sortBy = 'FirstName';
        queryRequest.sortDirection = 'ASC';

        // Fetch the FIRST page;
        queryRequest.currentPageNumber = 1;
        queryRequest.requestedPageNumber = 1;
        queryRequest.previousRecordId = null;
        queryRequest.previousSortValue = null;
        queryRequest.nextRecordId = null;
        queryRequest.nextSortValue = null;
        List<Contact> firstPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, firstPageRecords.size(), 'Incorrect number of records on the FIRST page');
        Assert.areEqual(
            firstPage_FirstContact.FirstName,
            firstPageRecords[0].FirstName,
            'Incorrect first record on the FIRST page'
        );
        Assert.areEqual(
            firstPage_LastContact.FirstName,
            firstPageRecords[3].FirstName,
            'Incorrect last record on the FIRST page'
        );

        // Navigate to next page (forward pagination to the 2nd page);
        queryRequest.currentPageNumber = 1;
        queryRequest.requestedPageNumber = 2;
        queryRequest.previousRecordId = firstPage_FirstContact.Id;
        queryRequest.previousSortValue = firstPage_FirstContact.FirstName;
        queryRequest.nextRecordId = firstPage_LastContact.Id;
        queryRequest.nextSortValue = firstPage_LastContact.FirstName;
        List<Contact> nextPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, nextPageRecords.size(), 'Incorrect number of records on the SECOND page');
        Assert.areEqual(
            secondPage_FirstContact.FirstName,
            nextPageRecords[0].FirstName,
            'Incorrect last record on the SECOND page'
        );
        Assert.areEqual(secondPage_LastContact.FirstName, nextPageRecords[3].FirstName, 'Incorrect last record on the LAST page');

        // Fetch the LAST page;
        queryRequest.currentPageNumber = 2;
        queryRequest.requestedPageNumber = 3;
        queryRequest.previousRecordId = null;
        queryRequest.previousSortValue = null;
        queryRequest.nextRecordId = null;
        queryRequest.nextSortValue = null;
        List<Contact> lastPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(lastPageSize, lastPageRecords.size(), 'Incorrect number of records on the LAST page');
        Assert.areEqual(lastPage_FirstContact.FirstName, lastPageRecords[0].FirstName, 'Incorrect first record on the LAST page');
        Assert.areEqual(lastPage_LastContact.FirstName, lastPageRecords[2].FirstName, 'Incorrect last record on the LAST page');

        // Navigate to previous page (backward pagination to the 2nd page again);
        queryRequest.currentPageNumber = 3;
        queryRequest.requestedPageNumber = 2;
        queryRequest.previousRecordId = lastPage_FirstContact.Id;
        queryRequest.previousSortValue = lastPage_FirstContact.FirstName;
        queryRequest.nextRecordId = lastPage_LastContact.Id;
        queryRequest.nextSortValue = lastPage_LastContact.FirstName;
        List<Contact> previousPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, previousPageRecords.size(), 'Incorrect number of records on the SECOND page');
        Assert.areEqual(
            secondPage_FirstContact.FirstName,
            previousPageRecords[0].FirstName,
            'Incorrect last record on the SECOND page'
        );
        Assert.areEqual(
            secondPage_LastContact.FirstName,
            previousPageRecords[3].FirstName,
            'Incorrect last record on the LAST page'
        );
    }

    /**
     * This test is 95% identical except for the Contact order (now it's DESC).
     */
    @IsTest
    static void testGetContactRecords_DescByFirstName() {
        final Integer pageSize = 4;
        final Integer totalRecordsCount = 11; // This results in 3 pages (4 + 4 + 3);
        final Integer lastPageSize = 3;

        // Create test data;
        List<Contact> contacts = TestDataFactory.createContacts(totalRecordsCount - 1); // 10 contacts with 'FirstName' populated;
        Contact contactWithNullFirstName = TestDataFactory.createContacts(1)[0]; // 1 contact with 'FirstName' = NULL;
        contactWithNullFirstName.FirstName = null;
        contacts.add(contactWithNullFirstName);
        insert contacts;
        contacts = [SELECT Id, FirstName FROM Contact ORDER BY FirstName DESC NULLS LAST, Id DESC NULLS LAST];
        Integer lastContactIndex = contacts.size() - 1;
        Assert.areEqual(
            contactWithNullFirstName.Id,
            contacts[lastContactIndex].Id,
            'The last test Contact should have FirstName = NULL'
        );
        Assert.isNull(contacts[lastContactIndex].FirstName, 'The last test Contact should have FirstName = NULL');

        // Contact record references below correspond to the first & last record on the given page;
        Contact firstPage_FirstContact = contacts[0];
        Contact firstPage_LastContact = contacts[3];

        Contact secondPage_FirstContact = contacts[4];
        Contact secondPage_LastContact = contacts[7];

        Contact lastPage_FirstContact = contacts[8];
        Contact lastPage_LastContact = contacts[totalRecordsCount - 1];

        // Create query request putting static params;
        KeysetPaginationController.QueryRequest queryRequest = new KeysetPaginationController.QueryRequest();
        queryRequest.totalRecordsCount = totalRecordsCount;
        queryRequest.pageSize = pageSize;
        queryRequest.sortBy = 'FirstName';
        queryRequest.sortDirection = 'DESC';

        // Fetch the FIRST page;
        queryRequest.currentPageNumber = 1;
        queryRequest.requestedPageNumber = 1;
        queryRequest.previousRecordId = null;
        queryRequest.previousSortValue = null;
        queryRequest.nextRecordId = null;
        queryRequest.nextSortValue = null;
        List<Contact> firstPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, firstPageRecords.size(), 'Incorrect number of records on the FIRST page');
        Assert.areEqual(
            firstPage_FirstContact.FirstName,
            firstPageRecords[0].FirstName,
            'Incorrect first record on the FIRST page'
        );
        Assert.areEqual(
            firstPage_LastContact.FirstName,
            firstPageRecords[3].FirstName,
            'Incorrect last record on the FIRST page'
        );

        // Navigate to next page (forward pagination to the 2nd page);
        queryRequest.currentPageNumber = 1;
        queryRequest.requestedPageNumber = 2;
        queryRequest.previousRecordId = firstPage_FirstContact.Id;
        queryRequest.previousSortValue = firstPage_FirstContact.FirstName;
        queryRequest.nextRecordId = firstPage_LastContact.Id;
        queryRequest.nextSortValue = firstPage_LastContact.FirstName;
        List<Contact> nextPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, nextPageRecords.size(), 'Incorrect number of records on the SECOND page');
        Assert.areEqual(
            secondPage_FirstContact.FirstName,
            nextPageRecords[0].FirstName,
            'Incorrect last record on the SECOND page'
        );
        Assert.areEqual(secondPage_LastContact.FirstName, nextPageRecords[3].FirstName, 'Incorrect last record on the LAST page');

        // Fetch the LAST page;
        queryRequest.currentPageNumber = 2;
        queryRequest.requestedPageNumber = 3;
        queryRequest.previousRecordId = null;
        queryRequest.previousSortValue = null;
        queryRequest.nextRecordId = null;
        queryRequest.nextSortValue = null;
        List<Contact> lastPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(lastPageSize, lastPageRecords.size(), 'Incorrect number of records on the LAST page');
        Assert.areEqual(lastPage_FirstContact.FirstName, lastPageRecords[0].FirstName, 'Incorrect first record on the LAST page');
        Assert.areEqual(lastPage_LastContact.FirstName, lastPageRecords[2].FirstName, 'Incorrect last record on the LAST page');

        // Navigate to previous page (backward pagination to the 2nd page again);
        queryRequest.currentPageNumber = 3;
        queryRequest.requestedPageNumber = 2;
        queryRequest.previousRecordId = lastPage_FirstContact.Id;
        queryRequest.previousSortValue = lastPage_FirstContact.FirstName;
        queryRequest.nextRecordId = lastPage_LastContact.Id;
        queryRequest.nextSortValue = lastPage_LastContact.FirstName;
        List<Contact> previousPageRecords = KeysetPaginationController.getContactRecords(queryRequest);
        Assert.areEqual(pageSize, previousPageRecords.size(), 'Incorrect number of records on the SECOND page');
        Assert.areEqual(
            secondPage_FirstContact.FirstName,
            previousPageRecords[0].FirstName,
            'Incorrect last record on the SECOND page'
        );
        Assert.areEqual(
            secondPage_LastContact.FirstName,
            previousPageRecords[3].FirstName,
            'Incorrect last record on the LAST page'
        );
    }
}
