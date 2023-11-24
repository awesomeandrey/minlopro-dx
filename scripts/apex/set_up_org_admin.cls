Id runningUserId = UserInfo.getUserId();
User runningUser = [
        SELECT Name, UserPreferencesUserDebugModePref, Country
        FROM User
        WHERE Id = :runningUserId
        LIMIT 1
][0];
System.debug('\n\n Running User Info => ' + runningUser + '\n');
    update new User(
            Id = runningUserId,
            FirstName = 'Org',
            LastName = 'Admin',
            UserPreferencesUserDebugModePref = true,
            Country = 'United States'
    );
System.debug(
        String.format(
                '\n\n Successfully set up admin user. \n',
                Lists.of(UserInfo.getName()))
);