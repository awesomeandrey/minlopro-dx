@IsTest
private class LmPocProductIntersection {
    // Conceptual idea;
    private static Boolean hasAccountAlreadyOpenedOpportunityWithSameProduct(
        Set<String> leadProducts,

            Set<String> accountProducts
    ) {
        if (accountProducts == null || accountProducts.isEmpty()) {
            // The lead should be screened (meaning that new PA/Opp should be created);
            return false;
        }
        if (accountProducts.size() < leadProducts.size()) {
            // Obviously, the lead has new products the prospect is interested in (hence new PA/Opp should be created);
            return false;
        }
        return accountProducts.containsAll(leadProducts);
    }

    @IsTest
    static void case1() {
        Set<String> leadProducts = new Set<String>{ 'Auto' };
        Set<String> existingAccountProducts = new Set<String>();
        Assert.isFalse(hasAccountAlreadyOpenedOpportunityWithSameProduct(leadProducts, existingAccountProducts));
    }

    @IsTest
    static void case2() {
        Set<String> leadProducts = new Set<String>{ 'Auto' };
        Set<String> existingAccountProducts = new Set<String>{ 'Auto', 'Home', 'Life', 'Property' };
        Assert.isTrue(hasAccountAlreadyOpenedOpportunityWithSameProduct(leadProducts, existingAccountProducts));
    }

    @IsTest
    static void case3() {
        Set<String> leadProducts = new Set<String>{ 'Condo' };
        Set<String> existingAccountProducts = new Set<String>{ 'Auto', 'Home', 'Life', 'Property' };
        Assert.isFalse(hasAccountAlreadyOpenedOpportunityWithSameProduct(leadProducts, existingAccountProducts));
    }

    @IsTest
    static void case4() {
        Set<String> leadProducts = new Set<String>{ 'Auto', 'Home', 'Life', 'Property' };
        Set<String> existingAccountProducts = new Set<String>{ 'Life', 'Property', 'Auto', 'Home' }; // re-ordered;
        Assert.isTrue(hasAccountAlreadyOpenedOpportunityWithSameProduct(leadProducts, existingAccountProducts));
    }

    @IsTest
    static void case5() {
        Set<String> leadProducts = new Set<String>{ 'Auto', 'Home', 'Life', 'Property' };
        Set<String> existingAccountProducts = new Set<String>{ 'Life', 'Property' };
        Assert.isFalse(hasAccountAlreadyOpenedOpportunityWithSameProduct(leadProducts, existingAccountProducts));
    }
}
