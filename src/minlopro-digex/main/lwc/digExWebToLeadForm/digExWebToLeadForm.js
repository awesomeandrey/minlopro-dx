import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { cloneObject, isEmpty, isNotEmpty, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';
import { randomFirstName, randomLastName, randomEmail } from 'c/digExTestDataFactory';

import LEAD_OBJECT from '@salesforce/schema/Lead';
import PREFERRED_LANGUAGE_FIELD from '@salesforce/schema/Lead.PreferredLanguage__c';

/**
 * @description Web-to-Lead form with Google reCAPTCHA v2 (checkbox) verification.
 * Uses the digExReCaptchaForm wrapper for reCAPTCHA lifecycle management.
 */
export default class DigExWebToLeadForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track preferredLanguage = 'English';

    get languageOptions() {
        if (isNotEmpty(this.wiredPreferredLanguagePicklistValues.data)) {
            return this.wiredPreferredLanguagePicklistValues.data.values.map(({ label, value }) => ({ label, value }));
        }
        return [];
    }

    get leadDefaultRecordTypeId() {
        return this.wiredLeadObjectInfo?.data?.defaultRecordTypeId;
    }

    get errorObj() {
        return this.wiredLeadObjectInfo?.error || this.wiredPreferredLanguagePicklistValues?.error;
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    wiredLeadObjectInfo = {};

    @wire(getPicklistValues, { recordTypeId: '$leadDefaultRecordTypeId', fieldApiName: PREFERRED_LANGUAGE_FIELD })
    wiredPreferredLanguagePicklistValues = {};

    connectedCallback() {
        this.firstName = randomFirstName();
        this.lastName = randomLastName();
        this.email = randomEmail(this.firstName, this.lastName);
    }

    handleChangePreferredLanguage(event) {
        this.preferredLanguage = event.target.value;
    }

    async handleFormSubmit(event) {
        const { formData } = event.detail;
        try {
            const W2L_URL = '${SF_INSTANCE_URL}/servlet/servlet.WebToLead?encoding=UTF-8&orgId=${SF_INSTANCE_ID}';
            // Requires 'Trusted URL' setup
            await fetch(W2L_URL, { method: 'POST', body: formData, mode: 'no-cors' });
            $Toastify.success({ message: 'Your information has been submitted successfully!' });
            this.refs.reCaptchaForm.reset();
            void this.refs.reCaptchaForm.showSuccess();
        } catch (error) {
            $Toastify.error({ message: parseError(error)?.message || 'Failed to submit the form. Please try again.' });
        }
    }
}
