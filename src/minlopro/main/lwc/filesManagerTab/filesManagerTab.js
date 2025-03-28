import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isNotEmpty } from 'c/utilities';
import $Toastify from 'c/toastify';

import $USER_ID from '@salesforce/user/Id';

// Apex Controller Methods;
import queryOrCreateFolderIfNotExistsApex from '@salesforce/apex/FilesManagementController.queryOrCreateFolderIfNotExists';
import getFilesByParentIdApex from '@salesforce/apex/FilesManagementController.getFilesByParentId';
import addFilesToFolderApex from '@salesforce/apex/FilesManagementController.addFilesToFolder';
import deleteFilesByIdsApex from '@salesforce/apex/FilesManagementController.deleteFilesByIds';
import createPublicLinkApex from '@salesforce/apex/FilesManagementController.createPublicLink';

// Schema;
import CD_TITLE from '@salesforce/schema/ContentDocument.Title';
import CD_LATEST_PUBLISHED_VERSION_ID from '@salesforce/schema/ContentDocument.LatestPublishedVersionId';
import CD_PARENT_ID from '@salesforce/schema/ContentDocument.ParentId';
import CD_PUBLISH_STATUS from '@salesforce/schema/ContentDocument.PublishStatus';
import CD_SHARING_OPTION from '@salesforce/schema/ContentDocument.SharingOption';
import CD_SHARING_PRIVACY from '@salesforce/schema/ContentDocument.SharingPrivacy';

// Custom combobox options;
const CD_PUBLISH_STATUS_OPTIONS = [
    { label: '(P) Public', value: 'P' },
    { label: '(R) Personal Library', value: 'R' },
    { label: '(U) Upload Interrupted', value: 'U' }
];
const CD_SHARING_OPTIONS = [
    { label: '(A) Allowed', value: 'A' },
    { label: '(R) Restricted', value: 'R' }
];
const CD_SHARING_PRIVACY_OPTIONS = [
    { label: '(N) Visible to Anyone With Record Access', value: 'N' },
    { label: '(P) Private on Records', value: 'P' }
];

export default class FilesManagerTab extends LightningElement {
    @track contentWorkspace = null;
    @track doExplicitlyLinkToFolder = true;
    @track contentDistribution = {};
    @track loading = false;
    @track errorObject = null;

    get acceptedFormats() {
        return ['.pdf', '.png', '.txt'];
    }

    get contentWorkspaceId() {
        return this.contentWorkspace?.Id;
    }

    get contentWorkspaceName() {
        return this.contentWorkspace?.Name;
    }

    get stats() {
        return {
            'Content Workspace': `${this.contentWorkspaceName} (${this.contentWorkspaceId}) lorem ip sum lorem ip sum lorem ip sum lorem ip sum lorem ip sum lorem ip sum`,
            'Running User ID': this.runningUserId,
            'Has Errors': this.hasErrors,
            'Total # of Files': `${this.documentData.length} items`,
            'Total # of Files In Workspace': `${this.documentsInWorkspace.length} items`
        };
    }

    get hasErrors() {
        return isNotEmpty(this.errorObject) || isNotEmpty(this.wiredFolderFiles.error);
    }

    get normalizedErrorObject() {
        if (!this.hasErrors) {
            return null;
        }
        return this.errorObject || this.wiredFolderFiles.error;
    }

