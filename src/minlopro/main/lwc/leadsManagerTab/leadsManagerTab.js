import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isNotEmpty } from 'c/utilities';
import ConvertLeadModal from 'c/convertLeadModal';

// Apex Controller Methods;
import getMineNonConvertedLeadsApex from '@salesforce/apex/LeadsManagementController.getMineNonConvertedLeads';
import getMineConvertedLeadsApex from '@salesforce/apex/LeadsManagementController.getMineConvertedLeads';

// Column configs;
const COL_LEAD_NAME = {
    label: 'Lead',
    fieldName: 'Id',
    type: 'customLookup',
    typeAttributes: {
        context: { fieldName: 'Id' },
        fieldName: 'Id',
        objectApiName: 'Lead',
        value: { fieldName: 'Id' }
    }
};
const COL_LEAD_STATUS = {
    label: 'Status',
    fieldName: 'Status',
    type: 'customPicklist',
    typeAttributes: {
        context: { fieldName: 'Id' },
        fieldName: 'Status',
        value: { fieldName: 'Status' },
        objectApiName: 'Lead'
    }
};
const COL_LEAD_SOURCE = {
    label: 'Lead Source',
    fieldName: 'LeadSource',
    type: 'customPicklist',
    typeAttributes: {
        context: { fieldName: 'Id' },
        fieldName: 'LeadSource',
        value: { fieldName: 'LeadSource' },
        objectApiName: 'Lead'
    }
};
const COL_LEAD_COMPANY = {
    label: 'Company',
    fieldName: 'Company',
    type: 'text'
};
const COL_LEAD_ANNUAL_REVENUE = {
    label: 'Annual Revenue',
    fieldName: 'AnnualRevenue',
    type: 'currency',
    typeAttributes: {
        currencyCode: { fieldName: 'CurrencyIsoCode' },
        currencyDisplayAs: 'symbol'
    }
};
const COL_LEAD_EMAIL = {
    label: 'Email',
    fieldName: 'Email',
    type: 'email'
};
const COL_LEAD_CONVERTED_ACCOUNT = {
    label: 'Converted Account',
    fieldName: 'ConvertedAccountId',
    type: 'customLookup',
    typeAttributes: {
        context: { fieldName: 'ConvertedAccountId' },
        fieldName: 'ConvertedAccountId',
        objectApiName: 'Account',
        value: { fieldName: 'ConvertedAccountId' }
    }
};
const COL_LEAD_CONVERTED_CONTACT = {
    label: 'Converted Contact',
    fieldName: 'ConvertedContactId',
    type: 'customLookup',
    typeAttributes: {
        context: { fieldName: 'ConvertedContactId' },
        fieldName: 'ConvertedContactId',
        objectApiName: 'Contact',
        value: { fieldName: 'ConvertedContactId' }
    }
};
const COL_LEAD_CONVERTED_OPPORTUNITY = {
    label: 'Converted Opportunity',
    fieldName: 'ConvertedOpportunityId',
    type: 'customLookup',
    typeAttributes: {
        context: { fieldName: 'ConvertedOpportunityId' },
        fieldName: 'ConvertedOpportunityId',
        objectApiName: 'Opportunity',
        value: { fieldName: 'ConvertedOpportunityId' }
    }
};

export default class LeadsManagerTab extends LightningElement {
    @track loading = false;
    @track errorObject = null;

    get stats() {
        return {
            'Non-Converted Leads Amount': this.nonConvertedLeads.length,
            'Converted Leads Amount': this.convertedLeads.length,
            'Has Errors': this.hasErrors
        };
    }

    get hasErrors() {
        return (
            isNotEmpty(this.errorObject) ||
            isNotEmpty(this.wiredNonConvertedLeads.error) ||
            isNotEmpty(this.wiredConvertedLeads.error)
        );
    }

    get normalizedErrorObject() {
        if (!this.hasErrors) {
            return null;
        }
        return this.errorObject || this.wiredNonConvertedLeads.error || this.wiredConvertedLeads.error;
    }

    get nonConvertedLeadsColumns() {
        return [
            COL_LEAD_NAME,
            COL_LEAD_SOURCE,
            COL_LEAD_STATUS,
            COL_LEAD_COMPANY,
            COL_LEAD_ANNUAL_REVENUE,
            COL_LEAD_EMAIL,
            { type: 'action', typeAttributes: { rowActions: [{ label: 'Convert', name: 'convert' }] } }
        ];
    }

    get nonConvertedLeads() {
        if (this.wiredNonConvertedLeads.data) {
            return cloneObject(this.wiredNonConvertedLeads.data);
        }
        return [];
    }

    get convertedLeads() {
        if (this.wiredConvertedLeads.data) {
            return cloneObject(this.wiredConvertedLeads.data);
        }
        return [];
    }

    get convertedLeadsColumns() {
        return [
            COL_LEAD_NAME,
            COL_LEAD_SOURCE,
            COL_LEAD_COMPANY,
            COL_LEAD_CONVERTED_ACCOUNT,
            COL_LEAD_CONVERTED_CONTACT,
            COL_LEAD_CONVERTED_OPPORTUNITY
        ];
    }

    @wire(getMineNonConvertedLeadsApex)
    wiredNonConvertedLeads = {};

    @wire(getMineConvertedLeadsApex)
    wiredConvertedLeads = {};

    connectedCallback() {}

    // Event Handler;

    async handleRefreshWireAdapters() {
        this.loading = true;
        await Promise.all([refreshApex(this.wiredNonConvertedLeads), refreshApex(this.wiredConvertedLeads)]);
        this.loading = false;
    }

    async handleReset(event) {
        this.errorObject = null;
        await this.handleRefreshWireAdapters();
    }

    async handleRowAction(event) {
        const { action, row } = event.detail;
        if (action.name === 'convert') {
            await ConvertLeadModal.open({ recordId: row['Id'], disableClose: false });
            await this.handleRefreshWireAdapters();
        }
    }
}
