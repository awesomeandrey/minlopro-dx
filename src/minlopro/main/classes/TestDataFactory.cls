public class TestDataFactory {
    private final static Integer USERNAME_LENGTH = 10;

    public static String generateRandomString(Integer stringLength) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < stringLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
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
}
