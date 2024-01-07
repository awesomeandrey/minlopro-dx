import { LightningElement, track } from 'lwc';

import USER_ID from '@salesforce/user/Id';

export default class Playground extends LightningElement {
    @track value = USER_ID;

    get displayInfo() {
        return {
            additionalFields: ['Phone']
        };
    }

    get matchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Phone' }]
        };
    }

    handleLookupChange(event) {
        console.log('Playground.js', `handleLookupChange() | ${JSON.stringify(event.detail)}`);
        const { recordId } = event.detail;
        this.value = recordId || null;
    }

    handleLookupBlur(event) {
        console.log('Playground.js', `handleLookupBlur() | ${JSON.stringify(event.detail)}`);
    }

    handleLookupError(event) {
        console.error('Playground.js', `handleLookupError() | ${JSON.stringify(event.detail)}`);
    }
}
