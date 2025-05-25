import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import $Toastify from 'c/toastify';
import { cloneObject, isEmpty, isNotEmpty } from 'c/utilities';

// Constants;
import $UserId from '@salesforce/user/Id';

// Apex Controller Methods;
import getNamedCredentialsApex from '@salesforce/apex/NamedCredentialsController.getNamedCredentials';
import getAuthenticationUrlApex from '@salesforce/apex/NamedCredentialsController.getAuthenticationUrl';
import invokeApex from '@salesforce/apex/NamedCredentialsController.invoke';

export default class NamedCredentialsTab extends NavigationMixin(LightningElement) {
    @track selectedValue = 'SalesforceRestApi';
    @track loading = true;
    @track calloutStats = null;
    @track error = null;

    get namedCredentialOptions() {
        return this.namedCredentials.map(({ MasterLabel, DeveloperName, PrincipalType }) => ({
            label: MasterLabel,
            value: DeveloperName,
            iconName: isNotEmpty(PrincipalType) ? 'utility:anywhere_alert' : 'utility:events'
        }));
    }

    get namedCredentials() {
        if (isEmpty(this.wiredNamedCredentials.data)) {
            return [];
        }
        return cloneObject(this.wiredNamedCredentials.data);
    }

    get selectedNamedCredential() {
        return this.namedCredentials.find(({ DeveloperName }) => DeveloperName === this.selectedValue);
    }

    get selectedNamedCredentialType() {
        if (this.selectedNamedCredential) {
            let principalType = this.selectedNamedCredential['PrincipalType'];
            return isNotEmpty(principalType) ? `Legacy (${principalType})` : `Secured Endpoint`;
        }
        return null;
    }

    get doDisableBtn() {
        return this.loading || isEmpty(this.selectedValue);
    }

    get hasCalloutStats() {
        return isNotEmpty(this.calloutStats);
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    get browserTabName() {
        return `${this.selectedValue}-${$UserId}`;
    }

    @wire(getNamedCredentialsApex)
    wiredNamedCredentials = {};

    connectedCallback() {
        this.loading = false;
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

    async handleRedirectToAuthPage() {
        this.loading = true;
        try {
            const url = await getAuthenticationUrlApex({ namedCredentialApiName: this.selectedValue });
            // When 'this.browserTabName' is used then consecutive link clicks navigate to the same browser tab;
            window.open(url, this.browserTabName, 'width=900,height=600');
        } catch (error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }
}
