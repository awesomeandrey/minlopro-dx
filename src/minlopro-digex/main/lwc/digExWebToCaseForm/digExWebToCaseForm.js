import { LightningElement, track } from 'lwc';
import { parseError, capitalize } from 'c/utilities';
import $Toastify from 'c/toastify';
import { randomFirstName, randomLastName, randomEmail, randomText } from 'c/digExTestDataFactory';

/**
 * @description Web-to-Case form with Google reCAPTCHA v2 (checkbox) verification.
 * Submits a support case directly to Salesforce via the Web-to-Case endpoint.
 * Uses the digExReCaptchaForm wrapper for reCAPTCHA lifecycle management.
 *
 * Fields collected: contact name, email, subject, description.
 */
export default class DigExWebToCaseForm extends LightningElement {
    @track name = '';
    @track email = '';
    @track subject = '';
    @track description = '';

    connectedCallback() {
        const firstName = randomFirstName();
        const lastName = randomLastName();
        this.name = `${firstName} ${lastName}`;
        this.email = randomEmail(firstName, lastName);
        this.subject = capitalize(randomText(35));
    }

    renderedCallback() {
        if (!this.hasRendered && this.refs.description && !this.refs.description.value) {
            this.hasRendered = true;
            this.refs.description.value = capitalize(randomText(200));
        }
    }

    async handleFormSubmit(event) {
        const { formData } = event.detail;
        try {
            const W2C_URL = '${SF_INSTANCE_URL}/servlet/servlet.WebToCase?encoding=UTF-8&orgId=${SF_INSTANCE_ID}';
            // Requires 'Trusted URL' setup for the Salesforce instance URL
            await fetch(W2C_URL, { method: 'POST', body: formData, mode: 'no-cors' });
            $Toastify.success({ message: 'Your case has been submitted successfully!' });
            this.refs.reCaptchaForm.reset();
            void this.refs.reCaptchaForm.showSuccess();
        } catch (error) {
            $Toastify.error({ message: parseError(error)?.message || 'Failed to submit the form. Please try again.' });
        }
    }
}
