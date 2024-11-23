@IsTest
private class UserSelectorTest {
    @IsTest
    static void getSObjectTypeTest() {
        UserSelector userSelector = new UserSelector();
        SObjectType sObjectType = userSelector.getSObjectType();
        Assert.areEqual(User.SObjectType, sObjectType, '`UserSelector.cls` has no `User` sobject type defined!');
    }

    @IsTest
    static void getSObjectFieldListTest() {
        UserSelector userSelector = new UserSelector();
        List<SObjectField> returnedSObjectFields = userSelector.getSObjectFieldList();
        Assert.isFalse(returnedSObjectFields.isEmpty(), '`UserSelector.cls` has no SOBJECT_FIELD_LIST defined!');
    }

    @IsTest
    static void selectSObjectsByIdTest() {
        // Given
        User mockedUser = new User(Id = fflib_IDGenerator.generate(User.getSObjectType()));
        List<User> mockedUsers = Lists.of(mockedUser);
        // When
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Repository repositoryMock = (Repository) mocks.mock(Repository.class);
        mocks.startStubbing();
        mocks.when(
                repositoryMock.queryWithBinds(
                    fflib_Match.anyString(),
                    (Map<String, Object>) fflib_Match.anyObject(),
                    (System.AccessLevel) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockedUsers);
        mocks.stopStubbing();
        Application.Service.setMock(Repository.class, repositoryMock);
        // Test
        Test.startTest();
        UserSelector userSelector = new UserSelector();
        List<User> queriedUsers = userSelector.selectSObjectsById(Sets.of(mockedUser.Id));
        Test.stopTest();
        // Verify
        Assert.isFalse(queriedUsers.isEmpty());
        Assert.areEqual(mockedUsers.size(), queriedUsers.size());
        Assert.areEqual(mockedUsers[0].Id, queriedUsers[0].Id);
    }
}
