public without sharing class CurrencyRollupController {
    @AuraEnabled
    public static Decimal rollupOpportunitiesByAccountId(Id accountId) {
        /**
         * You can’t convert the result of an aggregate function into the user’s currency by calling the convertCurrency() function.
         * If a query includes a GROUP BY or HAVING clause, currency data returned by using an aggregate function,
         * such as SUM() or MAX(), is in the org’s default currency.
         *
         * https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_querying_currency_fields.htm
         */
        try {
            // Query to get the sum of Amounts
            List<AggregateResult> results = [
                SELECT SUM(Amount) total
                FROM Opportunity
                WHERE AccountId = :accountId
            ];
            AggregateResult result = results[0];
            // Extracting the sum from the query result
            Decimal totalAmount = 0;
            if (result.get('total') != null) {
                totalAmount = (Decimal) result.get('total');
            }
            return totalAmount;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<CurrencyType> getOrgCurrencyTypes() {
        return [
            SELECT IsoCode, ConversionRate, IsCorporate, DecimalPlaces, IsActive
            FROM CurrencyType
            WHERE IsActive = TRUE
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Opportunity> fetchOpportunitiesByAccountId(Id accountId) {
        return [SELECT Id, Name, Amount, StageName, CurrencyIsoCode FROM Opportunity WHERE AccountId = :accountId];
    }
}
