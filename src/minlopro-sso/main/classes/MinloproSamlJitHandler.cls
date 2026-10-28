global without sharing class MinloproSamlJitHandler implements Auth.SamlJitHandler {
    global User createUser(
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
        try {
            RuntimeContext ctx = new RuntimeContext()
                .withSamlSsoProviderId(samlSsoProviderId)
                .withCommunityId(communityId)
                .withPortalId(portalId)
                .withFederationIdentifier(federationIdentifier)
                .withAttributes(attributes)
                .withAssertion(assertion)
                .log();

            DigExPartnerUserBuilder userBuilder = new DigExPartnerUserBuilder(ctx).validate();

            Account userAccount = userBuilder.composeUserAccount();
            userAccount.Website = ctx.samlSsoProvider?.Issuer;
            insert userAccount;

            Contact userContact = userBuilder.composeUserContact(userAccount.Id);
            insert userContact;

            User digExPartnerUser = userBuilder.composeUser(userContact.Id);
            insert digExPartnerUser;

            Logger.debug('New user => {0}', Lists.of(JSON.serialize(digExPartnerUser)));
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
        try {
            RuntimeContext ctx = new RuntimeContext()
                .withUserId(userId)
                .withSamlSsoProviderId(samlSsoProviderId)
                .withCommunityId(communityId)
                .withPortalId(portalId)
                .withFederationIdentifier(federationIdentifier)
                .withAttributes(attributes)
                .withAssertion(assertion)
                .log();

            DigExPartnerUserBuilder userBuilder = new DigExPartnerUserBuilder(ctx).validate();

            /**
            * Code below fails with MIXED_DML_OPERARION
            *
            Account userAccount = userBuilder.composeUserAccount();
            userAccount.Id = ctx.user.AccountId;
            update userAccount;

            Contact userContact = userBuilder.composeUserContact(userAccount.Id);
            userContact.Id = ctx.user.ContactId;
            update userContact;
            */

            User digExPartnerUser = userBuilder.composeUser(ctx.user.ContactId);
            digExPartnerUser.Id = ctx.user.Id;
            if (!Test.isRunningTest()) {
                update digExPartnerUser;
            }

            Logger.debug('Old user title = {0} VS new title = {1}', Lists.of(ctx.user.Title, digExPartnerUser.Title));
        } catch (Exception ex) {
            Logger.error(ex);
            throw new IllegalArgumentException(ex);
        }
    }

    public without sharing class RuntimeContext {
        public User user { get; private set; }
        public SamlSsoConfig samlSsoProvider { get; private set; }
        public Network community { get; private set; }
        public Id portalId { get; private set; }
        public String federationIdentifier { get; private set; }
        public Map<String, String> attributes { private get; private set; }
        public String assertion { private get; private set; }

        public RuntimeContext() {
        }

        public RuntimeContext withUserId(Id userId) {
            this.user = [SELECT Name, Username, AccountId, ContactId, Title FROM User WHERE Id = :userId];
            return this;
        }

        public RuntimeContext withSamlSsoProviderId(Id samlSsoProviderId) {
            // The ID of the SamlSsoConfig standard object
            List<SamlSsoConfig> configs = [
                SELECT MasterLabel, DeveloperName, IdentityLocation, IdentityMapping, Issuer
                FROM SamlSsoConfig
                WHERE Id = :samlSsoProviderId
                LIMIT 1
            ];
            this.samlSsoProvider = configs.isEmpty() ? null : configs[0];
            return this;
        }

        public RuntimeContext withCommunityId(Id communityId) {
            // The ID of the Experience Cloud site. This parameter can be null if you’re not creating an Experience Cloud user.
            List<Network> communities = [SELECT Name, Description FROM Network WHERE Id = :communityId LIMIT 1];
            this.community = communities.isEmpty() ? null : communities[0];
            return this;
        }

        public RuntimeContext withPortalId(Id portalId) {
            // The ID of the portal. This parameter can be null if you’re not creating a portal user.
            this.portalId = portalId;
            return this;
        }

        public RuntimeContext withFederationIdentifier(String federationIdentifier) {
            this.federationIdentifier = federationIdentifier;
            return this;
        }

        public RuntimeContext withAttributes(Map<String, String> attributes) {
            // All attributes in the SAML assertion that were added to the default assertion
            this.attributes = attributes.clone();
            return this;
        }

        public RuntimeContext withAssertion(String assertion) {
            // The default SAML assertion, base-64 encoded
            this.assertion = assertion;
            return this;
        }

        public RuntimeContext log() {
            Logger.debug(
                new Map<String, Object>{
                    'user' => this.user,
                    'samlSsoProvider' => this.samlSsoProvider,
                    'communityId' => this.community,
                    'portalId' => this.portalId,
                    'federationIdentifier' => this.federationIdentifier,
                    'attributes' => this.attributes,
                    'assertion' => this.assertion?.abbreviate(25)
                }
            );
            return this;
        }

        public String getAttribute(String key) {
            return this.attributes?.get(key);
        }
    }

    public without sharing class DigExPartnerUserBuilder {
        private final User user;

        public DigExPartnerUserBuilder(RuntimeContext ctx) {
            this.user = new User();
            this.user.Profile = new Profile(Name = 'DigEx Partner');
            this.user.IsActive = true;
            this.user.Department = String.format('Origin = {0}', Lists.of(ctx.samlSsoProvider.MasterLabel));
            this.withFirstName(ctx.getAttribute('User.FirstName'))
                .withFirstName(ctx.getAttribute('FirstName'))
                .withFirstName(ctx.getAttribute('firstName'))
                .withLastName(ctx.getAttribute('User.LastName'))
                .withLastName(ctx.getAttribute('LastName'))
                .withLastName(ctx.getAttribute('lastName'))
                .withEmail(ctx.getAttribute('User.Email'))
                .withEmail(ctx.getAttribute('Email'))
                .withEmail(ctx.getAttribute('email'))
                .withFederationIdentifier(ctx.federationIdentifier);
        }

        public DigExPartnerUserBuilder withFirstName(String firstName) {
            if (String.isNotBlank(firstName))
                this.user.FirstName = firstName.toLowerCase().capitalize();
            return this;
        }

        public DigExPartnerUserBuilder withLastName(String lastName) {
            if (String.isNotBlank(lastName))
                this.user.LastName = lastName.toLowerCase().capitalize();
            return this;
        }

        public DigExPartnerUserBuilder withFederationIdentifier(String federationIdentifier) {
            this.user.FederationIdentifier = federationIdentifier;
            return this;
        }

        public DigExPartnerUserBuilder withEmail(String email) {
            if (String.isNotBlank(email) && email.containsIgnoreCase('@'))
                this.user.Email = email;
            return this;
        }

        public DigExPartnerUserBuilder validate() {
            List<Schema.SObjectField> mandatoryFields = new List<Schema.SObjectField>{
                Schema.User.FirstName,
                Schema.User.LastName,
                Schema.User.Email
            };
            for (Schema.SObjectField field : mandatoryFields) {
                if (this.user.get(field) == null) {
                    throw new IllegalArgumentException(
                        String.format('Missing required field: [{0}]', Lists.of(field.getDescribe().getName()))
                    );
                }
            }
            return this;
        }

        public Account composeUserAccount() {
            return new Account(
                Name = String.format(
                    '{0} {1} ({2})',
                    Lists.of(this.user.FirstName, this.user.LastName, this.user.FederationIdentifier)
                )
            );
        }

        public Contact composeUserContact(Id accountId) {
            return new Contact(
                AccountId = accountId,
                FirstName = this.user.FirstName,
                LastName = this.user.LastName,
                Email = this.user.Email
            );
        }

        public User composeUser(Id contactId) {
            this.user.ContactId = contactId;
            // Computed fields
            this.user.Username = String.format(
                '{0}{1}@partner.digex.edu',
                Lists.of(this.user.FirstName.toLowerCase(), this.user.LastName.toLowerCase())
            );
            this.user.CommunityNickname = this.user.Username;
            this.user.Alias = (this.user.FirstName + '.' + this.user.LastName).toLowerCase().substring(0, 8);
            this.user.Title = String.format(
                '{0} {1} {2} {3}',
                new List<Object>{
                    Lists.getRandomString(Lists.of('Software Developer', 'Solution Engineer', 'Project Manager')),
                    Lists.getRandomString(Lists.of('😊', '😨', '😜')),
                    Lists.getRandomString(Lists.of('⬅️', '⬆️', '➡️')),
                    Lists.getRandomString(Lists.of('♌', '✴️', '🆎'))
                }
            );
            // Derive from transaction user
            this.user.TimeZoneSidKey = UserInfo.getTimeZone().getID();
            this.user.LocaleSidKey = UserInfo.getLocale();
            this.user.EmailEncodingKey = 'UTF-8';
            this.user.LanguageLocaleKey = UserInfo.getLanguage();
            return this.user;
        }
    }
}
