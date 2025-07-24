import { LightningElement, api, track } from 'lwc';
import { cloneObject, isNotEmpty } from 'c/utilities';

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
 *
 * <c-adm-object-relationship-picker-container
 *  title="My Custom Field Path"
 *  object-api-name="Opportunity"
 *  mode="context-to-parents"
 * ></c-adm-object-relationship-picker-container>
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

    get isContextToParentsMode() {
        return this.mode === CONTEXT_TO_PARENTS;
    }

    get isContextToChildrenMode() {
        return this.mode === CONTEXT_TO_CHILDREN;
    }

    get maxDepth() {
        return MAX_RELATIONSHIPS_DEPTH;
    }

    get normalizedRelationshipPath() {
        if (this.isContextToParentsMode) return this.normalizedParentRelationshipPath;
        if (this.isContextToChildrenMode) return this.normalizedChildRelationshipPath;
        return null;
    }

    get normalizedParentRelationshipPath() {
        return this.relationshipsArray
            .flat(MAX_RELATIONSHIPS_DEPTH)
            .map(({ apiName, relationshipName, referencedObjectName }, index, array) => {
                let isLastElement = index === array.length - 1;
                if (isLastElement) {
                    return apiName;
                } else {
                    return `${relationshipName} (${referencedObjectName})`;
                }
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

    get selectedFieldPath() {
        if (this.isContextToParentsMode) {
            return this.relationshipsArray
                .flat(MAX_RELATIONSHIPS_DEPTH)
                .reduce((accumulator, currentValue, currentIndex, array) => {
                    let isLastElement = currentIndex === array.length - 1;
                    return [...accumulator, isLastElement ? currentValue['apiName'] : currentValue['relationshipName']];
                }, [])
                .join('.');
        }
        return null;
    }

    get selectedFieldPathType() {
        if (isNotEmpty(this.selectedFieldPath)) {
            return this.relationshipsArray.flat(MAX_RELATIONSHIPS_DEPTH).at(-1).dataType;
        }
        return null;
    }

    get selectedChildRelationshipPath() {
        if (this.isContextToChildrenMode) {
            // TODO;
            return null;
        }
        return null;
    }

    handleSelect(event) {
        this.relationshipsArray = cloneObject(event.detail);
        // console.table(cloneObject(this.relationshipsArray));
        this.dispatchEvent(new CustomEvent('select', { detail: { value: this.selectedFieldPath } }));
    }
}
