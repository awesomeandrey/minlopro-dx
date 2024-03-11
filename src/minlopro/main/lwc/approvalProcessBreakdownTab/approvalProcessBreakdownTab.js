import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isEmpty, isEmptyArray, isNotEmpty, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex;
import isLockedApex from '@salesforce/apex/ApprovalProcessController.isLocked';
import lockApex from '@salesforce/apex/ApprovalProcessController.lock';
import unlockApex from '@salesforce/apex/ApprovalProcessController.unlock';
import submitOpportunityForApproval from '@salesforce/apex/ApprovalProcessController.submitOpportunityForApproval';
import getProcessInstancesByRecordIdApex from '@salesforce/apex/ApprovalProcessController.getProcessInstancesByRecordId';

// Constants;
import $UserId from '@salesforce/user/Id';

export default class ApprovalProcessBreakdownTab extends LightningElement {
    @track selectedOpportunityId = '@SF_SAMPLE_OPPORTUNITY_ID';
    @track selectedProcessInstanceId = null;
    @track loading = false;
    @track errorObj = null;

    get stats() {
        return {
            'Selected Opportunity ID': this.selectedOpportunityId,
            'Is Opportunity Locked?': this.isOpportunityLocked,
            'Has Pending Approval Process?': this.hasPendingApprovalProcess,
            'Has Errors': this.hasErrors
        };
    }

    get oppDisplayInfo() {
        return {
            additionalFields: ['StageName']
        };
    }

    get oppMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'StageName' }]
        };
    }

    get hasErrors() {
        return Boolean(this.normalizedError);
    }

    get normalizedError() {
        if (Boolean(this.wiredOppLockStatus?.error)) {
            return this.wiredOppLockStatus.error;
        }
        if (Boolean(this.wiredOppProcessInstances?.error)) {
            return this.wiredOppProcessInstances.error;
        } else if (Boolean(this.errorObj)) {
            return this.errorObj;
        }
        return null;
    }

    get isOpportunityLocked() {
        return this.wiredOppLockStatus?.data === true;
    }

    get toggleLockBtn() {
        return this.isOpportunityLocked ? 'Unlock' : 'Lock';
    }

    get disableActions() {
        return isEmpty(this.selectedOpportunityId);
    }

    get processInstanceColumns() {
        return [
            {
                label: 'Id',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Id',
                    objectApiName: 'ProcessInstance',
                    value: { fieldName: 'Id' },
                    nameFieldPath: 'Id'
                }
            },
            {
                label: 'Process Definition',
                fieldName: 'ProcessDefinitionId',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'ProcessDefinitionId',
                    objectApiName: 'ProcessDefinition',
                    value: { fieldName: 'ProcessDefinitionId' }
                }
            },
            {
                label: 'Status',
                fieldName: 'Status',
                type: 'customCombobox',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Status',
                    value: { fieldName: 'Status' },
                    options: ['Started', 'Pending', 'Rejected', 'Approved'].map((_) => ({ label: _, value: _ }))
                }
            },
            {
                label: 'Submitted By',
                fieldName: 'SubmittedById',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'SubmittedById',
                    value: { fieldName: 'SubmittedById' },
                    objectApiName: 'User'
                }
            },
            {
                label: 'Last Actor',
                fieldName: 'LastActorId',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'LastActorId',
                    value: { fieldName: 'LastActorId' },
                    objectApiName: 'User'
                }
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [{ label: 'Visualize', name: 'visualize' }]
                }
            }
        ];
    }

    get processInstanceData() {
        if (this.wiredOppProcessInstances.data) {
            return cloneObject(this.wiredOppProcessInstances.data);
        }
        return [];
    }

    get hasPendingApprovalProcess() {
        return this.processInstanceData.some(({ Status }) => Status === 'Pending');
    }

    @wire(isLockedApex, { recordId: '$selectedOpportunityId' })
    wiredOppLockStatus = {};

    @wire(getProcessInstancesByRecordIdApex, { recordId: '$selectedOpportunityId' })
    wiredOppProcessInstances = {};

    connectedCallback() {}

    handleOpportunityChange(event) {
        console.log('ApprovalProcessBreakdownTab.js', `handleOpportunityChange() | ${JSON.stringify(event.detail)}`);
        const { recordId } = event.detail;
        this.selectedOpportunityId = recordId || null;
        this.handleRefreshWires();
    }

    async handleToggleLock(event) {
        try {
            this.loading = true;
            this.errorObj = null;
            if (this.isOpportunityLocked) {
                await unlockApex({ recordId: this.selectedOpportunityId });
            } else {
                await lockApex({ recordId: this.selectedOpportunityId });
            }
            $Toastify.success({ message: `Opportunity was ${this.isOpportunityLocked ? 'unlocked' : 'locked'}.` });
        } catch (error) {
            this.errorObj = cloneObject(error);
        } finally {
            await this.handleRefreshWires();
            this.loading = false;
        }
    }

    async handleReset(event) {
        this.selectedOpportunityId = null;
        this.selectedProcessInstanceId = null;
        this.refs.oppPicker.clearSelection();
        this.errorObj = null;
        this.loading = false;
        await this.handleRefreshWires();
    }

    async handleRefreshWires(event) {
        await Promise.allSettled([refreshApex(this.wiredOppLockStatus), refreshApex(this.wiredOppProcessInstances)]);
    }

    async handleSubmitForApproval(event) {
        try {
            this.loading = true;
            this.errorObj = null;
            const serializedProcessResult = await submitOpportunityForApproval({
                opportunityId: this.selectedOpportunityId,
                submitterId: $UserId,
                skipEntryCriteria: false
            });
            let processResult = cloneObject(JSON.parse(serializedProcessResult));
            console.table(processResult);
        } catch (error) {
            this.errorObj = cloneObject(error);
        } finally {
            await this.handleRefreshWires();
            this.loading = false;
        }
    }

    handleRowAction(event) {
        const { action, row } = event.detail;
        switch (action.name) {
            case 'visualize':
                this.selectedProcessInstanceId = row['Id'];
                break;
        }
    }
}
