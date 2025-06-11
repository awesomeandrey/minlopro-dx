import { LightningElement } from 'lwc';

export default class UserMonitorObjectAccess extends LightningElement {
    get customObjectLookupSettings() {
        return {
            displayInfo: {
                primaryField: 'DeveloperName',
                additionalFields: ['NamespacePrefix']
            },
            matchingInfo: {
                primaryField: { fieldPath: 'DeveloperName' },
                additionalFields: [{ fieldPath: 'NamespacePrefix' }]
            }
        };
    }

    handleLookupSelect(event) {}

    handleLookupError(event) {
        const { error } = event.detail;
        console.table(error);
        debugger;
        // ERR_RP002
        // ERR_RP003
    }

    connectedCallback() {}

    handleRunDemo(event) {
        setTimeout(() => this.goToPanel('panel2'), 2000); // simulates user selecting object
        setTimeout(() => this.goToPanel('panel3'), 5000); // simulates clicking 'view FLS'
    }

    goToPanel(refName) {
        // reset all;
        ['panel1', 'panel2', 'panel3'].forEach((el, index) => {
            this.refs[el].classList.remove('expanded');
            this.refs[el].classList.add('collapsed');
        });
        // expand particular section
        this.refs[refName].classList.add('expanded');
        this.refs[refName].classList.remove('collapsed');
    }
}
