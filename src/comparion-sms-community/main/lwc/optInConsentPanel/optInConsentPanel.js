import { LightningElement, api, track } from 'lwc';

// Apex;
import validateAndCaptureOptInConsentApex from '@salesforce/apex/LmSmsOptInConsentController.validateAndCaptureOptInConsent';

// Constants;
const ACCOUNT_ID_PARAM = 'accountId';
const CODE_PARAM = 'code';

export default class OptInConsentPanel extends LightningElement {
    @track hasProcessed = false;
    @track errorMessage = null;

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
            return 'Failed to process Opt-In consent.';
        } else if (this.hasProcessed) {
            return 'Thank you!';
        } else {
            return 'Processing...';
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
        /**
         * TODO - invoke custom Apex controller, validate code & capture opt-in consent;
         * TODO - to be implemented as a separate ticket/work item;
         */
        console.log('accountId > ', this.accountId);
        console.log('code > ', this.code);
        debugger;
        try {
            if (!this.accountId || !this.code) {
                throw new Error('Invalid request detected!');
            }
            let success = await validateAndCaptureOptInConsentApex({ accountId: this.accountId, codeToVerify: this.code });
            if (!success) {
                throw new Error('Server error occurred!');
            }
        } catch (error) {
            console.error(error);
            debugger;
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
