import { LightningElement, track } from 'lwc';
import { cloneObject, isEmpty } from 'c/utilities';

// Custom Permissions;
import IS_FILES_MANAGER from '@salesforce/customPermission/IsFilesManager';
import IS_LEADS_MANAGER from '@salesforce/customPermission/IsLeadManager';
import IS_OCR_USER from '@salesforce/customPermission/IsOcrUser';

export default class Workspace extends LightningElement {
    @track selectedTabName = this.isValidTabName(this.lc_selectedTabName) ? this.lc_selectedTabName : 'playground';
    @track doCollapseTabs = this.lc_doCollapseTabs;
    @track componentConstructor = null;
    @track error = null;

    get tabs() {
        // 'name' property corresponds to LWC component API name;
        return [
            { label: 'Playground', name: 'playground', iconName: 'utility:activity', visible: true },
            { label: 'Currency Rollup', name: 'currencyRollupTab', iconName: 'utility:money', visible: true },
            { label: 'Duplicates Manager', name: 'duplicatesManagerTab', iconName: 'utility:groups', visible: true },
            { label: 'Datatable Contacts', name: 'datatableContacts', iconName: 'utility:table', visible: true },
            { label: 'Custom Combobox', name: 'comboboxPlayground', iconName: 'utility:bundle_policy', visible: true },
            { label: 'LWC Modal Demo', name: 'modalPlayground', iconName: 'utility:preview', visible: true },
            { label: 'Files Manager', name: 'filesManagerTab', iconName: 'utility:share_file', visible: IS_FILES_MANAGER },
            { label: 'Leads Conversion', name: 'leadsManagerTab', iconName: 'utility:lead', visible: IS_LEADS_MANAGER },
            {
                label: 'Approval Process Breakdown',
                name: 'approvalProcessBreakdownTab',
                iconName: 'utility:approval',
                visible: true
            },
            { label: 'Keyset Pagination', name: 'keysetPaginationTab', iconName: 'utility:breadcrumbs', visible: true },
            { label: 'Drag & Drop', name: 'dragAndDrop', iconName: 'utility:drag', visible: true },
            { label: 'PDF-Lib Demo', name: 'pdfLibDemo', iconName: 'utility:pdf_ext', visible: true },
            { label: 'TesseractJS-OCR', name: 'ocrDemo', iconName: 'utility:scan', visible: IS_OCR_USER },
            {
                label: 'Per-User Named Credential Demo',
                name: 'perUserNamedCredentialTab',
                iconName: 'utility:integration',
                visible: true
            }
        ]
            .map((tabInfo) => {
                tabInfo.label = this.doCollapseTabs ? '' : tabInfo.label;
                tabInfo.iconName = isEmpty(tabInfo.iconName) ? 'utility:bundle_policy' : tabInfo.iconName;
                return tabInfo;
            })
            .filter(({ visible = false }) => visible);
    }

    get lc_selectedTabName() {
        return window.localStorage.getItem('selectedTabName');
    }

    get lc_doCollapseTabs() {
        return window.localStorage.getItem('doCollapseTabs') === 'true';
    }

    async handleSelectTab(event) {
        // Fired immediately upon 'lightning-vertical-navigation' LWC load if 'name' property is specified;
        const { name } = event.detail;
        this.selectedTabName = name;
        window.localStorage.setItem('selectedTabName', name);
        // Instantiate LWC;
        await this.instantiate(name);
    }

    handleToggleTabs(event) {
        this.doCollapseTabs = !this.doCollapseTabs;
        window.localStorage.setItem('doCollapseTabs', `${this.doCollapseTabs}`); // Cast to string;
    }

    async instantiate(componentName) {
        this.error = null;
        try {
            // Dynamically instantiate LWC by its API name;
            const { default: componentConstructor } = await import(`c/${componentName}`);
            this.componentConstructor = componentConstructor;
        } catch (error) {
            this.error = cloneObject(error);
        }
    }

    isValidTabName(tabNameToCheck) {
        return this.tabs.some(({ name }) => name === tabNameToCheck);
    }
}
