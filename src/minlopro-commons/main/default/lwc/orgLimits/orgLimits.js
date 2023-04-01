import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty, to, uniqueId } from 'c/commons';

// Apex;
import getAllOrgLimitsApex from '@salesforce/apex/OrgLimitsController.getAll';

export default class OrgLimits extends LightningElement {
    @track rawOrgLimits = [];
    @track showAllLimits = false;
    @track errorObj = {};

    get orgLimitsColumns() {
        return [
            {
                fieldName: 'name',
                label: 'Name'
            },
            {
                fieldName: 'value',
                label: 'Consumed',
                type: 'number'
            },
            {
                fieldName: 'limit',
                label: 'Limit',
                type: 'number'
            }
        ];
    }

    get orgLimitsData() {
        return this.rawOrgLimits.filter(({ value: consumed }) => {
            if (this.showAllLimits) {
                return true;
            } else {
                return Number(consumed) > 0;
            }
        });
    }

    get hasOrgLimitsData() {
        return isNotEmpty(this.rawOrgLimits);
    }

    get hasError() {
        return isNotEmpty(this.errorObj);
    }

    get orgLimitsAmountBadge() {
        return `Org Limits Amount: ${this.orgLimitsData.length}`;
    }

    get toggleFilterBtnVariant() {
        return this.showAllLimits ? 'neutral' : 'brand';
    }

    get toggleFilterBtnLabel() {
        return this.showAllLimits ? 'Show Consumed' : 'Show All';
    }

    async connectedCallback() {
        await this.fetchOrgLimits();
    }

    async handleRefresh(event) {
        this.rawOrgLimits = [];
        this.errorObj = {};
        await this.fetchOrgLimits();
    }

    async handleToggleFilter(event) {
        this.showAllLimits = !this.showAllLimits;
    }

    async fetchOrgLimits() {
        const [error, result = []] = await to(getAllOrgLimitsApex());
        if (isNotEmpty(error)) {
            this.errorObj = error;
        }
        // Enrich with `uid`;
        this.rawOrgLimits = cloneObject(result).map((_) => ({
            uid: uniqueId(),
            ..._
        }));
    }
}
