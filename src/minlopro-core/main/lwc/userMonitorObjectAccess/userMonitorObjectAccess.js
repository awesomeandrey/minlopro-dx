import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {
    cloneObject,
    isEmpty,
    parseError,
    debounce,
    isEmptyArray,
    isNotEmpty,
    capitalize,
    containsIgnoreCase
} from 'c/utilities';
import Toastify from 'c/toastify';

import searchObjectsByKeywordApex from '@salesforce/apex/UserMonitorController.searchObjectsByKeyword';

const LOCAL_STORAGE_KEY = 'object_qualified_api_names';

export default class UserMonitorObjectAccess extends LightningElement {
    @track selectedObjectName = null;
    @track searchObjectKeyword = null;
    @track searchFieldKeyword = null;
    @track foundObjects = [];
    @track handleSearchObjectKeywordChangeDebounced = debounce(this.handleSearchObjectKeywordChange.bind(this), 900);
    @track handleSearchFieldKeywordChangeDebounced = debounce(this.handleSearchFieldKeywordChange.bind(this), 900);
    @track loading = false;

    @wire(getObjectInfo, { objectApiName: '$selectedObjectName' })
    wiredObjectInfo = {};

    get hasObjectKeywordsHistory() {
        return !isEmptyArray(this.searchObjectKeywordsRaw);
    }

    get searchObjectKeywordsRaw() {
        const rawKeywords = localStorage.getItem(LOCAL_STORAGE_KEY) || '[]';
        return Array.from(JSON.parse(rawKeywords)).filter(Boolean);
    }

    get searchObjectKeywordsAsPills() {
        return this.searchObjectKeywordsRaw.map((_) => ({ label: _, name: _ }));
    }

    get objectsColumns() {
        return [
            {
                label: 'Label',
                fieldName: 'Label',
                type: 'text'
            },
            {
                label: 'QualifiedApiName',
                fieldName: 'QualifiedApiName',
                type: 'customCodeSnippet'
            },
            {
                label: 'NamespacePrefix',
                fieldName: 'NamespacePrefix',
                type: 'customBadge'
            }
        ];
    }

    get objectsData() {
        return cloneObject(this.foundObjects);
    }

    get doDisableOlsViewerSection() {
        return isEmpty(this.selectedObjectName);
    }

    get doDisableFlsViewerSection() {
        return isEmpty(this.selectedObjectName);
    }

    get isSelectedObjectEligible() {
        return isEmpty(this.wiredObjectInfo?.error);
    }

    get wiredObjectError() {
        return this.wiredObjectInfo?.error && parseError(this.wiredObjectInfo.error);
    }

    get olsColumns() {
        return [
            {
                label: 'CRUD Permission',
                fieldName: 'permission',
                type: 'customCodeSnippet'
            },
            {
                label: 'Value',
                fieldName: 'value',
                type: 'boolean'
            }
        ];
    }

    get olsData() {
        const { queryable, searchable, createable, updateable, deletable } = this.wiredObjectInfo?.data || {};
        const data = [];
        for (const [propName, value] of Object.entries({
            queryable,
            searchable,
            createable,
            updateable,
            deletable
        })) {
            data.push({ permission: capitalize(propName), value });
        }
        return data;
    }

    get flsColumns() {
        return [
            {
                label: 'Label',
                fieldName: 'label',
                type: 'text'
            },
            {
                label: 'API Name',
                fieldName: 'apiName',
                type: 'customCodeSnippet'
            },
            {
                label: 'Data Type',
                fieldName: 'dataType',
                type: 'customCodeSnippet'
            },
            {
                label: 'Creatable?',
                fieldName: 'creatable',
                type: 'boolean'
            },
            {
                label: 'Updateable?',
                fieldName: 'updateable',
                type: 'boolean'
            }
        ];
    }

    get flsData() {
        return Object.values(this.wiredObjectInfo?.data?.fields || {})
            .map(({ label, apiName, dataType, creatable, updateable }) => ({ label, apiName, dataType, creatable, updateable }))
            .filter(({ label, apiName }) => {
                if (isNotEmpty(this.searchFieldKeyword)) {
                    return (
                        containsIgnoreCase(label, this.searchFieldKeyword) || containsIgnoreCase(apiName, this.searchFieldKeyword)
                    );
                }
                return true;
            });
    }

    get $progressSlider() {
        return this.refs.progressSlider;
    }

    async connectedCallback() {
        await this.searchObjects();
    }

    async handleSearchObjectKeywordChange(event) {
        this.searchObjectKeyword = event.detail.value;
        await this.searchObjects();
    }

    async handleSearchObjectKeywordClick(event) {
        const { name } = event.target.dataset;
        this.searchObjectKeyword = name;
        this.refs.objectSearchInput.value = this.searchObjectKeyword;
        await this.searchObjects();
    }

    handleSearchObjectKeywordRemove(event) {
        event.preventDefault();
        const { name } = event.target.dataset;
        this.removeSearchObjectKeyword(name);
        this.foundObjects = cloneObject(this.foundObjects); // Simulate component re-render;
    }

    handlePrevious(event) {
        event.preventDefault();
        this.$progressSlider.previous();
    }

    handleNext(event) {
        event.preventDefault();
        this.$progressSlider.next();
    }

    handleSelectObject(event) {
        const { selectedRows = [], config = {} } = event.detail;
        if (config.action === 'rowSelect') {
            const { QualifiedApiName } = selectedRows[0];
            this.selectedObjectName = QualifiedApiName;
            this.$progressSlider.next();
        }
    }

    handleSearchFieldKeywordChange(event) {
        this.searchFieldKeyword = event.detail.value;
    }

    // Service Methods

    async searchObjects() {
        try {
            this.loading = true;
            this.foundObjects = cloneObject(await searchObjectsByKeywordApex({ keyword: this.searchObjectKeyword }));
            if (!isEmptyArray(this.foundObjects) && isNotEmpty(this.searchObjectKeyword)) {
                this.addSearchObjectKeyword(this.searchObjectKeyword);
            }
        } catch (error) {
            const { message } = parseError(error);
            Toastify.error({ message });
        } finally {
            this.loading = false;
        }
    }

    addSearchObjectKeyword(keywordToAdd) {
        const last5SearchKeywords = Array.from(new Set([keywordToAdd, ...this.searchObjectKeywordsRaw]))
            .filter(Boolean)
            .slice(0, 5);
        localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(last5SearchKeywords));
    }

    removeSearchObjectKeyword(keywordToRemove) {
        const filteredKeyword = this.searchObjectKeywordsRaw.filter((keyword) => keyword !== keywordToRemove);
        localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(filteredKeyword));
    }
}
