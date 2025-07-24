import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { cloneObject, isNotEmpty } from 'c/utilities';
// import { AuthConfig, getAuthConfigs, PageReference } from 'c/digExUtil';

// Apex;
import setExperienceIdApex from '@salesforce/apex/DigExLoginController.setExperienceId';
import registerApex from '@salesforce/apex/DigExRegisterController.register';

// Constants;
import $IsGuestUser from '@salesforce/user/isGuest';

export default class DigExRegisterForm extends NavigationMixin(LightningElement) {
    @track firstName = null;
    @track lastName = null;
    @track userEmail = null;
    @track error = null;
    @track loading = false;

    get hasInvalidInputs() {
        return this.$inputElements.some((input) => !input.checkValidity());
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    get $inputElements() {
        return [this.refs.firstnameInput, this.refs.lastnameInput, this.refs.emailInput];
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
            // this.authConfigs = await getAuthConfigs();
            // if (!this.usernamePasswordEnabled) {
            //     this.error = {
            //         message: 'Username/Password login is disabled!'
            //     };
            // }
        }
    }

    handleFirstnameChange(event) {
        event.preventDefault();
        this.firstName = event.detail.value;
    }

    handleLastnameChange(event) {
        event.preventDefault();
        this.lastName = event.detail.value;
    }

    handleEmailChange(event) {
        event.preventDefault();
        this.userEmail = event.detail.value;
    }

    async handleSignUp(event) {
        event.preventDefault();
        if (this.hasInvalidInputs) {
            this.$inputElements.forEach((input) => input.reportValidity());
            return;
        }
        try {
            this.loading = true;
            this.error = null;
            const result = await registerApex({
                firstname: this.firstName,
                lastname: this.lastName,
                userEmail: this.userEmail
            });
            const clonedResult = cloneObject(result);
            console.table(clonedResult);
        } catch (error) {
            this.error = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }
}
