public with sharing class digex_RunningUserInfoAsPdfController {
    public User currentUser { get; set; }
    public List<UserInfoItem> userInfoItems { get; set; }

    public digex_RunningUserInfoAsPdfController() {
        this.userInfoItems = new List<UserInfoItem>();

        // Specify the name for the PDF file generated;
        ApexPages.currentPage().getHeaders().put('Content-Disposition', 'inline; filename=Minlopro DigEx User Info (VF).pdf');
    }

    public void doLoadCurrentUserInfo() {
        this.currentUser = SystemInfoController.getUserInfoById(UserInfo.getUserId());
        Map<String, Object> fieldsAsMap = this.currentUser.getPopulatedFieldsAsMap();
        for (String fieldName : fieldsAsMap.keySet()) {
            Object fieldValue = fieldsAsMap.get(fieldName);
            if (fieldValue != null) {
                this.userInfoItems.add(new UserInfoItem(fieldName, fieldValue.toString()));
            }
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
