/**
 * @description Mocked implementation of {@link PartyApiService} used exclusively when the
 * `EnableVipIndicatorMock` feature toggle is active. It returns deterministic {@link PartyApiService.SearchResult}
 * payloads driven by the Account's `FirstName` / `LastName` values:
 *
 * - `$Banner$ / $VIP$`              → single match with `vipIndicator = true`  (person IS a BoD member)
 * - `$Banner$ / $In-VIP-Household$` → single match with `vipIndicator = false` (no direct match; household lookup applies)
 * - `$Banner$ / $Multi-Match$`      → two records with `vipIndicator = false`  (ambiguous multi-match)
 * - `$Banner$ / $Error$`            → throws {@link IllegalArgumentException}  (simulates an API error)
 * - any other variation             → delegates to `super.search()` method that calls Party API
 *
 * Intended for UI-level manual testing only.
 */
public class PartyApiServiceWithSearchMocks extends PartyApiService {
    public override SearchResult search(Account personAccount) {
        PartyApiService.SearchResult result = new PartyApiService.SearchResult();
        result.logMessage = 'MOCK';
        if (personAccount.LastName == '$VIP$') {
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
        } else if (personAccount.FirstName == '$Banner$') {
            // Single no-match
            PartyApiService.Party party = new PartyApiService.Party();
            party.vipIndicator = 'false';
            result.party = new List<PartyApiService.Party>{ party };
            return result;
        } else {
            return super.search(personAccount);
        }
    }
}
