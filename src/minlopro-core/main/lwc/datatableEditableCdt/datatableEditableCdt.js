import { LightningElement } from 'lwc';

export default class DatatableEditableCdt extends LightningElement {
    context = null;
    fieldName = null;
    value = null;

    debugModeEnabled = false; // Turn on/off to identify bottlenecks;
    cdtClassName = null;

    get validity() {
        return { valid: true };
    }

    // Service Methods;

    escape() {
        this.debugModeEnabled && console.log(`${this.cdtClassName}.js | escape()`);
        // Force escape from cell edit panel;
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

    notify() {
        this.debugModeEnabled && console.log(`${this.cdtClassName}.js | notify()`);
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
        console.error(`${this.cdtClassName}.js | notifyError()`);
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
}
