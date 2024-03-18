/**
 * This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
 */
global without sharing class AxiomSamlJitHandler implements Auth.SamlJitHandler {
    global User createUser(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        // Create brand new User;
        return new User();
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
        // Update existing user by `userId` parameter;
        User existingUser = [SELECT Id FROM User WHERE Id = :userId];
    }
}
