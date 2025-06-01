/**
 * Inspired by https://help.salesforce.com/s/articleView?id=000393553&type=1
 * and https://help.salesforce.com/s/articleView?id=sales.emailadmin_bounce_enable.htm&type=5
 */
public inherited sharing class TH_EmailMessage_Sample1 extends BasicTriggerHandler {
    private final EmailMessageSelector messageSelector = (EmailMessageSelector) Application.Selector.newInstance(
        EmailMessage.SObjectType
    );

    public override void afterInsert(List<SObject> newRecords) {
        Logger.debug('INSERTED {0} Email Message(s)', Lists.of(newRecords.size().toString()));
    }

    // For bounced email messages the DML runs on behalf of Automated Process user;
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Logger.debug('UPDATED {0} Email Message(s)', Lists.of(oldMap.size().toString()));
        List<Id> recordIds = Lists.of(newMap.keySet());
        List<EmailMessage> bouncedEmailMessages = this.messageSelector.selectBouncedByIds(recordIds);
        if (!bouncedEmailMessages.isEmpty()) {
            this.handleBouncedMessages(bouncedEmailMessages);
        }
    }

    private void handleBouncedMessages(List<EmailMessage> bouncedEmailMessages) {
        Logger.debug('Handling {0} bounced email message(s).', Lists.of(bouncedEmailMessages.size().toString()));
        Logger.debug(bouncedEmailMessages);
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Minlopro'
            LIMIT 1
        ];
        try {
            Map<EmailMessage, Task> taskByEmailMessageMap = this.messageSelector.selectWithTasksByIds(bouncedEmailMessages);
            for (EmailMessage bouncedMessage : taskByEmailMessageMap.keySet()) {
                Task messageTask = taskByEmailMessageMap.get(bouncedMessage);
                if (messageTask == null) {
                    continue;
                }
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Undelivered Email ⚠️');
                notification.setBody(
                    String.format(
                        'Your outbound email could not be delivered to [{0}] address.',
                        Lists.of(bouncedMessage.ToAddress)
                    )
                );
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(bouncedMessage.RelatedToId);
                notification.send(Sets.of(messageTask.OwnerId.toString()));
            }
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
