public with sharing class VipIndicatorController {
    @TestVisible
    private static PartyApiService service = FeatureToggle.isActive('EnableVipIndicatorMock')
        ? new PartyApiServiceWithSearchMocks() // Applicable for manual testing / UI verification solely
        : new PartyApiService();

    @AuraEnabled(Cacheable=true)
    public static Banner computeBanner(Id accountId) {
        try {
            Account primaryAccount = selectAccounts(new List<Id>{ accountId })[0];
            if (!primaryAccount.IsPersonAccount) {
                throw new IllegalArgumentException('VIP Indicator is only supported for Person Accounts.');
            }
            PartyApiService.SearchResult primaryResult = service.search(primaryAccount);
            List<Account> householdAccounts = getHouseholdAccounts(primaryAccount);
            List<PartyApiService.SearchResult> householdResults = new List<PartyApiService.SearchResult>();
            for (Account member : householdAccounts) {
                if (member.Id != accountId) {
                    householdResults.add(service.search(member));
                }
            }
            Banner banner = new Banner(primaryResult, householdResults);
            banner.accountId = accountId;
            banner.compose();
            // Runtime.sleep(4000);
            return banner;
        } catch (Exception ex) {
            AuraHandledException ahe = new AuraHandledException(ex.getMessage());
            ahe.initCause(ex);
            throw ahe;
        }
    }

    private static List<Account> selectAccounts(List<Id> accountIds) {
        return [
            SELECT
                PersonBirthdate,
                PersonEmail,
                FirstName,
                LastName,
                Phone,
                PersonMailingStreet,
                BillingStreet,
                PersonMailingPostalCode,
                PersonMailingStateCode,
                IsPersonAccount
            FROM Account
            WHERE Id = :accountIds
        ];
    }

    private static List<Account> getHouseholdAccounts(Account primaryAccount) {
        if (
            FeatureToggle.isActive('EnableVipIndicatorMock') &&
            String.isNotBlank(primaryAccount.FirstName) &&
            primaryAccount.FirstName.containsIgnoreCase('$Banner$') &&
            String.isNotBlank(primaryAccount.LastName) &&
            primaryAccount.LastName.containsIgnoreCase('$In-VIP-Household$')
        ) {
            Map<Id, Account> mockedAccountsMap = new Map<Id, Account>(
                [SELECT Id FROM Account WHERE LastName = '$VIP$' AND IsPersonAccount = TRUE LIMIT 1]
            );
            return selectAccounts(new List<Id>(mockedAccountsMap.keySet()));
        }
        return new List<Account>{ primaryAccount };
    }

    public class Banner {
        @AuraEnabled
        public Id accountId { get; set; }
        @AuraEnabled
        public Boolean showBanner { get; set; }
        @AuraEnabled
        public Boolean isVip { get; set; }
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String logMessage {
            get {
                return this.primarySearchResult.logMessage;
            }
            set;
        }

        @TestVisible
        private final PartyApiService.SearchResult primarySearchResult;
        @TestVisible
        private final List<PartyApiService.SearchResult> householdSearchResults;

        public Banner(PartyApiService.SearchResult primaryResult) {
            this.primarySearchResult = primaryResult;
            this.householdSearchResults = new List<PartyApiService.SearchResult>();
        }

        public Banner(PartyApiService.SearchResult primaryResult, List<PartyApiService.SearchResult> householdResults) {
            this.primarySearchResult = primaryResult;
            this.householdSearchResults = householdResults;
        }

        private void compose() {
            if (this.isSingleVipMatch(this.primarySearchResult)) {
                this.isVip = true;
                this.showBanner = true;
                this.message = 'This person is a Board of Directors member.';
            } else if (this.hasVipInHousehold()) {
                this.isVip = false;
                this.showBanner = true;
                this.message = 'This person is associated with a Board of Directors member.';
            } else if (this.isMultiMatch(this.primarySearchResult)) {
                this.isVip = false;
                this.showBanner = true;
                this.message = 'Possible Board of Directors member (but we could not confirm 100% a 1-to-1 match).';
            } else {
                this.isVip = false;
                this.showBanner = false;
                this.message = 'Not a BoD member.';
            }
        }

        private Boolean isSingleVipMatch(PartyApiService.SearchResult searchResult) {
            return searchResult?.party?.size() == 1 && searchResult.party[0].vipIndicator?.equalsIgnoreCase('true');
        }

        private Boolean isMultiMatch(PartyApiService.SearchResult searchResult) {
            return searchResult?.party?.size() > 1;
        }

        private Boolean hasVipInHousehold() {
            for (PartyApiService.SearchResult result : this.householdSearchResults) {
                if (this.isSingleVipMatch(result)) {
                    return true;
                }
            }
            return false;
        }
    }
}
