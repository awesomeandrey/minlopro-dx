// TODO - learn;
global class MinloproRegistrationHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        Logger.debug(data.toString());
        return new User(Id = UserInfo.getUserId());
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        Logger.debug(data.toString());
    }
}
