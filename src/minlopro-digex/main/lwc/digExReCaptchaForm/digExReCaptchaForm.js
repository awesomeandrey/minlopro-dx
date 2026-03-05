import { LightningElement, api, track } from 'lwc';
import { parseError, wait, waitAsync } from 'c/utilities';
import $Toastify from 'c/toastify';

import verifyUserTokenApex from '@salesforce/apex/DigExReCaptchaController.verifyUserToken';

/**
 * @description Reusable reCAPTCHA-protected form wrapper.
 * Handles reCAPTCHA v2 (checkbox) lifecycle: initialization, widget rendering, and token verification.
 * The parent component passes form fields via the default slot and listens to the 'formsubmit' event
 * to perform the actual form submission (e.g. Web-to-Lead, Web-to-Case).
 *
 * @fires DigExReCaptchaForm#formsubmit
 *
 * @example
 * <c-dig-ex-re-captcha-form onformsubmit={handleFormSubmit} submit-label="Submit" lwc:ref="reCaptchaForm">
 *     <input type="hidden" name="orgid" value="..." />
 *     <input id="subject" name="subject" type="text" class="slds-input" required />
 * </c-dig-ex-re-captcha-form>
 */
export default class DigExReCaptchaForm extends LightningElement {
    static renderMode = 'light';

    /** Label for the submit button. */
    @api submitLabel = 'Submit';

    @track reCaptchaWidget = null;
    @track isReCaptchaValid = false;
    @track error = null;
    @track loading = false;
    @track submitted = false;

    get disableBtn() {
        return this.loading || !this.reCaptchaWidget || !this.isReCaptchaValid;
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
        } finally {
            this.loading = false;
        }
        this.renderReCaptchaWidget();
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

    handleSubmit(event) {
        event.preventDefault();
        if (!this.refs.form.reportValidity() || !this.isReCaptchaValid) {
            return;
        }
        const formData = new FormData(this.refs.form);
        /**
         * Fired when the form passes validation and reCAPTCHA is verified.
         * @event DigExReCaptchaForm#formsubmit
         * @type {CustomEvent}
         * @property {FormData} detail.formData - The collected form data ready for submission.
         */
        this.dispatchEvent(new CustomEvent('formsubmit', { detail: { formData } }));
    }

    /**
     * Resets the form fields and reCAPTCHA widget. Call this after a successful submission.
     */
    @api
    reset() {
        this.refs.form?.reset();
        this.reCaptchaWidget?.reset();
        this.isReCaptchaValid = false;
        this.error = null;
    }

    /**
     * Shows the "Thanks!" success message for the given duration, then restores the form.
     * @param {number} [durationMs=5000] - How long to show the success message in milliseconds.
     */
    @api
    async showSuccess(durationMs = 5000) {
        const container = this.refs.container;
        container.style.minHeight = `${container.offsetHeight}px`;
        this.submitted = true;
        setTimeout(async () => {
            this.submitted = false;
            container.style.minHeight = '';
            await waitAsync();
            this.renderReCaptchaWidget();
        }, durationMs);
    }
}
