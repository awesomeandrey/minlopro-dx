public with sharing class digex_RunningUserInfoAsPdfController {
    public User currentUser { get; set; }
    public List<UserInfoItem> userInfoItems { get; set; }

    public digex_RunningUserInfoAsPdfController() {
        this.userInfoItems = new List<UserInfoItem>();
    }

    public void doLoadCurrentUserInfo() {
        this.currentUser = SystemInfoController.getUserInfoById(UserInfo.getUserId());
        List<String> userFieldNames = new List<String>{ 'Name', 'ProfileId', 'Email', 'Username', 'UserType' };
        for (String fieldName : userFieldNames) {
            this.userInfoItems.add(new UserInfoItem(fieldName, (String) this.currentUser.get(fieldName)));
        }
    }

    public class UserInfoItem {
        public String field { get; set; }
        public String value { get; set; }

        public UserInfoItem(String field, String value) {
            this.field = field;
            this.value = value;
        }
    }
}
