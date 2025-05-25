public without sharing class PKCE {
    private final static Cache.OrgPartition PARTITION = Cache.Org.getPartition('local.PKCE'); // Org Cache;

    public static State generate(String cacheKey) {
        // Step 1 - Invoke public Salesforce endpoint to get PKCE state;
        State pkceState = Test.isRunningTest() ? generateRandom() : generate();
        // Step 2 - Save state in Platform Cache;
        PARTITION.put(cacheKey, pkceState, 300);
        return pkceState;
    }

    public static State get(String cacheKey) {
        return (State) PARTITION.get(cacheKey);
    }

    private static State generate() {
        HttpRequest pkceRequest = new HttpRequest();
        pkceRequest.setMethod('GET');
        pkceRequest.setEndpoint(String.format('{0}/{1}', Lists.of('${SF_INSTANCE_URL}', 'services/oauth2/pkce/generator')));
        HttpResponse pkceResponse = new Http().send(pkceRequest);
        return (State) JSON.deserialize(pkceResponse.getBody(), State.class);
    }

    private static State generateRandom() {
        PKCE.State randomState = new PKCE.State();
        randomState.code_challenge = TestDataFactory.generateRandomString(50);
        randomState.code_verifier = TestDataFactory.generateRandomString(50);
        return randomState;
    }

    public class State {
        public String code_challenge_method = 'S256';
        public String code_challenge = null; // e.g. JB7nT*************
        public String code_verifier = null; // e.g. GkLvw**************
    }
}
