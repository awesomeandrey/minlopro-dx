import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { cloneObject, isNotEmpty } from 'c/utilities';
import { AuthConfig, getAuthConfigs, PageReference } from 'c/digExUtil';

// Apex;
import setExperienceIdApex from '@salesforce/apex/DigExLoginController.setExperienceId';
import loginWithCredentialsApex from '@salesforce/apex/DigExLoginController.loginWithCredentials';

// Constants;
import $IsGuestUser from '@salesforce/user/isGuest';

export default class DigExLoginForm extends NavigationMixin(LightningElement) {
    @track username = null;
    @track password = null;
    @track loading = false;
    @track error = null;
    @track authConfigs = {};

    get hasInvalidInputs() {
        return this.$inputElements.some((input) => !input.checkValidity());
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    get usernamePasswordEnabled() {
        return this.authConfigs[AuthConfig.UsernamePasswordEnabled] === true;
    }

    get selfRegistrationEnabled() {
        return this.authConfigs[AuthConfig.SelfRegistrationEnabled] === true;
    }

    get selfRegistrationUrl() {
        return this.authConfigs[AuthConfig.SelfRegistrationUrl];
    }

    get disableLogin() {
        return this.loading || !this.usernamePasswordEnabled || !$IsGuestUser;
    }

    get $inputElements() {
        return [this.refs.usernameInput, this.refs.passwordInput];
    }

    async connectedCallback() {
        if (!$IsGuestUser) {
            // Immediately redirect to Home page;
            // this[NavigationMixin.Navigate](PageReference.Home);
            this.error = {
                message: "You're already logged in!"
            };
        } else {
            await setExperienceIdApex();
            // Check auth configs and enabled/disable u/p login;
            this.authConfigs = await getAuthConfigs();
            if (!this.usernamePasswordEnabled) {
                this.error = {
                    message: 'Username/Password login is disabled!'
                };
            }
        }
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
