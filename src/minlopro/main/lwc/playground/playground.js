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

    get sampleStats() {
        return {
            'Display Info': JSON.stringify(this.displayInfo),
            'Matching Info': JSON.stringify(this.matchingInfo),
            'Another Long Property': 'Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum;',
            'Another Really Long Property':
                'Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum'
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

    async handleCelebrateWithConfetti(event) {
        await this.refs.confetti.celebrate();
    }
}
