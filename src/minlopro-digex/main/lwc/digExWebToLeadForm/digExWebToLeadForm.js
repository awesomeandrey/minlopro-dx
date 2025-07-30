import { LightningElement, track } from 'lwc';
import { isEmpty, parseError, wait } from 'c/utilities';
import $Toastify from 'c/toastify';

import verifyUserTokenApex from '@salesforce/apex/DigExWebToLeadController.verifyUserToken';

export default class DigExWebToLeadForm extends LightningElement {
    static renderMode = 'light';

    @track $grecaptcha = null;
    @track isCaptchaValid = false;
    @track error = null;
    @track loading = false;

    get disableBtn() {
        return this.loading || isEmpty(this.$grecaptcha) || !this.isCaptchaValid;
    }

    async connectedCallback() {
        this.loading = true;
        try {
            this.$grecaptcha = await new Promise((resolve, reject) => {
                document.dispatchEvent(new CustomEvent('requestGrecaptcha', { detail: { callback: resolve } }));
                wait(() => reject('Failed to capture reCAPTCHA library reference.'), 5000);
            });
        } catch (error) {
            this.error = error;
            return;
        }
        // Explicitly render the widget;
        this.$grecaptcha?.render(this.refs.gRecaptcha, {
            sitekey: '${SF_GOOGLE_RECAPTCHA_SITE_KEY}',
            callback: this.verifyCaptcha.bind(this),
            'expired-callback': () => {
                // The name of your callback function, executed when the reCAPTCHA response expires and the user needs to re-verify.
                console.log('[reCAPTCHA] expired-callback()');
                this.isCaptchaValid = false;
                $Toastify.info({ message: 'Verification expired. Check verification checkbox again.' });
            },
            'error-callback': (error) => {
                // The name of your callback function, executed when reCAPTCHA encounters an error (usually network connectivity) and cannot continue until connectivity is restored. If you specify a function here, you are responsible for informing the user that they should retry.
                console.log('[reCAPTCHA] error-callback()', error);
                this.isCaptchaValid = false;
                $Toastify.error({ message: parseError(error)?.message }, this);
                this.error = error;
            }
        });
        this.loading = false;
    }

    async verifyCaptcha(userToken) {
        this.loading = true;
        try {
            this.error = null;
            this.isCaptchaValid = false;
            const { success = false, errorCodes = [] } = await verifyUserTokenApex({ userToken });
            this.isCaptchaValid = success;
            if (!this.isCaptchaValid) {
                this.error = { message: `Captcha is invalid: ${errorCodes}` };
            }
        } catch (error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }

    handleSubmitForm(event) {
        event.preventDefault();
        if (this.refs.w2lForm.reportValidity() && this.isCaptchaValid) {
            this.refs.w2lForm.submit();
        }
    }
}
