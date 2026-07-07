import { LightningElement, wire, track } from 'lwc';
import {
    EnclosingTabId,
    IsConsoleNavigation,
    closeTab,
    disableTabClose,
    focusTab,
    getAllTabInfo,
    getFocusedTabInfo,
    getTabInfo,
    openSubtab,
    openTab,
    refreshTab,
    setTabHighlighted,
    setTabIcon,
    setTabLabel
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';
import { isEmpty, resolveRecordId } from 'c/utilities';

export default class WorkspaceApiTab extends NavigationMixin(LightningElement) {
    @track generatedAccountUrl = null;
    @track sampleAccountId = resolveRecordId('${SF_SAMPLE_PERSON_ACCOUNT_ID}');
    @track errorObj = null;

    @wire(IsConsoleNavigation)
    isConsoleNavigation = false;

    @wire(EnclosingTabId)
    enclosingTabId;

    get datatableKeyFieldName() {
        return 'Id';
    }

    get sampleColumns() {
        return [
            {
                label: 'Account Name',
                fieldName: this.datatableKeyFieldName,
                type: 'customLookup',
                editable: false,
                displayReadOnlyIcon: true,
                typeAttributes: {
                    context: { fieldName: this.datatableKeyFieldName },
                    fieldName: this.datatableKeyFieldName,
                    objectApiName: 'Account',
                    value: { fieldName: this.datatableKeyFieldName }
                }
            },
            {
                label: 'Record URL (_self)',
                fieldName: 'RecordUrl',
                type: 'url',
                typeAttributes: {
                    target: '_self'
                }
            },
            {
                label: 'Record URL (_target)',
                fieldName: 'RecordUrl',
                type: 'url',
                typeAttributes: {
                    target: '_target'
                }
            }
        ];
    }

    get sampleData() {
        return [{ Id: this.sampleAccountId, RecordUrl: `/${this.sampleAccountId}` }];
    }

    get stats() {
        return {
            'Is Console Navigation?': this.isConsoleNavigation,
            'Enclosing Tab Id': this.enclosingTabId,
            'Account ID': this.sampleAccountId,
            'Account Generated URL': this.generatedAccountUrl
        };
    }

    get slashRecordUrl() {
        return `/${this.sampleAccountId}`;
    }

    get disableTabOpen() {
        return !this.isConsoleNavigation;
    }

    get disableSubTabOpen() {
        return !this.isConsoleNavigation || isEmpty(this.enclosingTabId);
    }

    async handleGenerateAccountUrl(event) {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.sampleAccountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        };
        this.generatedAccountUrl = await this[NavigationMixin.GenerateUrl](pageRef);
    }

    handleOpenTab(event) {
        if (this.isConsoleNavigation) {
            openTab({ recordId: this.sampleAccountId });
        }
    }

    async handleOpenSubTab(event) {
        if (this.isConsoleNavigation) {
            try {
                const tabInfo = await getTabInfo(this.enclosingTabId);
                const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
                openSubtab(primaryTabId, { recordId: this.sampleAccountId, focus: true });
                setTabHighlighted(primaryTabId, true, {
                    pulse: true,
                    state: 'success'
                });
            } catch (error) {
                this.errorObj = error;
            }
        }
    }

    handleReset(event) {
        this.generatedAccountUrl = null;
        this.errorObj = null;
    }

    handleDatatableClick(event) {
        event.preventDefault();
    }
}
