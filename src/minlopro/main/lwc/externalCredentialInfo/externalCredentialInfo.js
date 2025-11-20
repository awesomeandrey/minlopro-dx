import { api, LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isEmpty, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

import getExternalCredentialApex from '@salesforce/apex/NamedCredentialsController.getExternalCredential';
import getExternalCredentialAuthUrlApex from '@salesforce/apex/NamedCredentialsController.getExternalCredentialAuthUrl';

export default class ExternalCredentialInfo extends LightningElement {
    @api recordId = null;

    @track loading = false;

    get externalCredential() {
        if (isEmpty(this.wiredExternalCredential.data)) {
            return {};
        }
        return cloneObject(this.wiredExternalCredential.data);
    }

    get principalsColumns() {
        return [
            {
                label: '#',
                fieldName: 'sequenceNumber',
                type: 'number'
            },
            {
                label: 'Principal Name',
                fieldName: 'principalName',
                type: 'customBadge'
            },
            {
                label: 'Principal Type',
                fieldName: 'principalType',
                type: 'customCodeSnippet'
            },
            {
                label: 'Auth Status',
                fieldName: 'authenticationStatus',
                type: 'customCodeSnippet'
            },
            {
                type: 'action',
                typeAttributes: { rowActions: [{ label: 'Configure', name: 'configure' }] }
            }
        ];
    }

    get principalsData() {
        return this.externalCredential?.principals?.map(
            ({ authenticationStatus, id, principalName, principalType, sequenceNumber }) => ({
                authenticationStatus,
                id,
                principalName,
                principalType,
                sequenceNumber
            })
        );
    }

    @wire(getExternalCredentialApex, { recordId: '$recordId' })
    wiredExternalCredential = {};

    renderedCallback() {
        console.table(this.externalCredential);
    }

    async handleRefresh() {
        await refreshApex(this.wiredExternalCredential);
    }

    async handleRowAction(event) {
        const { action, row } = event.detail;
        if (action.name === 'configure') {
            try {
                const authenticationUrl = await getExternalCredentialAuthUrlApex({
                    externalCredentialName: this.externalCredential.developerName,
                    principalType: row.principalType,
                    principalName: row.principalName
                });
                console.table(authenticationUrl);
                const browserTabName = `${this.externalCredential.id}-${row.principalName}-${row.principalType}`;
                window.open(authenticationUrl, browserTabName);
            } catch (error) {
                const { message } = parseError(error);
                $Toastify.error({ message });
            }
        }
    }
}
