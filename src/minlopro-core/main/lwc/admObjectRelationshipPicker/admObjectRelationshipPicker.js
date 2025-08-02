import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { isEmptyArray, cloneObject } from 'c/utilities';

// Modes;
const CONTEXT_TO_PARENTS = 'context-to-parents';
const CONTEXT_TO_CHILDREN = 'context-to-children';

export default class AdmObjectRelationshipPicker extends LightningElement {
    /**
     * Context object API name to start digging from.
     * @type {string}
     */
    @api objectApiName;
    /**
     * Relationship picker mode. 2 modes supported: context-to-parent & context-to-child.
     * @type {string}
     */
    @api mode;
    /**
     * Maximum relationships depth.
     * @type {number}
     */
    @api maxDepth = 1;

    @track selectedOptionKey;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    get normalizedMaxDepth() {
        return this.maxDepth - 1;
    }

    get relationshipOptions() {
        if (this.mode === CONTEXT_TO_PARENTS) return this.parentRelationshipOptions;
        if (this.mode === CONTEXT_TO_CHILDREN) return this.childRelationshipOptions;
        return null;
    }

    get hasRelationshipOptions() {
        return !isEmptyArray(this.relationshipOptions);
    }

    get parentRelationshipOptions() {
        // Option item prototype (for parent relationship);
        const prototypeObject = {
            get key() {
                return `${this.apiName}-${this.spanning}`;
            },
            get formattedLabel() {
                return `${this.label}`;
            }
        };
        // Build options;
        return Object.values(this.objectInfo?.data?.fields || [])
            .filter(({ reference = false, referenceToInfos = [] }) => {
                if (reference) {
                    // Exclude polymorphic lookups;
                    return referenceToInfos.length === 1;
                }
                // And include the rest;
                return true;
            })
            .map(({ reference = false, apiName, label, dataType, relationshipName, referenceToInfos = [] }) => {
                if (reference) {
                    return { apiName, label, dataType, relationshipName, referencedObjectName: referenceToInfos[0].apiName };
                } else {
                    return { apiName, label, dataType };
                }
            })
            .map((_) => {
                let directField = Object.setPrototypeOf({ ..._, spanning: false }, prototypeObject);
                if (_.relationshipName && _.referencedObjectName) {
                    let spanningRelationship = Object.setPrototypeOf({ ..._, spanning: true }, prototypeObject);
                    return this.maxDepth <= 1 ? [directField] : [directField, spanningRelationship];
                } else {
                    return directField;
                }
            })
            .flat()
            .map((_) => Object.setPrototypeOf({ ..._, selected: this.selectedOptionKey === _.key }, _));
    }

    get childRelationshipOptions() {
        // Option item prototype (for child relationship);
        const prototypeObject = {
            get key() {
                return `${this.relationshipName}-${this.spanning}`;
            },
            get formattedLabel() {
                return `${this.relationshipName}`;
            }
        };
        // Build options;
        return Object.values(this.objectInfo?.data?.childRelationships || [])
            .map(({ childObjectApiName, fieldName, relationshipName }) => ({
                childObjectApiName,
                fieldName,
                relationshipName
            }))
            .map((_) => {
                let directRelationship = Object.setPrototypeOf({ ..._, spanning: false }, prototypeObject);
                let spanningRelationship = Object.setPrototypeOf({ ..._, spanning: true }, prototypeObject);
                return this.maxDepth <= 1 ? [directRelationship] : [directRelationship, spanningRelationship];
            })
            .flat()
            .map((_) => Object.setPrototypeOf({ ..._, selected: this.selectedOptionKey === _.key }, _));
    }

    get selectedRelationship() {
        return this.relationshipOptions.find(({ key }) => this.selectedOptionKey === key);
    }

    get normalizedSelectedRelationship() {
        const normalizedRelationship = cloneObject(this.selectedRelationship);
        // General properties cleanup;
        delete normalizedRelationship.key;
        delete normalizedRelationship.formattedLabel;
        delete normalizedRelationship.spanning;
        delete normalizedRelationship.selected;
        return normalizedRelationship;
    }

    get hasSpanningReference() {
        return this.selectedRelationship?.spanning ?? false;
    }

    get spanningObjectName() {
        if (this.hasSpanningReference) {
            if (this.mode === CONTEXT_TO_PARENTS) return this.selectedRelationship.referencedObjectName;
            if (this.mode === CONTEXT_TO_CHILDREN) return this.selectedRelationship.childObjectApiName;
        }
        return null;
    }

    handleRelationshipClick(event) {
        this.selectedOptionKey = event.currentTarget.dataset.key;
        if (this.hasSpanningReference) {
            // Clear selection (the payload contains empty array);
            this.dispatchEvent(new CustomEvent('select', { detail: [] }));
        } else {
            // Capture selection;
            this.dispatchEvent(
                new CustomEvent('select', {
                    detail: [this.normalizedSelectedRelationship]
                })
            );
        }
    }

    handleRelationshipSelection(event) {
        const nestedRelationships = event.detail;
        if (isEmptyArray(nestedRelationships)) {
            // Clear selection (the payload contains empty array);
            this.dispatchEvent(new CustomEvent('select', { detail: [] }));
        } else {
            // Capture selection;
            this.dispatchEvent(
                new CustomEvent('select', {
                    detail: [this.normalizedSelectedRelationship, nestedRelationships]
                })
            );
        }
    }
}
