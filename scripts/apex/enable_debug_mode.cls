Id runningUserId = UserInfo.getUserId();
Boolean enabled = [SELECT UserPreferencesUserDebugModePref FROM User WHERE Id = :runningUserId].UserPreferencesUserDebugModePref;
if (!enabled) {
    update new User(Id = runningUserId, UserPreferencesUserDebugModePref = true);
}
System.debug(
        String.format(
                '\n\n Successfully enabled Debug Mode for [{0}] user. \n',
                Lists.of(UserInfo.getName()))
);