import { LightningElement, api } from 'lwc';
import { cloneObject, isNotEmpty, parseError } from 'c/utilities';

const $SAMPLE_ERROR = {
    status: 400,
    body: {
        message: 'An error occurred while trying to update the record. Please try again.',
        statusCode: 400,
        enhancedErrorType: 'RecordError',
        output: {
            errors: [
                {
                    constituentField: null,
                    duplicateRecordError: {
                        matchResults: [
                            {
                                apiName: 'Contact',
                                isAllowSave: false,
                                matchRecordIds: ['0035t00001BlsFPAAZ', '0035t00001BlWDeAAN'],
                                matchRule: 'MatchByNameAndPhone',
                                objectLabel: 'Contact',
                                objectLabelPlural: 'Contacts',
                                themeInfo: {
                                    color: '9602C7',
                                    iconUrl:
                                        'https://speed-speed-821-dev-ed.scratch.my.salesforce.com/img/icon/t4v35/standard/contact_120.png'
                                }
                            }
                        ]
                    },
                    errorCode: 'DUPLICATES_DETECTED',
                    field: null,
                    fieldLabel: null,
                    message: 'Duplicate Contact detected!'
                }
            ],
            fieldErrors: {}
        }
    },
    headers: {},
    ok: false,
    statusText: 'Bad Request',
    errorType: 'fetchResponse'
};

// Templates;
import emptyTemplate from './empty.html';
import errorTemplate from './errorAlert.html';

const $EXPANDED_CLASSNAME = 'expanded';
export default class ErrorAlert extends LightningElement {
    @api value = null;

    get errorObj() {
        try {
            return parseError(cloneObject(this.value));
        } catch (error) {
            return { message: 'Failed to parse error object!' };
        }
    }

    get message() {
        return this.errorObj.message;
    }

    get code() {
        return this.errorObj.code || 'Unknown';
    }

    get details() {
        return this.errorObj.details || {};
    }

    get preformattedDetails() {
        return JSON.stringify(this.details || {}, null, 2);
    }

    get hasError() {
        return Boolean(this.message);
    }

    get hasDetails() {
        return isNotEmpty(this.details);
    }

    constructor() {
        super();
        // Uncomment for testing purposes;
        // this.value = $SAMPLE_ERROR;
    }

    render() {
        return this.hasError ? errorTemplate : emptyTemplate;
    }

    handleToggleShowMore() {
        this.refs.detailsPanel.classList.toggle($EXPANDED_CLASSNAME);
    }
}
