public with sharing class FilesManagementController {
    private static final String FOLDER_NAME = 'Minlopro_SampleFiles';
    private static final ContentDocumentSelector documentSelector = (ContentDocumentSelector) Application.Selector.newInstance(
        ContentDocument.SObjectType
    );
    private static final ContentDocumentLinkSelector documentLinkSelector = (ContentDocumentLinkSelector) Application.Selector.newInstance(
        ContentDocumentLink.SObjectType
    );
    private static final ContentDistributionSelector documentDistributionSelector = (ContentDistributionSelector) Application.Selector.newInstance(
        ContentDistribution.SObjectType
    );
    private static final ContentWorkspaceSelector workspaceSelector = (ContentWorkspaceSelector) Application.Selector.newInstance(
        ContentWorkspace.SObjectType
    );
    private static final ContentWorkspacePermissionSelector workspacePermissionSelector = (ContentWorkspacePermissionSelector) Application.Selector.newInstance(
        ContentWorkspacePermission.SObjectType
    );

    @AuraEnabled
    public static ContentWorkspace queryOrCreateFolderIfNotExists() {
        try {
            List<ContentWorkspace> existingWorkspaceFolders = workspaceSelector.selectByDeveloperNames(Lists.of(FOLDER_NAME));
            if (existingWorkspaceFolders.isEmpty()) {
                Logger.debug('Creating new workspace folder...');
                // Create new folder;
                ContentWorkspace workspaceFolder = new ContentWorkspace();
                workspaceFolder.Name = 'Minlopro - Sample Files';
                workspaceFolder.DeveloperName = FOLDER_NAME;
                workspaceFolder.Description = 'Folder with sample files.';
                // Update 'Admin' permission/role by enabling content delivery'
                // https://salesforce.stackexchange.com/questions/312172/content-distribution-records-are-not-getting-created
                final String adminPermissionType = 'Admin';
                ContentWorkspacePermission adminPermission = workspacePermissionSelector.selectByType(adminPermissionType)[0];
                Logger.debug('Found workspace admin permission: {0}', Lists.of(JSON.serialize(adminPermission)));
                adminPermission.PermissionsDeliverContent = true;
                // Commit the changes;
                fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                uow.registerNew(workspaceFolder);
                uow.registerUpsert(adminPermission);
                uow.commitWork();
                return ((List<ContentWorkspace>) workspaceSelector.selectSObjectsById(Sets.of(workspaceFolder.Id)))[0];
            } else {
                return existingWorkspaceFolders[0];
            }
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getFilesByOwnerId(Id ownerId) {
        try {
            return documentSelector.selectByOwnerIds(Lists.of(ownerId));
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContentDocumentLink> addFilesToFolder(List<Id> contentDocumentIds) {
        try {
            ContentWorkspace workspaceFolder = queryOrCreateFolderIfNotExists();
            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            for (Id documentId : contentDocumentIds) {
                linksToInsert.add(new ContentDocumentLink(ContentDocumentId = documentId, LinkedEntityId = workspaceFolder.Id));
            }
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(linksToInsert);
            uow.commitWork();
            return documentLinkSelector.selectSObjectsById(new Map<Id, ContentDocumentLink>(linksToInsert).keySet());
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteFilesByIds(List<Id> contentDocumentIds) {
        try {
            List<ContentDocument> documents = (List<ContentDocument>) documentSelector.selectSObjectsById(
                Sets.of(contentDocumentIds)
            );
            Logger.debug('Deleting {0} files...', Lists.of(String.valueOf(documents.size())));
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerDeleted(documents);
            uow.commitWork();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static ContentDistribution createPublicLink(Id contentVersionId) {
        try {
            List<ContentDistribution> existingDistributions = documentDistributionSelector.selectByContentVersionIds(
                Lists.of(contentVersionId)
            );
            if (!existingDistributions.isEmpty()) {
                Logger.debug('Found existing distribution for [{0}] content version.', Lists.of(contentVersionId));
                return existingDistributions[0];
            }
            Logger.debug('Creating new distribution for [{0}] content version.', Lists.of(contentVersionId));
            // Create a new ContentDistribution record to represent the share;
            ContentDistribution distribution = new ContentDistribution();
            distribution.Name = 'Public Link Available Externally';
            distribution.ContentVersionId = contentVersionId;
            distribution.PreferencesAllowViewInBrowser = true;
            distribution.PreferencesLinkLatestVersion = true;
            distribution.PreferencesNotifyOnVisit = false;
            distribution.PreferencesPasswordRequired = false;
            distribution.PreferencesAllowOriginalDownload = true;
            // Insert the 'ContentDistribution' record;
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(distribution);
            uow.commitWork();
            // After the insert, the 'DistributionPublicUrl' field will be populated;
            return documentDistributionSelector.selectByContentVersionIds(Lists.of(contentVersionId))[0];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * Used to cleanup content documents with content workspace (aka folder).
     */
    public static void emptyRecycleBin() {
        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument WHERE IsDeleted IN (TRUE, FALSE)];
        if (!documents.isEmpty()) {
            System.debug('\n\n Deleting Documents => ' + documents.size() + '\n');
            delete documents;
            Database.emptyRecycleBin(documents);
        }
        List<ContentWorkspace> workspaces = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Minlopro_SampleFiles'];
        if (!workspaces.isEmpty()) {
            System.debug('\n\n Deleting Workspaces => ' + workspaces.size() + '\n');
            delete workspaces;
        }
        List<SObject> itemsToPurge = new List<SObject>();
        itemsToPurge.addAll(documents);
        itemsToPurge.addAll(workspaces);
        if (!itemsToPurge.isEmpty()) {
            System.debug('\n\n Purging recycle bin => ' + itemsToPurge.size() + '\n');
            Database.emptyRecycleBin(itemsToPurge);
        }
    }
}
