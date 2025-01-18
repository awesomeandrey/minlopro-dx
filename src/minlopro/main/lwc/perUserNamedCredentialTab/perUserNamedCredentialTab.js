import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import $Toastify from 'c/toastify';
import { cloneObject, isEmpty, isNotEmpty } from 'c/utilities';

// Apex Controller Methods;
import getNamedCredentialsApex from '@salesforce/apex/PerUserNamedCredentialController.getNamedCredentials';
import getDataUserAuthUrlApex from '@salesforce/apex/PerUserNamedCredentialController.getDataUserAuthUrl';
import invokeApex from '@salesforce/apex/PerUserNamedCredentialController.invoke';

export default class PerUserNamedCredentialTab extends NavigationMixin(LightningElement) {
    @track selectedValue = 'SalesforceRestApi';
    @track loading = true;
    @track calloutStats = null;
    @track error = null;

    get namedCredentialOptions() {
        return this.namedCredentials.map(({ MasterLabel, DeveloperName, PrincipalType }) => ({
            label: `${MasterLabel} (${PrincipalType})`,
            value: DeveloperName
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

    get doDisableBtn() {
        return this.loading || isEmpty(this.selectedValue);
    }

    get hasCalloutStats() {
        return isNotEmpty(this.calloutStats);
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    @wire(getNamedCredentialsApex)
    wiredNamedCredentials = {};

    connectedCallback() {
        this.loading = false;
    }

    handleSelect(event) {
        const { value } = event.detail;
        this.selectedValue = value;
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
        // this[NavigationMixin.Navigate](
        //     {
        //         type: 'standard__webPage',
        //         attributes: {
        //             url: 'https://@SF_SITE_DOMAIN_NAME.my.salesforce-setup.com/lightning/settings/personal/ExternalObjectUserSettings/home'
        //         }
        //     },
        //     false
        // );
        this.loading = true;
        try {
            const url = await getDataUserAuthUrlApex({ namedCredentialApiName: this.selectedValue });
            window.open(url, 'Enter Login Details', 'width=900,height=600');
        } catch (error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }
}
