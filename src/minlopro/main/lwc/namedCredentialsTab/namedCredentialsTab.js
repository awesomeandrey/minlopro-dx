import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import $Toastify from 'c/toastify';
import { cloneObject, isEmpty, isNotEmpty } from 'c/utilities';

import $UserId from '@salesforce/user/Id';

import getNamedCredentialsApex from '@salesforce/apex/NamedCredentialsController.getNamedCredentials';
import invokeApex from '@salesforce/apex/NamedCredentialsController.invoke';

export default class NamedCredentialsTab extends NavigationMixin(LightningElement) {
    @track selectedValue = 'SalesforceRestApi';
    @track loading = true;
    @track calloutStats = null;
    @track error = null;

    get namedCredentialOptions() {
        return this.namedCredentials.map((item) => {
            return {
                ...item,
                value: item.apiName,
                iconName: item.isLegacy ? 'utility:anywhere_alert' : 'utility:events'
            };
        });
    }

    get namedCredentials() {
        if (isEmpty(this.wiredNamedCredentials.data)) {
            return [];
        }
        return cloneObject(this.wiredNamedCredentials.data);
    }

    get selectedNamedCredential() {
        return this.namedCredentials.find(({ apiName }) => apiName === this.selectedValue) || {};
    }

    get doDisableBtn() {
        return this.loading || isEmpty(this.selectedValue);
    }

    get hasCalloutStats() {
        return isNotEmpty(this.calloutStats);
    }

    get browserTabName() {
        return `${this.selectedValue}-${$UserId}`;
    }

    get isLegacyPerUser() {
        return isNotEmpty(this.selectedNamedCredential) && this.selectedNamedCredential.isLegacyPerUser;
    }

    get isSecuredEndpoint() {
        return isNotEmpty(this.selectedNamedCredential) && !this.selectedNamedCredential.isLegacy;
    }

    @wire(getNamedCredentialsApex)
    wiredNamedCredentials = {};

    connectedCallback() {
        this.loading = false;
        /**
         * Inspired by https://www.jamessimone.net/blog/joys-of-apex/implementing-oauth-browser-flows-properly.
         * Works when authenticating External Credentials only!
         */
        const popupContext = window.opener;
        if (popupContext) {
            window.close();
        }
    }

    handleSelect(event) {
        const { value } = event.detail;
        this.selectedValue = value;
        // Reset stats;
        this.calloutStats = null;
        this.error = null;
    }

    async handleInvokeCallout() {
        this.loading = true;
        this.calloutStats = null;
        this.error = null;
        try {
            const result = await invokeApex({ namedCredentialApiName: this.selectedValue });
            this.calloutStats = cloneObject(result);
            if (this.calloutStats.success) {
                $Toastify.success({ message: 'HTTP callout succeeded!' });
            } else {
                $Toastify.warning({ message: 'HTTP callout failed! Check stats for details.' });
                this.error = { message: 'Unsuccessful HTTP response code received' };
            }
        } catch (error) {
            this.error = error;
            $Toastify.error({ message: 'HTTP callout failed! Check stats for details.' });
        } finally {
            this.loading = false;
        }
    }

    async handleAuthLegacyNamedCredential() {
        this.loading = true;
        try {
            const { authenticationUrl } = this.selectedNamedCredential;
            /**
             * `this.browserTabName` is assigned to give each tab a unique identifier, ensuring that repeated clicks
             * on the same link reload the existing tab instead of opening a new one each time.
             */
            window.open(authenticationUrl, this.browserTabName);
        } catch (error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }
}
