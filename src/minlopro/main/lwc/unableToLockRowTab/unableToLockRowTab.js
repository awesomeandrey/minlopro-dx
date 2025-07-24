import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty, resolveRecordId } from 'c/utilities';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

import updateAccountSsnApex from '@salesforce/apex/UnableToLockRowDemoController.updateAccountSsn';

export default class UnableToLockRowTab extends LightningElement {
    @track selectedAccountId = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
    @track concurrentRequests = 50;
    @track syntheticDelay = 8000;
    @track doApplyForUpdate = false;
    @track loading = false;
    @track error = null;

    get accountDisplayInfo() {
        return {
            additionalFields: ['Phone']
        };
    }

    get accountMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Phone' }]
        };
    }

    get hasAccountSelected() {
        return isNotEmpty(this.selectedAccountId);
    }

    get stats() {
        return {
            'Account ID': this.selectedAccountId,
            'Concurrent Requests': this.concurrentRequests,
            'Synthetic Delay': `${this.syntheticDelay}ms`,
            'Apply FOR UPDATE Clause': this.doApplyForUpdate
        };
    }

    get disableBtn() {
        return this.loading || !this.hasAccountSelected;
    }

    async handleRefreshRecord() {
        await notifyRecordUpdateAvailable([{ recordId: this.selectedAccountId }]);
    }

    handleAccountLookupChange(event) {
        const { recordId } = event.detail;
        this.selectedAccountId = recordId || null;
    }

    handleConcurrentRequestsChange(event) {
        const { value } = event.detail;
        this.concurrentRequests = Number(value);
    }

    handleSyntheticDelayChange(event) {
        const { value } = event.detail;
        this.syntheticDelay = Number(value);
    }

    handleDoApplyForUpdateChange(event) {
        const { checked } = event.detail;
        this.doApplyForUpdate = checked;
    }

    async handleUpdateSSN(event) {
        event.preventDefault();
        try {
            this.loading = true;
            this.error = null;
            const promises = new Array(this.concurrentRequests).fill(0).map(() => {
                return updateAccountSsnApex({
                    recordId: this.selectedAccountId,
                    syntheticDelay: this.syntheticDelay,
                    doApplyForUpdate: this.doApplyForUpdate
                });
            });
            await Promise.all(promises);
        } catch (error) {
            this.error = cloneObject(error);
        } finally {
            await this.handleRefreshRecord({});
            this.loading = false;
        }
    }
}
