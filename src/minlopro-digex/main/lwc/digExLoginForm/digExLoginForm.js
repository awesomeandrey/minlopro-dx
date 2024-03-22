import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty } from 'c/utilities';

// Apex;
import setExperienceIdApex from '@salesforce/apex/DigExLoginController.setExperienceId';
import loginWithCredentialsApex from '@salesforce/apex/DigExLoginController.loginWithCredentials';

/**
 * TODO - add link to register page;
 * TODO - add link to forgot password;
 */

export default class DigExLoginForm extends LightningElement {
    @track username = null;
    @track password = null;
    @track loading = false;
    @track error = null;

    get hasInvalidInputs() {
        return this.$inputElements.some((input) => !input.checkValidity());
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    get $inputElements() {
        return [this.refs.usernameInput, this.refs.passwordInput];
    }

    async connectedCallback() {
        await setExperienceIdApex();
    }

    // Event Handlers;

    handleUsernameChange(event) {
        event.preventDefault();
        this.username = event.detail.value;
    }

    handlePasswordChange(event) {
        event.preventDefault();
        this.password = event.detail.value;
    }

    async handleLogin(event) {
        event.preventDefault();
        if (this.hasInvalidInputs) {
            this.$inputElements.forEach((input) => input.reportValidity());
            return;
        }
        try {
            this.loading = true;
            this.error = null;
            const redirectUrl = await loginWithCredentialsApex({
                username: this.username,
                password: this.password
            });
            // Redirect user to site home page;
            window.location.replace(redirectUrl);
        } catch (error) {
            this.error = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }
}
