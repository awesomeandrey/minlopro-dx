import { LightningElement, track } from 'lwc';
import { isEmpty, parseError, wait, waitAsync } from 'c/utilities';
import $Toastify from 'c/toastify';

import verifyUserTokenApex from '@salesforce/apex/DigExWebToLeadController.verifyUserToken';

/**
 * @description Web-to-Lead form with Google reCAPTCHA v2 (checkbox) verification.
 */
export default class DigExWebToLeadForm extends LightningElement {
    static renderMode = 'light';

    @track reCaptchaWidget = null;
    @track isReCaptchaValid = false;
    @track error = null;
    @track loading = false;
    @track submitted = false;

    get disableBtn() {
        return this.loading || isEmpty(this.reCaptchaWidget) || !this.isReCaptchaValid;
    }

    get showForm() {
        return !this.submitted;
    }

    async connectedCallback() {
        this.loading = true;
        try {
            this.reCaptchaWidget = await new Promise((resolve, reject) => {
                document.dispatchEvent(new CustomEvent('requestGrecaptcha', { detail: { callback: resolve } }));
                wait(() => reject('Failed to capture reCAPTCHA library reference.'), 5000);
            });
        } catch (error) {
            this.error = error;
            return;
        }
        this.renderReCaptchaWidget();
        this.loading = false;
    }

    renderReCaptchaWidget() {
        this.reCaptchaWidget?.render(this.refs.reCaptcha, {
            sitekey: '${SF_GOOGLE_RECAPTCHA_SITE_KEY}',
            callback: this.verifyReCaptcha.bind(this),
            'expired-callback': () => {
                console.log('[reCAPTCHA] expired-callback()');
                this.isReCaptchaValid = false;
                $Toastify.info({ message: 'Verification expired. Check verification checkbox again.' });
            },
            'error-callback': (error) => {
                console.log('[reCAPTCHA] error-callback()', error);
                this.isReCaptchaValid = false;
                $Toastify.error({ message: parseError(error)?.message }, this);
                this.error = error;
            }
        });
    }

    async verifyReCaptcha(userToken) {
        this.loading = true;
        try {
            this.error = null;
            this.isReCaptchaValid = false;
            const { success = false, errorCodes = [] } = await verifyUserTokenApex({ userToken });
            this.isReCaptchaValid = success;
            if (!this.isReCaptchaValid) {
                this.error = { message: `Captcha is invalid: ${errorCodes}` };
            }
        } catch (error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }

    async handleSubmitForm(event) {
        event.preventDefault();
        if (!this.refs.w2lForm.reportValidity() || !this.isReCaptchaValid) {
            return;
        }
        this.loading = true;
        try {
            const formData = new FormData(this.refs.w2lForm);
            const W2L_URL = '${SF_INSTANCE_URL}/servlet/servlet.WebToLead?encoding=UTF-8&orgId=${SF_INSTANCE_ID}';
            // Requires 'Trusted URL' setup
            await fetch(W2L_URL, { method: 'POST', body: formData, mode: 'no-cors' });
            $Toastify.success({ message: 'Your information has been submitted successfully!' });
            // Reset form
            this.refs.w2lForm.reset();
            this.reCaptchaWidget?.reset();
            this.isReCaptchaValid = false;
            // Show 'Thanks' message for 5 sec
            const container = this.refs.container;
            container.style.minHeight = `${container.offsetHeight}px`;
            this.submitted = true;
            setTimeout(async () => {
                this.submitted = false;
                container.style.minHeight = '';
                // Wait for LWC to flush DOM updates before re-rendering reCAPTCHA
                await waitAsync();
                this.renderReCaptchaWidget();
            }, 5000);
        } catch (error) {
            this.error = error;
            $Toastify.error({ message: parseError(error)?.message || 'Failed to submit the form. Please try again.' });
        } finally {
            this.loading = false;
        }
    }
}