    get documentColumns() {
        return [
            {
                label: 'Content Document',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Id',
                    objectApiName: 'ContentDocument',
                    value: { fieldName: 'Id' },
                    nameFieldPath: CD_TITLE.fieldApiName
                }
            },
            {
                label: 'Parent ID',
                fieldName: CD_PARENT_ID.fieldApiName,
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: CD_PARENT_ID.fieldApiName,
                    objectApiName: 'ContentWorkspace',
                    value: { fieldName: CD_PARENT_ID.fieldApiName }
                }
            },
            {
                label: 'Publish Status',
                fieldName: CD_PUBLISH_STATUS.fieldApiName,
                type: 'customCombobox',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: CD_PUBLISH_STATUS.fieldApiName,
                    value: { fieldName: CD_PUBLISH_STATUS.fieldApiName },
                    options: CD_PUBLISH_STATUS_OPTIONS
                }
            },
            {
                label: 'Sharing Option',
                fieldName: CD_SHARING_OPTION.fieldApiName,
                type: 'customCombobox',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: CD_SHARING_OPTION.fieldApiName,
                    value: { fieldName: CD_SHARING_OPTION.fieldApiName },
                    options: CD_SHARING_OPTIONS
                }
            },
            {
                label: 'Sharing Privacy',
                fieldName: CD_SHARING_PRIVACY.fieldApiName,
                type: 'customCombobox',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: CD_SHARING_PRIVACY.fieldApiName,
                    value: { fieldName: CD_SHARING_PRIVACY.fieldApiName },
                    options: CD_SHARING_PRIVACY_OPTIONS
                }
            },
            {
                label: 'Latest Published Version',
                fieldName: CD_LATEST_PUBLISHED_VERSION_ID.fieldApiName,
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: CD_LATEST_PUBLISHED_VERSION_ID.fieldApiName,
                    objectApiName: 'ContentVersion',
                    value: { fieldName: CD_LATEST_PUBLISHED_VERSION_ID.fieldApiName },
                    nameFieldPath: 'Title'
                }
            },
            {
                label: 'Owner',
                fieldName: 'OwnerId',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'OwnerId',
                    objectApiName: 'User',
                    value: { fieldName: 'OwnerId' }
                }
            },
            { type: 'action', typeAttributes: { rowActions: [{ label: 'Create Public Link', name: 'createPublicLink' }] } }
        ];
    }

    get documentData() {
        if (this.wiredFolderFiles.data) {
            return cloneObject(this.wiredFolderFiles.data);
        }
        return [];
    }

    get documentsInWorkspace() {
        return this.documentData.filter(({ ParentId }) => ParentId === this.contentWorkspaceId);
    }

    get documentIds() {
        return this.documentData.map(({ Id }) => Id);
    }

    get hasContentDistribution() {
        return isNotEmpty(this.contentDistribution);
    }

    get runningUserId() {
        return $USER_ID;
    }

    @wire(getFilesByParentIdApex)
    wiredFolderFiles = {};

    async connectedCallback() {
        this.loading = true;
        try {
            this.contentWorkspace = cloneObject(await queryOrCreateFolderIfNotExistsApex());
        } catch (error) {
            this.errorObject = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }

    // Event Handler;

    handleReset(event) {
        this.contentDistribution = {};
        this.loading = false;
        this.errorObject = null;
        refreshApex(this.wiredFolderFiles);
    }

    handleToggleLinkage(event) {
        const { checked } = event.detail;
        this.doExplicitlyLinkToFolder = checked;
    }

    async handleDeleteAllFiles(event) {
        this.loading = true;
        try {
            await deleteFilesByIdsApex({ contentDocumentIds: this.documentIds });
            this.handleReset(event);
            $Toastify.info({ message: `Deleted all files in "${this.contentWorkspace.Name}" content workspace.` });
        } catch (error) {
            this.errorObject = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }

    async handleUploadFinished(event) {
        const { files = [] } = event.detail;
        try {
            console.group('File Upload');
            files.forEach(({ name, documentId }) => {
                console.log(`${documentId} | ${name}`);
            });
            console.log('Total # of uploaded files:', files.length);
            $Toastify.success({ message: `${files.length} files uploaded!` });
            this.loading = true;
            if (this.doExplicitlyLinkToFolder) {
                // Explicitly put files in folder;
                let contentDocumentIds = files.map(({ documentId }) => documentId);
                let contentDocumentLinks = await addFilesToFolderApex({ contentDocumentIds });
                console.table(contentDocumentLinks);
                $Toastify.success({
                    message: `${files.length} files were explicitly added to "${this.contentWorkspace.Name}" content workspace.`
                });
            }
        } catch (error) {
            this.errorObject = cloneObject(error);
        } finally {
            this.loading = false;
            refreshApex(this.wiredFolderFiles);
            console.groupEnd();
        }
    }

    async handleRowAction(event) {
        const { action, row } = event.detail;
        this.loading = true;
        try {
            if (action.name === 'createPublicLink') {
                let contentVersionId = row[CD_LATEST_PUBLISHED_VERSION_ID.fieldApiName];
                this.contentDistribution = await createPublicLinkApex({ contentVersionId });
                console.table(cloneObject(this.contentDistribution));
                /**
                 * Invoke cURL command in order to download the file from bash:
                 * curl -o 'sf_downloaded_file.png' "{this.contentDistribution.ContentDownloadUrl}"
                 */
                console.log('end of execution!');
            }
        } catch (error) {
            this.errorObject = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }
}
