/**
 * Used as a stub Apex Class during pre-deployment stage.
 */
global without sharing class AxiomSamlJitHandlerStub implements Auth.SamlJitHandler {
    global User createUser(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        return null;
    }

    global void updateUser(
        Id userId,
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
    }
}
