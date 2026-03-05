import { LightningElement, track } from 'lwc';
import { parseError } from 'c/utilities';
import $Toastify from 'c/toastify';
import { randomFirstName, randomLastName, randomEmail } from 'c/digExTestDataFactory';

/**
 * @description Web-to-Lead form with Google reCAPTCHA v2 (checkbox) verification.
 * Uses the digExReCaptchaForm wrapper for reCAPTCHA lifecycle management.
 */
export default class DigExWebToLeadForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';

    connectedCallback() {
        this.firstName = randomFirstName();
        this.lastName = randomLastName();
        this.email = randomEmail(this.firstName, this.lastName);
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
