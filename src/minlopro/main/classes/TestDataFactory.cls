public class TestDataFactory {
    // Testing SFDX Replacements: '@SF_USERNAME' < should contain integration user username!

    public final static CurrencyType CORPORATE_CURRENCY_TYPE {
        get {
            for (CurrencyType cType : CURRENCY_TYPES_BY_CODE.values()) {
                if (cType.IsCorporate) {
                    return cType;
                }
            }
            return null;
        }
    }

    private final static Integer USERNAME_LENGTH = 10;
    private final static Map<String, Profile> ORG_PROFILES_BY_NAME = new Map<String, Profile>();
    private final static Map<String, CurrencyType> CURRENCY_TYPES_BY_CODE = new Map<String, CurrencyType>();

    static {
        // Select org profiles;
        for (Profile profileRecord : [SELECT Id, Name FROM Profile]) {
            ORG_PROFILES_BY_NAME.put(profileRecord.Name, profileRecord);
        }
        // Select currency types;
        for (CurrencyType cType : [SELECT IsoCode, ConversionRate, IsCorporate, DecimalPlaces, IsActive FROM CurrencyType]) {
            CURRENCY_TYPES_BY_CODE.put(cType.IsoCode, cType);
        }
    }

    // User Provisioning;

    public static User createAdmin() {
        Profile adminProfile = TestDataFactory.selectSystemAdminProfile();
        return TestDataFactory.createUser('Admin', 'Minlopro', adminProfile.Id);
    }

    public static User createUser(String firstName, String lastName, Id profileId) {
        String username = generateRandomString(USERNAME_LENGTH);
        String orgId = UserInfo.getOrganizationId();
        User u = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = username + '@test' + orgId + '.com',
            Username = username + '@test' + orgId + '.com',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = username.substring(0, USERNAME_LENGTH / 2),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId,
            Street = '12345 Test Street',
            MobilePhone = '9999999999',
            Phone = '9999999999'
        );
        return u;
    }

    // Records/Data Generation;

    public static List<Account> createAccounts(Integer numOfAccounts) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numOfAccounts; i++) {
            accounts.add(new Account(Name = 'Test #' + i, AnnualRevenue = 0));
        }
        return accounts;
    }

    public static List<Contact> createContacts(Integer numOfContacts) {
        return createContacts(numOfContacts, null);
    }

    public static List<Contact> createContacts(Integer numOfContacts, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numOfContacts; i++) {
            contacts.add(
                new Contact(
                    AccountId = accountId,
                    FirstName = 'TestFirstName' + i,
                    LastName = 'TestLastName' + i,
                    Email = 'test' + i + '@example.com',
                    Phone = '777-' + i,
                    MobilePhone = '1234567890'
                )
            );
        }
        return contacts;
    }

    public static List<Opportunity> createOpportunities(Integer numOfOpps, Id accountId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < numOfOpps; i++) {
            opportunities.add(
                new Opportunity(
                    Name = 'Test Opportunity #' + i,
                    StageName = 'Closed Won',
                    CloseDate = Date.today(),
                    Amount = 1000,
                    AccountId = accountId,
                    CurrencyIsoCode = CORPORATE_CURRENCY_TYPE.IsoCode
                )
            );
        }
        return opportunities;
    }

    public static List<Lead> createLeads(Integer numOfLeads) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < numOfLeads; i++) {
            leads.add(
                new Lead(
                    Company = 'Company #' + i,
                    AnnualRevenue = 100 * Math.random(),
                    Email = 'lead_' + i + '@edu.com',
                    GenderIdentity = 'Male',
                    LeadSource = 'Web',
                    Status = 'New',
                    FirstName = 'FN #' + i,
                    LastName = 'LN #' + i,
                    Title = 'Test Lead Data',
                    Phone = '750-224-9149' + i,
                    MobilePhone = '750-224-9149' + i
                )
            );
        }
        return leads;
    }

    // Utility Methods;

    public static Profile selectSystemAdminProfile() {
        return ORG_PROFILES_BY_NAME.get('System Administrator');
    }

    public static Profile selectMinloproUserProfile() {
        return ORG_PROFILES_BY_NAME.get('Minlopro User');
    }

    public static String generateRandomString(Integer stringLength) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < stringLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
}
