public inherited sharing class EmailMessageSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

    public SObjectType getSObjectType() {
        return EmailMessage.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            EmailMessage.ActivityId, // Lookup to Task record (generated behind the scenes)
            EmailMessage.EmailTemplateId,
            EmailMessage.FromAddress,
            EmailMessage.FromId,
            EmailMessage.FromName,
            EmailMessage.Incoming,
            EmailMessage.Id,
            EmailMessage.IsBounced,
            EmailMessage.IsClientManaged,
            EmailMessage.IsExternallyVisible,
            EmailMessage.IsOpened,
            EmailMessage.IsTracked,
            EmailMessage.Name,
            EmailMessage.RelatedToId,
            EmailMessage.Status,
            EmailMessage.Subject,
            EmailMessage.ParentId,
            EmailMessage.ToAddress,
            EmailMessage.TextBody
        };
    }

    public List<EmailMessage> selectBouncedByIds(List<Id> recordIds) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, false, true);
        queryFactory.setCondition('Id IN :recordIds AND IsBounced = TRUE');
        return this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'recordIds' => recordIds },
            System.AccessLevel.SYSTEM_MODE
        );
    }

    public Map<EmailMessage, Task> selectWithTasksByIds(List<EmailMessage> records) {
        List<Id> recordIds = Lists.of(new Map<Id, EmailMessage>(records).keySet());
        return this.selectWithTasksByIds(recordIds);
    }

    public Map<EmailMessage, Task> selectWithTasksByIds(List<Id> recordIds) {
        List<EmailMessage> messagesWithActivity = this.selectSObjectsById(Sets.of(recordIds));
        List<Id> activityIds = new List<Id>();
        for (EmailMessage message : messagesWithActivity) {
            if (String.isNotBlank(message.ActivityId)) {
                activityIds.add(message.ActivityId);
            }
        }
        Map<EmailMessage, Task> resultMap = new Map<EmailMessage, Task>();
        if (activityIds.isEmpty()) {
            return resultMap;
        }
        Map<Id, Task> tasksMap = new Map<Id, Task>([SELECT Id, Owner.Name FROM Task WHERE Id IN :activityIds]);
        for (EmailMessage message : messagesWithActivity) {
            resultMap.put(message, tasksMap.get(message?.ActivityId));
        }
        return resultMap;
    }
}
