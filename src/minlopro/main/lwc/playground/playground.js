import { LightningElement, track } from 'lwc';
import { cloneObject, uniqueId } from 'c/utilities';

import USER_ID from '@salesforce/user/Id';

// Constants;
const SAMPLE_ACCOUNT_ID = '@SF_SAMPLE_ACCOUNT_ID';
const SF_SAMPLE_CONTACT_ID = '@SF_SAMPLE_CONTACT_ID';

export default class Playground extends LightningElement {
    @track selectedUserId = USER_ID;

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
                'Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum; Lorem ip sum',
            'Contacts #': this.tableData.length
        };
    }

    get tableColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Id',
                    objectApiName: 'Contact',
                    value: { fieldName: 'Id' }
                }
            },
            {
                label: 'Title',
                fieldName: 'Title',
                type: 'text'
            },
            {
                label: 'Account',
                fieldName: 'AccountId',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'AccountId',
                    objectApiName: 'Account',
                    value: { fieldName: 'AccountId' }
                }
            },
            {
                label: 'Industry',
                fieldName: 'Industry__c',
                type: 'customPicklist',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Industry__c',
                    value: { fieldName: 'Industry__c' },
                    objectApiName: 'Contact'
                }
            },
            {
                label: 'Job Function',
                fieldName: 'JobFunction__c',
                type: 'customPicklist',
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'JobFunction__c',
                    value: { fieldName: 'JobFunction__c' },
                    objectApiName: 'Contact'
                }
            },
            {
                label: 'Title',
                fieldName: 'Title',
                type: 'text'
            }
        ];
    }

    get tableData() {
        return [
            {
                Id: SF_SAMPLE_CONTACT_ID || uniqueId(),
                AccountId: SAMPLE_ACCOUNT_ID,
                Title: 'Account Executive',
                Industry__c: 'Technology',
                JobFunction__c: 'SoftwareDeveloper'
            }
        ];
    }

    handleLookupChange(event) {
        console.log('Playground.js', `handleLookupChange() | ${JSON.stringify(event.detail)}`);
        const { recordId } = event.detail;
        this.selectedUserId = recordId || null;
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
