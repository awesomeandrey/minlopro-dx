import { LightningElement, api, track, wire } from 'lwc';
import { cloneObject } from 'c/utilities';

// Modes;
const CONTEXT_TO_PARENTS = 'context-to-parents';
const CONTEXT_TO_CHILDREN = 'context-to-children';

// Spanning Relationships Depth;
const MAX_RELATIONSHIPS_DEPTH = 3;

/**
 * Parent Relationship object structure.
 * {
 *     "label": "Plan",
 *     "apiName": "OCE__Plan__c",
 *     "relationshipName": "OCE__Plan__r",
 *     "referencedObjectName": "OCE__Plan__c"
 * }
 *
 * Child Relationship object structure.
 * {
 *     "childObjectApiName: "OCE__MeetingMember__c",
 *     "fieldName: "OCE__Meeting__c",
 *     "relationshipName: "OCE__MeetingMember__r"
 * }
 */
export default class AdmObjectRelationshipPickerContainer extends LightningElement {
    /**
     * Picker element title.
     */
    @api title;
    /**
     * Context object API name to start digging from.
     */
    @api objectApiName;
    /**
     * Relationship picker mode. 2 modes supported: context-to-parent & context-to-child.
     * @type {string}
     */
    @api mode;
    /**
     * The array with all nested relationships (may contain nested arrays as the relationship depth grows).
     * Use `Array.prototype.flat(depth)` or/and `Array.prototype.reduce(depth)` methods to work with it.
     * @type {[]}
     */
    @track relationshipsArray = [];

    get maxDepth() {
        return MAX_RELATIONSHIPS_DEPTH;
    }

    get normalizedRelationshipPath() {
        if (this.mode === CONTEXT_TO_PARENTS) return this.normalizedParentRelationshipPath;
        if (this.mode === CONTEXT_TO_CHILDREN) return this.normalizedChildRelationshipPath;
        return [];
    }

    get normalizedParentRelationshipPath() {
        return this.relationshipsArray
            .flat(MAX_RELATIONSHIPS_DEPTH)
            .map(({ apiName, relationshipName, referencedObjectName }, index, array) => {
                return `${index === array.length - 1 ? apiName : relationshipName} (${referencedObjectName})`;
            })
            .join(' > ');
    }

    get normalizedChildRelationshipPath() {
        return this.relationshipsArray
            .flat(MAX_RELATIONSHIPS_DEPTH)
            .map(({ relationshipName, childObjectApiName }) => {
                return `${relationshipName} (${childObjectApiName})`;
            })
            .join(' > ');
    }

    handleRelationshipSelection(event) {
        this.relationshipsArray = cloneObject(event.detail);
        console.log(JSON.stringify(this.relationshipsArray));
        // TODO - fire event above the hierarchy;
        debugger;
    }
}
