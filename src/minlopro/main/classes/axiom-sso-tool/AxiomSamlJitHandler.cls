/**
 * This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
 */
global without sharing class AxiomSamlJitHandler implements Auth.SamlJitHandler {
    public static String CLAIM_FIRSTNAME = 'User.FirstName';
    public static String CLAIM_LASTNAME = 'User.LastName';
    public static Profile DIGEX_PARTNER_PROFILE {
        get {
            if (DIGEX_PARTNER_PROFILE == null) {
                DIGEX_PARTNER_PROFILE = [SELECT Id FROM Profile WHERE Name = 'DigEx Partner' LIMIT 1][0];
            }
            return DIGEX_PARTNER_PROFILE;
        }
        private set;
    }

    global User createUser(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        Logger.debug(
            this.collectParams(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion).toString()
        );
        try {
            // 'FederationIdentifier' must be passed within SAML request;
            if (String.isBlank(federationIdentifier)) {
                throw new IllegalArgumentException('Federation Identifier must be defined!');
            }

            // Extract mandatory SAML attributes;
            final String firstName = attributes?.get(CLAIM_FIRSTNAME);
            final String lastName = attributes?.get(CLAIM_LASTNAME);
            if (String.isBlank(firstName) || String.isBlank(lastName)) {
                throw new IllegalArgumentException('FirstName and LastName SAML attributes must be defined!');
            }

            // Generate the rest;
            final String usernameOrEmail = String.format('{0}@{1}', Lists.of(federationIdentifier, 'minlopro.digex.edu'));
            final String alias = federationIdentifier.substring(0, 5);

            // Create new Account;
            Account userAccount = new Account(
                Name = String.format('{0} {1} ({2})', Lists.of(firstName, lastName, federationIdentifier))
            );
            insert userAccount;

            // Create the Contact;
            Contact userContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = usernameOrEmail,
                AccountId = userAccount.Id
            );
            insert userContact;

            // Create brand new User for DigEx experience site;
            User digExPartnerUser = this.cloneAdminUser();
            digExPartnerUser.ProfileId = DIGEX_PARTNER_PROFILE.Id;
            digExPartnerUser.ContactId = userContact.Id;
            digExPartnerUser.FirstName = firstName;
            digExPartnerUser.LastName = lastName;
            digExPartnerUser.Username = usernameOrEmail;
            digExPartnerUser.Alias = alias;
            digExPartnerUser.Email = usernameOrEmail;
            digExPartnerUser.FederationIdentifier = federationIdentifier;
            digExPartnerUser.IsActive = true;

            insert digExPartnerUser;

            digExPartnerUser = [
                SELECT
                    Id,
                    Name,
                    UserType,
                    AccountId,
                    ContactId,
                    Username,
                    Profile.Name,
                    Profile.UserLicense.Name,
                    FederationIdentifier
                FROM User
                WHERE Id = :digExPartnerUser.Id
                LIMIT 1
            ];
            Logger.debug('Newly created DigEx user: {0}', Lists.of(digExPartnerUser));

            /**
             * Set up access. This should be done in separate transaction to avoid the error below:
             * `MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): PermissionSetAssignment`
             */
            PermissionSetService psService = PermissionSetService.getInstance().enforceAllOrNothing(true);
            psService.assignAsync(digExPartnerUser.Id, Sets.of('Minlopro_PSG_DigExUser'));

            return digExPartnerUser;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new IllegalArgumentException(ex);
        }
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
        Logger.debug(
            this.collectParams(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion).toString()
        );
    }

    private Map<String, String> collectParams(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        return new Map<String, String>{
            'samlSsoProviderId' => samlSsoProviderId,
            'communityId' => communityId,
            'portalId' => portalId,
            'federationIdentifier' => federationIdentifier,
            'attributes' => JSON.serialize(attributes),
            'assertion' => assertion?.abbreviate(25)
        };
    }

    private User cloneAdminUser() {
        User adminUser = [
            SELECT EmailEncodingKey, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return adminUser.clone(false, true);
    }
}
