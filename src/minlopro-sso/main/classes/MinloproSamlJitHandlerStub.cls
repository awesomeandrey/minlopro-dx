/**
 * Used as a stub Apex Class during pre-deployment stage.
 */
@SuppressWarnings('PMD')
global without sharing class MinloproSamlJitHandlerStub implements Auth.SamlJitHandler {
    global User createUser(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        this.raiseException();
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
        this.raiseException();
    }

    private void raiseException() {
        if (2 > 1) {
            throw new IllegalArgumentException(
                String.format(
                    '{0} is meant to be a temporary plug.',
                    new List<String>{ MinloproSamlJitHandlerStub.class.toString() }
                )
            );
        }
    }
}
