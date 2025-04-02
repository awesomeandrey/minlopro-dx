import { LightningElement, track } from 'lwc';
import { cloneObject, resolveRecordId, uniqueId, waitAsync } from 'c/utilities';

import USER_ID from '@salesforce/user/Id';

// Constants;
const SAMPLE_ACCOUNT_ID = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
const SAMPLE_CONTACT_ID = resolveRecordId('${SF_SAMPLE_CONTACT_ID}');

export default class Playground extends LightningElement {
    @track selectedUserId = USER_ID;
    @track selectedChannel = 'sms'; // values [sms, email]
    @track loading = false;

    @track isSmsOptInEligible = true;
    @track isEmailOptInEligible = true;

    get optInTemplateText() {
        return 'Hi John,We hope this message finds you well! We are reaching out to ask for your permission to receive [specific information, services, or updates, e.g., marketing communications, newsletters, etc.] from us. Your consent is important, and we would like to ensure you are comfortable with receiving communications from [Your Company Name].';
    }

    get isSmsChannel() {
        return this.selectedChannel === 'sms';
    }

    get doDisableSmsChannel() {
        return this.loading || !this.isSmsOptInEligible;
    }

    get isEmailChannel() {
        return this.selectedChannel === 'email';
    }

    get doDisableEmailChannel() {
        return this.loading || !this.isEmailOptInEligible;
    }

    get hasAnyOptInChannelAvailable() {
        return this.isSmsOptInEligible || this.isEmailOptInEligible;
    }

    async handleCelebrateWithConfetti(event) {
        await this.refs.confetti.celebrate();
    }

    async handleSendOptInMessage() {
        this.loading = true;
        await waitAsync(2000);
        this.loading = false;
    }

    handleSelectDeliveryChannel(event) {
        if (event.target.disabled) {
            return;
        }
        this.selectedChannel = event.target.dataset.name;
    }

    handleToggleChange(event) {
        const { name } = event.target.dataset;
        const { checked } = event.detail;
        this[name] = checked;
        // Reset channel;
        if (this.isSmsOptInEligible) {
            this.selectedChannel = 'sms';
        } else {
            this.selectedChannel = 'email';
        }
    }
}
