import { LightningElement } from 'lwc';
import { log as $log } from 'lightning/logger';

export default class DatatableEditableCdt extends LightningElement {
    /**
     * Custom properties that identify particular cell.
     */
    context = null; // Row key value;
    fieldName = null;
    value = null;
    // Properties provided by CDT engine;
    wrapText = false;

    /**
     * Always override this getter as @api property.
     * @returns {{valid: boolean}}
     */
    get validity() {
        return { valid: true };
    }

    /**
     * Override this getter with focusable element (e.g. input)
     * in order to correctly escape from cell edit mode.
     */
    get $focusedInput() {
        return null;
    }

    get textClassName() {
        return this.wrapText ? 'slds-hyphenate' : 'slds-truncate';
    }

    constructor() {
        super();
        // Use environment variable in order to enable/disable debug mode;
        this.debugModeEnabled = '${SF_LWC_CDT_DEBUG_MODE_ENABLED}'.toLowerCase() === 'true';
    }

    // Service Methods;

    escape() {
        if (this.$focusedInput) {
            this.log(`escape via "keydown" event`);
            /**
             * Simulate 'Escape' button click on focused input.
             * Open browser developer tools > top/YOUR_ORG_URL/components/lightning/datatable.js file > search for 'ESCAPE' keyword.
             */
            const escapeEvent = new KeyboardEvent('keydown', {
                composed: true,
                bubbles: true,
                cancelable: false,
                key: 'Escape',
                keyCode: 27,
                code: 'Escape',
                which: 27
            });
            this.$focusedInput.focus();
            this.$focusedInput.dispatchEvent(escapeEvent);
        } else {
            this.log(`escape via "ieditfinished" event`);
            /**
             * Force escape from cell edit panel via reserved/unofficial event.
             * Open browser developer tools > top/YOUR_ORG_URL/components/lightning/datatable.js file > search for 'ieditfinished' keyword.
             */
            this.dispatchEvent(
                new CustomEvent('ieditfinished', {
                    composed: true,
                    bubbles: true,
                    cancelable: false,
                    detail: {
                        reason: 'lost-focus',
                        rowKeyValue: this.context,
                        colKeyValue: 'unknown'
                    }
                })
            );
        }
    }

    notify() {
        this.log(this.notify);
        // Force changes updated;
        this.dispatchEvent(
            new CustomEvent('cellchange', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    draftValues: [
                        {
                            ['context']: this.context,
                            [this.fieldName]: this.value
                        }
                    ]
                }
            })
        );
    }

    notifyError(errorObj = {}) {
        this.log(this.notifyError);
        // Force changes updated;
        this.dispatchEvent(
            new CustomEvent('cellerror', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    ['context']: this.context,
                    ['fieldName']: this.fieldName,
                    ['error']: errorObj
                }
            })
        );
    }

    log(messageOrFunction, details, type = 'info') {
        if (this.debugModeEnabled) {
            let logMessage = [
                `${this.constructor.name}.js`,
                typeof messageOrFunction === 'function' ? `${messageOrFunction.name}()` : messageOrFunction,
                JSON.stringify(details)
            ]
                .filter((item) => item !== undefined)
                .join(' | ');
            // Log to browser console;
            if (type === 'error') {
                console.error(logMessage);
            } else {
                console.log(logMessage);
            }
            /**
             * Log via Lightning Logger. All logs are stored in 'EventLogFile' standard object.
             * See https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_lightninglogger.htm
             */
            $log(logMessage);
        }
    }
}
