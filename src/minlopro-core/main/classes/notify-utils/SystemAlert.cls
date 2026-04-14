@SuppressWarnings('PMD')
public without sharing class SystemAlert {
    private static final ContentWorkspaceSelector workspaceSelector = (ContentWorkspaceSelector) Application.Selector.newInstance(
        ContentWorkspace.SObjectType
    );
    private static final String SYSTEM_ALERTS_WORKSPACE_NAME = 'Minlopro_SystemAlertLogs';
    private static ContentWorkspace SYSTEM_ALERTS_WORKSPACE {
        get {
            if (SYSTEM_ALERTS_WORKSPACE != null) {
                return SYSTEM_ALERTS_WORKSPACE;
            }
            List<ContentWorkspace> workspaces = workspaceSelector.selectByDeveloperNames(Lists.of(SYSTEM_ALERTS_WORKSPACE_NAME));
            SYSTEM_ALERTS_WORKSPACE = workspaces.isEmpty() ? null : workspaces[0];
            return SYSTEM_ALERTS_WORKSPACE;
        }
        set;
    }

    public static void send(SystemAlert.Builder alertBuilder) {
        Messaging.CustomNotification notification = alertBuilder.composeNotification();
        if (alertBuilder.saveAsFile) {
            ContentVersion logFile = saveLogAsFile(alertBuilder);
            String targetPageRef = JSON.serialize(
                new Map<String, Object>{
                    'type' => 'standard__namedPage',
                    'attributes' => new Map<String, String>{ 'pageName' => 'filePreview' },
                    'state' => new Map<String, String>{ 'recordIds' => logFile.ContentDocumentId }
                }
            );
            notification.setTargetPageRef(targetPageRef);
        }
        notification.send(alertBuilder.recipientIds);
    }

    private static ContentVersion saveLogAsFile(SystemAlert.Builder alertBuilder) {
        String fileName = String.format(
            '{0}_{1}',
            Lists.of(System.now().format('yyyy-MM-dd-HH:mm'), alertBuilder.title.replaceAll(' ', '-').abbreviate(50))
        );
        String logHeader = String.format(
            '{0} ••• {1}',
            Lists.of(UserInfo.getUserName(), System.now().format('yyyy-MM-dd HH:mm'))
        );
        ContentVersion logFile = new ContentVersion();
        logFile.ContentLocation = 'S'; // Document is located within Salesforce
        logFile.Description = alertBuilder.title;
        logFile.FirstPublishLocationId = SYSTEM_ALERTS_WORKSPACE.Id;
        logFile.PathOnClient = fileName + '.txt';
        logFile.Title = fileName;
        logFile.VersionData = Blob.valueOf(
            String.format('{0}\n\n{1}\n\n{2}', Lists.of(logHeader, alertBuilder.title, alertBuilder.body))
        );
        insert logFile;
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :logFile.Id LIMIT 1];
    }

    public class Builder {
        private String title;
        private String body;
        private Boolean saveAsFile = false;
        private Set<String> recipientIds;

        public Builder() {
            this.recipientIds = new Set<String>{ UserInfo.getUserId() };
            this.title = 'System Alert ✔️';
        }

        public Builder withTitle(String title) {
            this.title = title;
            return this;
        }

        public Builder withBody(String body) {
            this.body = body;
            return this;
        }

        public Builder withRecipients(Set<Id> recipientIds) {
            this.recipientIds = new Set<String>();
            for (Id userId : recipientIds) {
                this.recipientIds.add(String.valueOf(userId));
            }
            return this;
        }

        public Builder saveAsFile(Boolean flag) {
            this.saveAsFile = flag;
            return this;
        }

        private Messaging.CustomNotification composeNotification() {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(Constants.CustomNotificationsTypes.Minlopro.Id);
            notification.setTitle(this.title.abbreviate(250)); // Hard limit
            notification.setBody(this.body.abbreviate(750)); // Hard limit
            notification.setSenderId(UserInfo.getUserId());
            notification.setTargetId(UserInfo.getUserId()); // You can't send a custom notification without a navigation target
            return notification;
        }
    }

    // Note: method should be run in separate Apex transaction!
    public static void setupContentWorkspace() {
        if (SYSTEM_ALERTS_WORKSPACE != null) {
            Logger.debug('{0} workspace already exists.', Lists.of(SYSTEM_ALERTS_WORKSPACE_NAME));
            return;
        }
        ContentWorkspace workspaceFolder = new ContentWorkspace();
        workspaceFolder.Name = 'Minlopro - System Alert Logs';
        workspaceFolder.DeveloperName = SYSTEM_ALERTS_WORKSPACE_NAME;
        workspaceFolder.Description = 'Holds log files produced by ' + SystemAlert.class.getName() + ' apex class.';
        insert workspaceFolder;
        Logger.debug('{0} workspace has been created: {1}', Lists.of(SYSTEM_ALERTS_WORKSPACE_NAME, workspaceFolder.Id));
    }
}
