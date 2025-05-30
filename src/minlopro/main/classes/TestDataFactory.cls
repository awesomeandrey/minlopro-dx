public class TestDataFactory {
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

    private final static Map<String, Profile> PROFILES_BY_NAME = new Map<String, Profile>();
    private final static Map<String, CurrencyType> CURRENCY_TYPES_BY_CODE = new Map<String, CurrencyType>();
    private final static Map<TestDataFactory.PublicGroup, Group> PUBLIC_GROUPS_BY_NAME = new Map<TestDataFactory.PublicGroup, Group>();
    private final static Map<TestDataFactory.Role, UserRole> ROLES_BY_NAME = new Map<TestDataFactory.Role, UserRole>();

    static {
        // Select org profiles;
        for (Profile profileRecord : [SELECT Id, Name FROM Profile]) {
            PROFILES_BY_NAME.put(profileRecord.Name, profileRecord);
        }
        // Select currency types;
        for (CurrencyType cType : [
            SELECT IsoCode, ConversionRate, IsCorporate, DecimalPlaces, IsActive
            FROM CurrencyType
            WHERE IsActive = TRUE
        ]) {
            CURRENCY_TYPES_BY_CODE.put(cType.IsoCode, cType);
        }
        // Select public groups;
        List<String> groupNames = new List<String>{ PublicGroup.OrgAdmins.name(), PublicGroup.OrgUsers.name() };
        for (Group groupItem : [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName IN :groupNames]) {
            PUBLIC_GROUPS_BY_NAME.put(PublicGroup.valueOf(groupItem.DeveloperName), groupItem);
        }
        // Select roles;
        List<String> roleNames = new List<String>{ Role.DX_Admin.name() };
        for (UserRole userRoleItem : [SELECT Id, DeveloperName, Name FROM UserRole WHERE DeveloperName IN :roleNames]) {
            ROLES_BY_NAME.put(Role.valueOf(userRoleItem.DeveloperName), userRoleItem);
        }
    }

    // User Provisioning;

    public static User createAdmin() {
        User adminUser = TestDataFactory.createUser('Admin', 'Minlopro', 'System Administrator');
        // Assign Role;
        adminUser.UserRoleId = ROLES_BY_NAME.get(Role.DX_Admin).Id;
        // Create user;
        insert adminUser;
        // Add the user to the corresponding Public Group;
        insert new GroupMember(UserOrGroupId = adminUser.Id, GroupId = PUBLIC_GROUPS_BY_NAME.get(PublicGroup.OrgAdmins).Id);
        // Assign PSG to the user;
        PermissionSetService.getInstance()
            .enforceAllOrNothing(false)
            .assign(
                adminUser.Id,
                new Set<String>{ PermissionSetOrPSG.Minlopro_PSG_InternalUser.name(), PermissionSetOrPSG.Minlopro_Admin.name() }
            );
        // Log info about user;
        new DebugTableFormatter(
                Lists.of('Name', 'Profile.Name', 'Profile.UserLicense.Name'),
                [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE Id = :adminUser.Id]
            )
            .log('> Test Admin User');
        return (User) selectAllFieldsById(User.SObjectType, adminUser.Id);
    }

    public static User createRegularUser() {
        String randomUsername = generateRandomString(8);
        User regularUser = TestDataFactory.createUser('Mike', 'Green-' + randomUsername, 'Minlopro User');
        // Assign Role;
        regularUser.UserRoleId = null;
        // Create user;
        insert regularUser;
        // Add the user to the corresponding Public Group;
        insert new GroupMember(UserOrGroupId = regularUser.Id, GroupId = PUBLIC_GROUPS_BY_NAME.get(PublicGroup.OrgUsers).Id);
        // Assign PSG to the user;
        PermissionSetService.getInstance()
            .enforceAllOrNothing(false)
            .assign(regularUser.Id, new Set<String>{ PermissionSetOrPSG.Minlopro_PSG_InternalUser.name() });
        // Log info about user;
        new DebugTableFormatter(
                Lists.of('Name', 'Profile.Name', 'Profile.UserLicense.Name'),
                [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE Id = :regularUser.Id]
            )
            .log('> Test Regular User');
        return (User) selectAllFieldsById(User.SObjectType, regularUser.Id);
    }

    public static User createUser(String firstName, String lastName, String profileName) {
        final Integer USERNAME_LENGTH = 5;
        String username = generateRandomString(USERNAME_LENGTH);
        String orgId = UserInfo.getOrganizationId();
        return new User(
            Alias = username.substring(0, USERNAME_LENGTH / 2),
            Email = username + '@test' + orgId + '.com',
            EmailEncodingKey = 'ISO-8859-1',
            FirstName = firstName,
            LanguageLocaleKey = 'en_US',
            LastName = lastName,
            LocaleSidKey = 'en_US',
            MobilePhone = generateRandomPhone(),
            Phone = generateRandomPhone(),
            Profile = new Profile(Name = profileName), // named lookup population;
            Street = '12345 Test Street',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = username + '@test' + orgId + '.com'
        );
    }

    // Records/Data Generation;

    public static List<Account> createAccounts(Integer numOfAccounts) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numOfAccounts; i++) {
            accounts.add(
                new Account(
                    Name = 'Test #' + i,
                    AnnualRevenue = generateRandomDecimal(),
                    Description = generateRandomString(100),
                    Industry = Lists.getRandomString(Lists.of('Telecommunications', 'Agriculture', 'Banking')),
                    Phone = generateRandomPhone(),
                    Website = generateRandomWebsite()
                )
            );
        }
        return accounts;
    }

    public static List<Account> createPersonAccounts(Integer numOfAccounts) {
        List<Account> customerAccounts = new List<Account>();
        RecordType personRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = TRUE LIMIT 1];
        for (Integer i = 0; i < numOfAccounts; i++) {
            Account customer = new Account();
            customer.RecordTypeId = personRecordType.Id;
            customer.PersonTitle = Lists.getRandomString(Lists.of('Sr. Surgeon', 'Top Banker', 'DevOps'));
            customer.FirstName = String.format('F{0}-{1}', Lists.of(i.toString(), TestDataFactory.generateRandomString(5)));
            customer.LastName = String.format('L{0}-{1}', Lists.of(i.toString(), TestDataFactory.generateRandomString(5)));
            customer.PersonEmail = String.format('{0}@apex.test', Lists.of(customer.LastName));
            customer.PersonHasOptedOutOfEmail = false;
            customer.Industry = Lists.getRandomString(Lists.of('Healthcare', 'Finance', 'Technology'));
            customer.Site = generateRandomWebsite();
            customer.Type = Lists.getRandomString(Lists.of('Partner', 'Customer'));
            customer.Phone = generateRandomPhone();
            customerAccounts.add(customer);
        }
        return customerAccounts;
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
                    Phone = generateRandomPhone(),
                    MobilePhone = generateRandomPhone(),
                    Description = generateRandomString(100)
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
                    CloseDate = Date.today().addDays(3),
                    Amount = generateRandomDecimal(),
                    AccountId = accountId,
                    CurrencyIsoCode = CORPORATE_CURRENCY_TYPE.IsoCode,
                    Description = generateRandomString(100)
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
                    GenderIdentity = Lists.getRandomString(Lists.of('Male', 'Female')),
                    LeadSource = Lists.getRandomString(Lists.of('Web', 'Partner')),
                    Status = 'New',
                    FirstName = 'FN #' + i,
                    LastName = 'LN #' + i,
                    Title = 'Test Lead Data',
                    Phone = generateRandomPhone(),
                    MobilePhone = generateRandomPhone(),
                    Description = generateRandomString(100),
                    Products__c = String.format(
                        '{0}; {1}',
                        Lists.of(
                            Lists.getRandomString(Lists.of('Auto', 'Home')),
                            Lists.getRandomString(Lists.of('Life', 'Umbrella'))
                        )
                    )
                )
            );
        }
        return leads;
    }

    // Utility Methods;

    public static Profile selectSystemAdminProfile() {
        return PROFILES_BY_NAME.get('System Administrator');
    }

    public static Profile selectMinloproUserProfile() {
        return PROFILES_BY_NAME.get('Minlopro User');
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

    public static Decimal generateRandomDecimal() {
        return generateRandomDecimal(150, 20000);
    }

    public static Decimal generateRandomDecimal(Integer min, Integer max) {
        // Generate a random integer between min and max
        Integer randomInt = Math.round(Math.random() * (max - min) + min);
        // Convert to Decimal
        return Decimal.valueOf(randomInt);
    }

    public static String generateRandomPhone() {
        Decimal randomDigits = TestDataFactory.generateRandomDecimal(300, 900);
        return String.format(
            '{0}-{1}-{2}',
            Lists.of(randomDigits.toString(), (randomDigits + 51).toString(), (randomDigits - 51).toString())
        );
    }

    public static String generateRandomWebsite() {
        String siteName = generateRandomString(5);
        String siteDomain = Lists.getRandomString(Lists.of('com', 'me', 'io'));
        return String.format('https://apextest.{0}.{1}', Lists.of(siteName, siteDomain));
    }

    private static SObject selectAllFieldsById(SObjectType objType, Id recordId) {
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        List<String> readableFieldNames = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if (fieldDescribe.isAccessible()) {
                readableFieldNames.add(fieldName);
            }
        }
        return Database.query(
            String.format(
                'SELECT {0} FROM {1} WHERE Id = :recordId LIMIT 1',
                new List<String>{ String.join(readableFieldNames, ','), objType.toString() }
            )
        );
    }

    public enum PublicGroup {
        OrgAdmins,
        OrgUsers
    }

    public enum Role {
        DX_Admin
    }

    public enum PermissionSetOrPSG {
        Minlopro_PSG_InternalUser,
        Minlopro_Admin
    }
}
