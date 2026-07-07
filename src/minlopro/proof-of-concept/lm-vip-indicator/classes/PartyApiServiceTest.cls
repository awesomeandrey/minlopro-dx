@IsTest
private class PartyApiServiceTest {
    @IsTest
    static void searchAccount_200_Match() {
        Account personAccount = buildSearchEligibleAccount();
        PartyApiService.Party mockedParty = buildPartyFromAccount(personAccount);
        PartyApiService.SearchResult mockedSearchRes = new PartyApiService.SearchResult();
        mockedSearchRes.party.add(mockedParty);

        Test.setMock(HttpCalloutMock.class, new PartyApiSearchMock(200, mockedSearchRes));
        Test.startTest();
        PartyApiService service = new PartyApiService();
        PartyApiService.SearchResult result = service.search(personAccount);
        Test.stopTest();

        Assert.areEqual(1, result.party.size());
        PartyApiService.Party foundParty = result.party.get(0);
        Assert.areEqual(personAccount.FirstName, foundParty.givenName);
        Assert.areEqual(personAccount.LastName, foundParty.surName);
    }

    @IsTest
    static void searchAccount_404_NotFound() {
        Account personAccount = buildSearchEligibleAccount();

        Test.setMock(HttpCalloutMock.class, new PartyApiSearchMock(404));
        Test.startTest();
        PartyApiService service = new PartyApiService();
        PartyApiService.SearchResult result = service.search(personAccount);
        Test.stopTest();

        Assert.isTrue(result.party.isEmpty());
    }

    @IsTest
    static void searchAccount_CalloutException() {
        Account personAccount = buildSearchEligibleAccount();
        Test.setMock(HttpCalloutMock.class, new PartyApiSearchMock(500));
        try {
            new PartyApiService().search(personAccount);
            Assert.fail('Callout exception should have been thrown.');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, CalloutException.class);
        }
    }

    @IsTest
    static void searchAccount_InvalidFilter() {
        Account personAccount = buildSearchIneligibleAccount();
        PartyApiService service = new PartyApiService();
        PartyApiService.SearchResult result = service.search(personAccount);
        Assert.isTrue(result.party.isEmpty());
    }

    @IsTest
    static void validate_PartyFilter_DTO() {
        PartyApiService.PartyFilter validFilter1 = buildValidPartyFilter();
        validFilter1.normalizeAddressParams();
        Assert.isTrue(validFilter1.isValid());
        Assert.areEqual(10, validFilter1.populatedParametersCount());

        PartyApiService.PartyFilter validFilter2 = validFilter1.clone();
        validFilter2.postalCode = null;
        Assert.isTrue(String.isNotBlank(validFilter2.addressLine1));
        validFilter2.normalizeAddressParams(); // Should cleanup address lines
        Assert.isTrue(String.isBlank(validFilter2.addressLine1));
        Assert.isTrue(String.isBlank(validFilter2.addressLine2));
        Assert.isTrue(validFilter2.isValid());
        Assert.areEqual(7, validFilter2.populatedParametersCount());

        PartyApiService.PartyFilter invalidFilter = validFilter2.clone();
        invalidFilter.phoneNumber = null;
        invalidFilter.stateOrProvinceCode = null;
        invalidFilter.driverLicenseNumber = null;
        Assert.isFalse(invalidFilter.isValid());
        Assert.areEqual(4, invalidFilter.populatedParametersCount());

        invalidFilter.givenName = null;
        Assert.isFalse(invalidFilter.isValid());
        Assert.areEqual(3, invalidFilter.populatedParametersCount());
    }

    private static Account buildSearchEligibleAccount() {
        Account personAccount = new Account();
        personAccount.FirstName = 'John';
        personAccount.LastName = 'Doe';
        personAccount.PersonEmail = 'test-customer@party.api';
        personAccount.PersonBirthdate = Date.today().addYears(-30);
        personAccount.Phone = '222-222-2222';
        personAccount.PersonMailingStreet = '415 Mission Street';
        personAccount.PersonMailingCity = 'San Francisco';
        personAccount.PersonMailingState = 'CA';
        personAccount.PersonMailingPostalCode = '94105';
        personAccount.PersonMailingCountry = 'US';
        return personAccount;
    }

    private static Account buildSearchIneligibleAccount() {
        Account personAccount = buildSearchEligibleAccount();
        personAccount.FirstName = null;
        personAccount.LastName = null;
        personAccount.PersonEmail = null;
        personAccount.Phone = null;
        return personAccount;
    }

    private static PartyApiService.Party buildPartyFromAccount(Account personAccount) {
        PartyApiService.Party partyDef = new PartyApiService.Party();
        partyDef.id = System.UUID.randomUUID().toString();
        partyDef.givenName = personAccount.FirstName;
        partyDef.surName = personAccount.LastName;
        partyDef.vipIndicator = 'false';
        return partyDef;
    }

    private static PartyApiService.PartyFilter buildValidPartyFilter() {
        PartyApiService.PartyFilter filter = new PartyApiService.PartyFilter();
        filter.birthDate = String.valueOf(Date.today().addYears(-30));
        filter.emailAddress = 'john.smith@example.com';
        filter.givenName = 'John';
        filter.surName = 'Smith';
        filter.phoneNumber = '111-111-1111';
        filter.addressLine1 = '20 Emerald Dr';
        filter.addressLine2 = '16 Main A7';
        filter.postalCode = '72113';
        filter.stateOrProvinceCode = 'AR';
        filter.driverLicenseNumber = 'WN7-ABC-0000';
        return filter;
    }

    private class PartyApiSearchMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final PartyApiService.SearchResult searchResult;

        public PartyApiSearchMock(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public PartyApiSearchMock(Integer statusCode, PartyApiService.SearchResult searchResult) {
            this(statusCode);
            this.searchResult = searchResult;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.searchResult == null ? '{}' : JSON.serialize(this.searchResult));
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}
