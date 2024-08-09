public inherited sharing class Application {
    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(
        new Map<Type, Type>{ Repository.class => SObjectRepository.class, OptInEmailService.class => OptInEmailService.class }
    );

    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
        new List<SObjectType>{
            ContentDocumentLink.SObjectType,
            ContentDistribution.SObjectType,
            ContentVersion.SObjectType,
            ContentWorkspace.SObjectType,
            ContentWorkspacePermission.SObjectType,
            Lead.SObjectType,
            User.SObjectType
        }
    );

    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type>{
            Account.SObjectType => AccountSelector.class,
            ContentDocument.SObjectType => ContentDocumentSelector.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinkSelector.class,
            ContentDistribution.SObjectType => ContentDistributionSelector.class,
            ContentVersion.SObjectType => ContentVersionSelector.class,
            ContentWorkspace.SObjectType => ContentWorkspaceSelector.class,
            ContentWorkspacePermission.SObjectType => ContentWorkspacePermissionSelector.class,
            EmailTemplate.SObjectType => EmailTemplateSelector.class,
            Lead.SObjectType => LeadSelector.class,
            User.SObjectType => UserSelector.class,
            ProcessInstance.SObjectType => ProcessInstanceSelector.class
        }
    );

    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Application.Selector,
        new Map<SObjectType, Type>{ User.SObjectType => Users.class }
    );
}
