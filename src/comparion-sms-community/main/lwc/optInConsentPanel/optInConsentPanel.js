import { LightningElement, track } from 'lwc';

// Apex;
import validateAndCaptureOptInConsentApex from '@salesforce/apex/LmSmsOptInConsentController.validateAndCaptureOptInConsent';

// Constants;
const ACCOUNT_ID_PARAM = 'accountId';
const CODE_PARAM = 'code';

export default class OptInConsentPanel extends LightningElement {
    @track hasProcessed = false;
    @track errorMessage = null;
    @track successMessage = null;

    get accountId() {
        return this.urlParameters.get(ACCOUNT_ID_PARAM);
    }

    get code() {
        return this.urlParameters.get(CODE_PARAM);
    }

    get urlParameters() {
        return new URLSearchParams(document.location.search);
    }

    get hasError() {
        return Boolean(this.errorMessage);
    }

    get message() {
        if (this.hasError) {
            return {
                title: 'Failed to process Opt-In consent.',
                text: this.errorMessage,
                textClass: 'slds-text-color_error'
            };
        } else if (this.hasProcessed) {
            return {
                title: 'Thank you!',
                text: this.successMessage,
                textClass: 'slds-text-color_success'
            };
        } else {
            return {
                title: 'Processing...',
                text: 'Please wait until we handle your request.'
            };
        }
    }

    get isLoading() {
        return this.hasProcessed === false;
    }

    get isFailed() {
        return !this.isLoading && this.hasError;
    }

    get isSuccessful() {
        return !this.isLoading && !this.hasError;
    }

    async connectedCallback() {
        try {
            // TODO - added to testing purpose (to remove in scope of another task);
            await new Promise((resolve) => setTimeout(resolve, 2000));
            if (!this.accountId || !this.code) {
                throw new Error('Invalid request detected!');
            }
            let { success, message } = await validateAndCaptureOptInConsentApex({
                accountId: this.accountId,
                codeToVerify: this.code
            });
            if (success) {
                this.successMessage = message;
            } else {
                throw new Error(message);
            }
        } catch (error) {
            console.error('Error detected:', error);
            this.errorMessage = error?.message || error?.body?.message || JSON.stringify(error);
        } finally {
            this.hasProcessed = true;
        }
    }

    handleClosePage(event) {
        // Note: the link should have [rel="opener"] attribute in order to be closable from JS handler;
        window.close();
    }
}
