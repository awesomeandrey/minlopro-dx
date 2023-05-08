Id runningUserId = UserInfo.getUserId();
User runningUser = [SELECT UserPreferencesUserDebugModePref, Country, CountryCode FROM User WHERE Id = :runningUserId LIMIT 1][0];
System.debug('\n\n Running User Info => ' + runningUser + '\n');
Boolean enabled = runningUser.UserPreferencesUserDebugModePref;
if (!enabled) {
    update new User(Id = runningUserId, UserPreferencesUserDebugModePref = true);
}
System.debug(
        String.format(
                '\n\n Successfully enabled Debug Mode for [{0}] user. \n',
                Lists.of(UserInfo.getName()))
);