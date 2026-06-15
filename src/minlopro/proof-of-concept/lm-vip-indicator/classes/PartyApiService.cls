public virtual inherited sharing class PartyApiService {
    public virtual SearchResult search(Account personAccount) {
        PartyFilter partyFilter = new PartyFilter();
        if (personAccount?.PersonBirthdate != null) {
            partyFilter.birthDate = String.valueOf(personAccount.PersonBirthdate);
        }
        partyFilter.emailAddress = personAccount.PersonEmail;
        partyFilter.givenName = personAccount.FirstName;
        partyFilter.surName = personAccount.LastName;
        String normalizedPhoneNumber = personAccount?.Phone?.replaceAll('\\D', '')?.right(10);
        if (String.isNotBlank(normalizedPhoneNumber) && Pattern.matches('^\\d{10}$', normalizedPhoneNumber)) {
            partyFilter.phoneNumber = normalizedPhoneNumber;
        }
        partyFilter.addressLine1 = personAccount.PersonMailingStreet;
        partyFilter.addressLine2 = personAccount.BillingStreet;
        partyFilter.postalCode = personAccount.PersonMailingPostalCode;
        partyFilter.stateOrProvinceCode = personAccount.PersonMailingStateCode;

        if (!partyFilter.isValid()) {
            // Skip API callout; return empty response payload intentionally
            SearchResult searchRes = new SearchResult();
            searchRes.logMessage = String.format(
                'Insufficient party filter criteria (filter params # = {0}).',
                new List<Object>{ partyFilter.populatedParametersCount() }
            );
            return searchRes;
        }

        SearchRequest request = new SearchRequest().default();
        request.partyFilter = partyFilter;
        return this.search(request);
    }

    public SearchResult search(SearchRequest searchReq) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PartyApi/partydomain/v3/search/parties');
        req.setMethod('POST');
        req.setHeader('app-name', 'salesforce-leadgen-cloud');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setBody(searchReq.toJson());
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 404) {
            SearchResult searchRes = new SearchResult();
            searchRes.logMessage = String.format(
                '{0} ({1}) No party information found for the given search criteria (filter params # = {2}).',
                new List<Object>{ res.getStatusCode(), res.getStatus(), searchReq.partyFilter.populatedParametersCount() }
            );
            return searchRes;
        } else if (res.getStatusCode() == 200) {
            SearchResult searchRes = (SearchResult) JSON.deserialize(res.getBody(), SearchResult.class);
            searchRes.logMessage = String.format(
                '{0} ({1}) Found {2} party(ies) for the given search criteria (filter params # = {3}).',
                new List<Object>{
                    res.getStatusCode(),
                    res.getStatus(),
                    searchRes.party?.size(),
                    searchReq.partyFilter.populatedParametersCount()
                }
            );
            return searchRes;
        } else {
            throw new CalloutException(
                String.format(
                    'Party API returned unsuccessful status: {0} ({1}) {2} (filter params # = {3}).',
                    new List<Object>{
                        res.getStatusCode(),
                        res.getStatus(),
                        res?.getBody()?.abbreviate(200),
                        searchReq.partyFilter.populatedParametersCount()
                    }
                )
            );
        }
    }

    // ── Request DTOs ──────────────────────────────────────────────────────────

    public class SearchRequest {
        public PartyFilter partyFilter;
        public PolicyFilter policyFilter;
        public Integer limitParam; // placeholder field normalized by custom 'toJson()' method
        public SearchFeatures searchFeatures;

        public String toJson() {
            // Note: suppress NULL values (required for 'partyFilter' to produce meaningful search result)
            // Note: replace "limitParam" → "limit" because 'limit' is Apex reserved keyword
            return JSON.serialize(this, true).replace('"limitParam"', '"limit"');
        }

        public SearchRequest default() {
            this.partyFilter = new PartyFilter();

            this.policyFilter = new PolicyFilter();
            this.policyFilter.showAllPolicies = false;

            this.searchFeatures = new SearchFeatures();
            this.searchFeatures.givenNameFuzzyIndicator = true;
            this.searchFeatures.surNameFuzzyIndicator = true;
            this.searchFeatures.emailDomainRequired = true;
            this.searchFeatures.isNickNameSearch = false;

            this.limitParam = 10;

            return this;
        }
    }

    public class PartyFilter {
        public String birthDate; // yyyy-mm-dd
        public String emailAddress;
        public String givenName; // *mandatory
        public String surName; // *mandatory
        public String phoneNumber; // 10-consecutive digits
        public String addressLine1;
        public String addressLine2;
        public String postalCode;
        public String stateOrProvinceCode;
        public String driverLicenseNumber;

        public Boolean isValid() {
            if (String.isBlank(this.givenName) || String.isBlank(this.surName)) {
                // Check for mandatory fields first
                return false;
            }
            if (
                String.isBlank(this.postalCode) && (String.isNotBlank(this.addressLine1) || String.isNotBlank(this.addressLine2))
            ) {
                // Eliminate 'Address Line 1/2 search requires Given Name, Sur Name and Zip' 400 (Bad Request) scenario
                return false;
            }
            // Enforce minimum filters threshold to avoid vague search result sets
            return this.populatedParametersCount() >= 5;
        }

        public Integer populatedParametersCount() {
            Integer count = 0;
            if (String.isNotBlank(this.birthDate))
                count++;
            if (String.isNotBlank(this.emailAddress))
                count++;
            if (String.isNotBlank(this.givenName))
                count++;
            if (String.isNotBlank(this.surName))
                count++;
            if (String.isNotBlank(this.phoneNumber))
                count++;
            if (String.isNotBlank(this.addressLine1))
                count++;
            if (String.isNotBlank(this.addressLine2))
                count++;
            if (String.isNotBlank(this.postalCode))
                count++;
            if (String.isNotBlank(this.stateOrProvinceCode))
                count++;
            if (String.isNotBlank(this.driverLicenseNumber))
                count++;
            return count;
        }
    }

    public class PolicyFilter {
        public Boolean showAllPolicies;
    }

    public class SearchFeatures {
        public Boolean givenNameFuzzyIndicator;
        public Boolean surNameFuzzyIndicator;
        public Boolean emailDomainRequired;
        public Boolean isNickNameSearch;
    }

    // ── Response DTOs ─────────────────────────────────────────────────────────

    public class SearchResult {
        public List<Party> party;

        public String logMessage;

        public SearchResult() {
            this.party = new List<Party>();
        }

        public SearchResult(String logMessage) {
            this();
            this.logMessage = logMessage;
        }
    }

    public class Party {
        public String id;
        public String givenName;
        public String surName;
        public String vipIndicator;
    }
}
