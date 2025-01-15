@IsTest
private class PKCETest {
    @IsTest
    static void generateAndGetStateTest() {
        String cacheKey = 'pkcetest';
        PKCE.State generatedState = PKCE.generate(cacheKey);
        Assert.isNotNull(generatedState, 'PKCE state was not generated');
        Assert.isNotNull(generatedState.code_challenge_method);
        Assert.isNotNull(generatedState.code_challenge);
        Assert.isNotNull(generatedState.code_verifier);
        PKCE.State retrievedState = PKCE.get(cacheKey);
        Assert.areEqual(generatedState.code_verifier, retrievedState.code_verifier);
        Assert.areEqual(generatedState.code_challenge, retrievedState.code_challenge);
        Assert.areEqual(generatedState.code_challenge_method, retrievedState.code_challenge_method);
    }
}
