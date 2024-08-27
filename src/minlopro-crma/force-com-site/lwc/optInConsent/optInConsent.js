import { LightningElement } from 'lwc';

import markAccountAsOptInApex from '@salesforce/apex/OptInVfController.markAccountAsOptIn';

export default class OptInConsent extends LightningElement {
    get accountId() {
        return this.urlParameters.get('accountId');
    }

    get code() {
        return this.urlParameters.get('code');
    }

    get urlParameters() {
        return new URLSearchParams(document.location.search);
    }

    async connectedCallback() {
        try {
            debugger;
            const saveResult = await markAccountAsOptInApex({ accountId: this.accountId });
            console.log(JSON.stringify(saveResult));
        } catch (error) {
            debugger;
            console.error(JSON.stringify(error));
        }
    }
}
