import { LightningElement, track, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { createRecord, updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex Controller Methods;
import findDuplicatesApex from '@salesforce/apex/DuplicatesManagerController.findDuplicates';
import upsertContactApex from '@salesforce/apex/DuplicatesManagerController.upsertContact';

// Static Resources;
import COMMONS_ASSETS from '@salesforce/resourceUrl/CommonsAssets';

// Schema;
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import CHECK_IF_DUPLICATE_FIELD from '@salesforce/schema/Contact.CheckIfDuplicate__c';

const $CONTACTS_RELATED_LIST_ID = 'Contacts';
const $RECORD_ID = 'Id';
const CONTACT_TEMPLATE = {
    FirstName: null,
    LastName: null,
    CheckIfDuplicate__c: false,
    Phone: null,
    Email: null
};

/**
 * Areas to investigate:
 * - run custom logic that checks whether duplicate Contact record exists
 * - create Contact record while duplicate rule(s) exist and enforced
 * - create Contact record bypassing duplicate rules
 */
export default class DuplicatesManagerTab extends LightningElement {
    @track selectedAccountId = '@SF_SAMPLE_ACCOUNT_ID';
    @track selectedContactId;
    @track errorObject = null;
    @track contactDraft = { ...CONTACT_TEMPLATE };
    @track loading = false;
    @track hasChanges = false;
    @track duplicateContacts = [];

    get accountDisplayInfo() {
        return {
            additionalFields: ['Phone']
        };
    }

    get accountMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Phone' }]
        };
    }

    get hasAccountSelected() {
        return Boolean(this.selectedAccountId);
    }

    get backgroundSvgUrl() {
        return `${COMMONS_ASSETS}/svg/background1.svg`;
    }

    get contactFields() {
        return [FIRSTNAME_FIELD, LASTNAME_FIELD, CHECK_IF_DUPLICATE_FIELD, EMAIL_FIELD, PHONE_FIELD];
    }

    get contactFieldNames() {
        return this.contactFields.map(({ fieldApiName }) => `Contact.${fieldApiName}`);
    }

    get isCreateRecordMode() {
        return !Boolean(this.selectedContactId);
    }

    get isUpdateRecordMode() {
        return Boolean(this.selectedContactId);
    }

    get createBtnInfo() {
        return {
            label: 'Create Record',
            selected: this.isCreateRecordMode,
            iconName: 'utility:add',
            variant: this.isCreateRecordMode ? 'brand' : 'neutral'
        };
    }

    get updateBtnInfo() {
        return {
            label: 'Update Record',
            selected: this.isUpdateRecordMode,
            iconName: 'utility:edit_form',
            variant: this.isUpdateRecordMode ? 'brand' : 'neutral'
        };
    }

    get contactColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: $RECORD_ID,
                    objectApiName: 'Contact',
                    value: { fieldName: $RECORD_ID }
                }
            },
            {
                label: 'Phone',
                fieldName: 'Phone',
                type: 'phone'
            },
            {
                label: 'Email',
                fieldName: 'Email',
                type: 'email'
            },
            {
                label: 'Check If Duplicate?',
                fieldName: 'CheckIfDuplicate__c',
                type: 'boolean'
            },
            { type: 'action', typeAttributes: { rowActions: [{ label: 'Edit', name: 'edit' }] } }
        ];
    }

    get contactData() {
        const { data } = this.wiredRelatedContacts;
        if (data) {
            const relatedRecords = cloneObject(data.records);
            return relatedRecords.map(({ id, fields = {} }) => {
                return {
                    [$RECORD_ID]: id,
                    [PHONE_FIELD.fieldApiName]: fields[PHONE_FIELD.fieldApiName].value,
                    [EMAIL_FIELD.fieldApiName]: fields[EMAIL_FIELD.fieldApiName].value,
                    [CHECK_IF_DUPLICATE_FIELD.fieldApiName]: fields[CHECK_IF_DUPLICATE_FIELD.fieldApiName].value
                };
            });
        }
        return [];
    }

    get duplicateColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: $RECORD_ID,
                    objectApiName: 'Contact',
                    value: { fieldName: $RECORD_ID }
                }
            },
            {
                label: 'Phone',
                fieldName: 'Phone',
                type: 'phone'
            },
            {
                label: 'Email',
                fieldName: 'Email',
                type: 'email'
            },
            {
                label: 'Check If Duplicate?',
                fieldName: 'CheckIfDuplicate__c',
                type: 'boolean'
            },
            {
                label: 'Account',
                fieldName: 'AccountId',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'AccountId' },
                    fieldName: 'AccountId',
                    objectApiName: 'Account',
                    value: { fieldName: 'AccountId' }
                }
            }
        ];
    }

    get duplicateData() {
        return cloneObject(this.duplicateContacts || []);
    }

    get hasNoRelatedContacts() {
        return this.contactData.length === 0;
    }

    get hasErrors() {
        return Boolean(this.normalizedErrorObject);
    }

    get normalizedErrorObject() {
        if (Boolean(this.wiredRelatedContacts.error)) {
            return this.wiredRelatedContacts.error;
        } else if (Boolean(this.errorObject)) {
            return this.errorObject;
        }
        return null;
    }

    get isFormValid() {
        return [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputFields) => {
            inputFields.reportValidity();
            return validSoFar && inputFields.checkValidity();
        }, true);
    }

    get disableBtn() {
        return this.loading;
    }

    get stats() {
        return {
            'Contact Field API Names': this.contactFields.map((_) => _.fieldApiName).join(', '),
            'Selected Account Record ID': this.selectedAccountId,
            'Selected Contact Record ID': this.selectedContactId,
            'Form Mode': this.isCreateRecordMode ? 'create' : 'update',
            'Related Contacts Count': this.contactData.length,
            'Has Errors': this.hasErrors
        };
    }

    @wire(getRecord, {
        recordId: '$selectedContactId',
        fields: '$contactFields'
    })
    wiredContact({ data, error }) {
        if (data) {
            this.contactDraft['Id'] = this.selectedContactId;
            this.contactDraft[FIRSTNAME_FIELD.fieldApiName] = getFieldValue(data, FIRSTNAME_FIELD);
            this.contactDraft[LASTNAME_FIELD.fieldApiName] = getFieldValue(data, LASTNAME_FIELD);
            this.contactDraft[CHECK_IF_DUPLICATE_FIELD.fieldApiName] = getFieldValue(data, CHECK_IF_DUPLICATE_FIELD);
            this.contactDraft[PHONE_FIELD.fieldApiName] = getFieldValue(data, PHONE_FIELD);
            this.contactDraft[EMAIL_FIELD.fieldApiName] = getFieldValue(data, EMAIL_FIELD);
        } else if (error) {
            console.error('DuplicatesManagerTab.js', parseError(error));
        }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$selectedAccountId',
        relatedListId: $CONTACTS_RELATED_LIST_ID,
        fields: '$contactFieldNames',
        sortBy: ['Contact.Name']
    })
    wiredRelatedContacts = {};

    connectedCallback() {
        if (typeof this.selectedAccountId === 'string' && this.selectedAccountId.length < 10) {
            // Invalid Account ID;
            this.selectedAccountId = null;
        }
    }

    // Event Handlers;

    handleReset(event) {
        this.selectedAccountId = null;
        this.selectedContactId = null;
        this.contactDraft = { ...CONTACT_TEMPLATE };
        this.refs.accountPicker.clearSelection();
        this.errorObject = null;
    }

    handleAccountLookupChange(event) {
        console.log('DuplicatesManagerTab.js', `handleAccountLookupChange() | ${JSON.stringify(event.detail)}`);
        const { recordId } = event.detail;
        this.handleReset();
        this.selectedAccountId = recordId || null;
    }

    handleSwitchToCreateRecordMode(event) {
        if (!this.isCreateRecordMode) {
            this.selectedContactId = null;
            this.contactDraft = { ...CONTACT_TEMPLATE };
        }
    }

    handleRowAction(event) {
        const { action, row } = event.detail;
        switch (action.name) {
            case 'edit':
                this.selectedContactId = row[$RECORD_ID];
                break;
        }
    }

    handleRefreshWireAdapter(event) {
        refreshApex(this.wiredRelatedContacts);
    }

    handleInputChange(event) {
        this.hasChanges = true;
        const fieldName = event.target.dataset.name;
        const { value, checked } = event.detail;
        this.contactDraft[fieldName] = value || checked;
        console.log('Contact Draft Change', JSON.stringify(this.contactDraft));
        // Reset duplicates;
        this.duplicateContacts = [];
    }

    async handleFindDuplicates(event) {
        if (!this.isFormValid) {
            return;
        }
        this.loading = true;
        this.errorObject = null;
        try {
            const contactToCheck = cloneObject(this.contactDraft);
            this.duplicateContacts = await findDuplicatesApex({ contactToCheck });
            $Toastify.info({ message: `Found ${this.duplicateContacts.length} duplicate Contacts.` });
        } catch (error) {
            // Capture error details;
            this.errorObject = error;
            const { message } = parseError(error);
            // Show notification;
            $Toastify.error({ title: 'Duplicates search failed!', message });
        } finally {
            this.loading = false;
        }
    }

    async handleSubmitViaUiApi(event) {
        if (!this.isFormValid) {
            return;
        }
        // Reset spinner & errors;
        this.loading = true;
        this.errorObject = null;
        // Invoke UI API;
        console.log('Submitting via UI API', JSON.stringify(this.contactDraft));
        const isNew = !Boolean(this.selectedContactId);
        const recordInput = {
            apiName: isNew ? 'Contact' : null,
            fields: { ...this.contactDraft }
        };
        if (isNew) {
            recordInput.fields['AccountId'] = this.selectedAccountId;
            recordInput.fields['MobilePhone'] = '1234567890';
        }
        try {
            const { id } = isNew ? await createRecord(recordInput) : await updateRecord(recordInput);
            this.selectedContactId = id;
            // Refresh related list records;
            await refreshApex(this.wiredRelatedContacts);
            // Show notification;
            $Toastify.success({ message: `${isNew ? 'Created new' : 'Updated'} Contact [${id}].` });
        } catch (error) {
            // Capture error details;
            this.errorObject = error;
            const { message } = parseError(error);
            // Show notification;
            $Toastify.error({ title: 'Failed to save Contact via UI API!', message });
        } finally {
            this.loading = false;
            this.hasChanges = false;
        }
    }

    async handleSubmitViaApex(event) {
        // Reset spinner & errors;
        this.loading = true;
        this.errorObject = null;
        // Invoke UI API;
        console.log('Submitting via Apex', JSON.stringify(this.contactDraft));
        this.contactDraft['AccountId'] = this.selectedAccountId;
        this.contactDraft['MobilePhone'] = '1234567890';
        try {
            this.selectedContactId = await upsertContactApex({ contactToUpsert: this.contactDraft });
            // Refresh related list records;
            await refreshApex(this.wiredRelatedContacts);
            // Show notification;
            $Toastify.success({ message: `Saved Contact via Apex!` });
        } catch (error) {
            // Capture error details;
            this.errorObject = error;
            const { message } = parseError(error);
            // Show notification;
            $Toastify.error({ title: 'Failed to save Contact via Apex!', message });
        } finally {
            this.loading = false;
            this.hasChanges = false;
        }
    }
}
