Id runningUserId = UserInfo.getUserId();
System.debug('\n\n runningUserId => ' + runningUserId + '\n');
Boolean enabled = [SELECT UserPreferencesUserDebugModePref FROM User WHERE Id = :runningUserId].UserPreferencesUserDebugModePref;
if (!enabled) {
    update new User(Id = runningUserId, UserPreferencesUserDebugModePref = true);
}