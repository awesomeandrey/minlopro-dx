@IsTest
private class VipIndicatorControllerTest {
    @TestSetup
    static void setup() {
        // Create stub person accounts
        Account vipAccount = createPersonAccount();
        vipAccount.LastName = '$VIP$';
        Account multiMatchAccount = createPersonAccount();
        multiMatchAccount.LastName = '$Multi-Match$';
        Account errorAccount = createPersonAccount();
        errorAccount.LastName = '$Error$';
        insert new List<Account>{ vipAccount, multiMatchAccount, errorAccount };
    }

    @IsTest
    static void checkVipStatus_SingleMatchVip() {
        Account vipAccount = selectStubAccount('$VIP$');

        Test.startTest();
        VipIndicatorController.service = new VipIndicatorControllerTest.PartyApiServiceStub();
        VipIndicatorController.Banner banner = VipIndicatorController.checkVipStatus(vipAccount.Id);
        Test.stopTest();

        Assert.isTrue(banner.isVip);
    }

    @IsTest
    static void checkVipStatus_SingleMatchNotVip() {
        Account randomAccount = createPersonAccount();
        insert randomAccount;

        Test.startTest();
        VipIndicatorController.service = new VipIndicatorControllerTest.PartyApiServiceStub();
        VipIndicatorController.Banner banner = VipIndicatorController.checkVipStatus(randomAccount.Id);
        Test.stopTest();

        Assert.isFalse(banner.isVip);
        Assert.isTrue(banner.primarySearchResult.party.isEmpty());
    }

    @IsTest
    static void checkVipStatus_MultiMatch() {
        Account multiMatchAccount = selectStubAccount('$Multi-Match$');

        Test.startTest();
        VipIndicatorController.service = new VipIndicatorControllerTest.PartyApiServiceStub();
        VipIndicatorController.Banner banner = VipIndicatorController.checkVipStatus(multiMatchAccount.Id);
        Test.stopTest();

        Assert.isFalse(banner.isVip);
        Assert.isTrue(banner.primarySearchResult.party.size() > 1);
    }

    @IsTest
    static void checkVipStatus_ServerError() {
        Account errorAccount = selectStubAccount('$Error$');

        try {
            VipIndicatorController.service = new VipIndicatorControllerTest.PartyApiServiceStub();
            VipIndicatorController.checkVipStatus(errorAccount.Id);
            Assert.fail('Exception should have been caught.');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, AuraHandledException.class);
            Assert.isInstanceOfType(ex.getCause(), IllegalArgumentException.class);
        }
    }

    private static Account createPersonAccount() {
        Account personAccount = TestDataFactory.createPersonAccounts(1)[0];
        return personAccount;
    }

    private static Account selectStubAccount(String lastNameKey) {
        return selectStubAccounts().get(lastNameKey);
    }

    private static Map<String, Account> selectStubAccounts() {
        Map<String, Account> resultMap = new Map<String, Account>();
        for (Account stubAccount : [
            SELECT FirstName, LastName, IsPersonAccount
            FROM Account
            WHERE LastName LIKE '$%$'
            LIMIT 10
        ]) {
            resultMap.put(stubAccount.LastName, stubAccount);
        }
        return resultMap;
    }

    private class PartyApiServiceStub extends PartyApiService {
        public override SearchResult search(Account personAccount) {
            PartyApiService.SearchResult result = new PartyApiService.SearchResult();
            result.logMessage = 'STUB';
            if (personAccount.LastName == '$VIP$') {
                // Single VIP match
                PartyApiService.Party party = new PartyApiService.Party();
                party.vipIndicator = 'true';
                result.party = new List<PartyApiService.Party>{ party };
                return result;
            } else if (personAccount.LastName == '$Multi-Match$') {
                // Two non-matches
                PartyApiService.Party party1 = new PartyApiService.Party();
                party1.vipIndicator = 'false';
                PartyApiService.Party party2 = new PartyApiService.Party();
                party2.vipIndicator = 'false';
                result.party = new List<PartyApiService.Party>{ party1, party2 };
                return result;
            } else if (personAccount.LastName == '$Error$') {
                throw new IllegalArgumentException('Simulated error response from Party API.');
            } else {
                // Empty result set
                return result;
            }
        }
    }
}
