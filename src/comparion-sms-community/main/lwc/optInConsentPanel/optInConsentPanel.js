import { LightningElement, api, track } from 'lwc';

// Apex;
import validateAndCaptureOptInConsentApex from '@salesforce/apex/LmSmsOptInConsentController.validateAndCaptureOptInConsent';

// Constants;
const ACCOUNT_ID_PARAM = 'accountId';
const CODE_PARAM = 'code';

export default class OptInConsentPanel extends LightningElement {
    @track loading = false;

    get accountId() {
        return this.urlParameters.get(ACCOUNT_ID_PARAM);
    }

    get code() {
        return this.urlParameters.get(CODE_PARAM);
    }

    get urlParameters() {
        return new URLSearchParams(document.location.search);
    }

    connectedCallback() {
        /**
         * TODO - invoke custom Apex controller, validate code & capture opt-in consent;
         * TODO - to be implemented as a separate ticket/work item;
         */
        console.log('accountId > ', this.accountId);
        console.log('code > ', this.code);
    }
}
