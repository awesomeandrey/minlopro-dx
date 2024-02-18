public inherited sharing class Application {
    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(
        new Map<Type, Type>{ Repository.class => SObjectRepository.class }
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
            ContentDocument.SObjectType => ContentDocumentSelector.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinkSelector.class,
            ContentDistribution.SObjectType => ContentDistributionSelector.class,
            ContentWorkspace.SObjectType => ContentWorkspaceSelector.class,
            ContentWorkspacePermission.SObjectType => ContentWorkspacePermissionSelector.class,
            Lead.SObjectType => LeadSelector.class,
            User.SObjectType => UserSelector.class
        }
    );

    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Application.Selector,
        new Map<SObjectType, Type>{ User.SObjectType => Users.class }
    );
}
