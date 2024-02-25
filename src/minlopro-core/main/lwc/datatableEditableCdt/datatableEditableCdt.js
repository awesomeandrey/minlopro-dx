import { LightningElement } from 'lwc';

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

    constructor() {
        super();
        // Use environment variable in order to enable/disable debug mode;
        this.debugModeEnabled = '@SF_LWC_CDT_DEBUG_MODE_ENABLED'.toLowerCase() === 'true';
    }

    // Service Methods;

    escape() {
        if (this.$focusedInput) {
            this.log(`escape via "keydown" event`);
            // Simulate 'Escape' button click on focused input;
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
            // Force escape from cell edit panel via reserved/unofficial event;
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

    log(messageOrFunction, details) {
        if (this.debugModeEnabled) {
            let itemsToLog = [
                `${this.constructor.name}.js`,
                typeof messageOrFunction === 'function' ? `${messageOrFunction.name}()` : messageOrFunction,
                JSON.stringify(details)
            ];
            console.log(itemsToLog.filter((item) => item !== undefined).join(' | '));
        }
    }
}
