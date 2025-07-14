import { LightningElement, track } from 'lwc';
import { resolveRecordId } from 'c/utilities';

import updateAccountSsnApex from '@salesforce/apex/UnableToLockRowDemoController.updateAccountSsn';

export default class UnableToLockRowTab extends LightningElement {
    @track selectedAccountId = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
    @track concurrentRequests = 5;
    @track syntheticDelay = 2000;
    @track doApplyForUpdate = false;
    @track loading = false;

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

    get stats() {
        return {
            'Account ID': this.selectedAccountId,
            'Concurrent Requests': this.concurrentRequests,
            'Synthetic Delay': `${this.syntheticDelay}ms`,
            'Apply FOR UPDATE Clause': this.doApplyForUpdate
        };
    }

    handleRefreshRecord(event) {}

    handleAccountLookupChange(event) {
        const { recordId } = event.detail;
        this.selectedAccountId = recordId || null;
    }

    handleConcurrentRequestsChange(event) {
        const { value } = event.detail;
        this.concurrentRequests = value;
    }

    handleSyntheticDelayChange(event) {
        const { value } = event.detail;
        this.syntheticDelay = value;
    }

    handleDoApplyForUpdateChange(event) {
        const { checked } = event.detail;
        this.doApplyForUpdate = checked;
    }
}
