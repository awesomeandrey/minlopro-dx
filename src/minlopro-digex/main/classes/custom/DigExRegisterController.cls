public without sharing class DigExRegisterController {
    @AuraEnabled
    public static User register(String firstname, String lastname, String userEmail) {
        Savepoint sp = Database.setSavepoint();
        try {
            Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
            if (!isGuestUser) {
                throw new IllegalArgumentException('The user is already logged in!');
            }

            // Set experience ID;
            Network digEx = [SELECT Id FROM Network WHERE Name = 'DigEx' LIMIT 1];
            Logger.debug('DigEx ID = {0}', Lists.of(digEx.Id));
            Site.setExperienceId(digEx.Id);

            // Compose valid user definition;
            User digExUser = new User();
            digExUser.Username = userEmail;
            digExUser.Email = userEmail;
            digExUser.FirstName = firstname;
            digExUser.LastName = lastname;
            digExUser.CommunityNickname = generateCommunityNickname(digExUser);

            /**
             * Create portal user (make sure 'without sharing' modifier is enforced
             * in order to query User record(s) on behalf of Guest user).
             */
            String userId = Site.createPersonAccountPortalUser(digExUser, Site.getAdminId(), null);
            Logger.debug('User ID = {0}', Lists.of(userId)); // The user is assigned Person Account record type;
            digExUser = [
                SELECT
                    Id,
                    Username,
                    Name,
                    Email,
                    CommunityNickname,
                    Profile.Name,
                    Account.Name,
                    Account.RecordType.Name,
                    Contact.Name,
                    IsPortalEnabled
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
            Logger.debug(JSON.serialize(digExUser));

            Database.rollback(sp);

            return digExUser;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String generateCommunityNickname(User digExUser) {
        return String.format(
                '{0}{1}{2}',
                Lists.of(
                    digExUser.FirstName.substring(0, 1),
                    digExUser.LastName.substring(0, 1),
                    String.valueOf(Crypto.getRandomInteger()).substring(1, 7)
                )
            )
            .trim();
    }
}
