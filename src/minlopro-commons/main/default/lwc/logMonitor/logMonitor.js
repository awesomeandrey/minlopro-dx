import { LightningElement, track } from 'lwc';
import EMP from 'lightning/empApi';
import LightningAlert from 'lightning/alert';
import $Toastify from 'c/toastify';
import { isNotEmpty, parseError, to, cloneObject, flatten, uniqueId } from 'c/commons';

import USER_ID from '@salesforce/user/Id';

// Static Resources;
import COMMONS_ASSETS from '@salesforce/resourceUrl/CommonsAssets';

// Custom Labels:
import errorLbl from '@salesforce/label/c.Commons_Msg_Error';
import muteLbl from '@salesforce/label/c.Logger_Btn_Mute';
import unmuteLbl from '@salesforce/label/c.Logger_Btn_Unmute';
import clearAllLbl from '@salesforce/label/c.Logger_Btn_ClearAll';
import expandAllLbl from '@salesforce/label/c.Logger_Btn_ExpandAll';
import collapseAllLbl from '@salesforce/label/c.Logger_Btn_CollapseAll';
import logsAmountAllLbl from '@salesforce/label/c.Logger_Badge_LogsAmount';
import noLogsYetLbl from '@salesforce/label/c.Logger_Msg_NoLogsYet';
import enableLoggingLbl from '@salesforce/label/c.Logger_Info_EnableLogging';

export default class LogMonitor extends LightningElement {
    @track isEmpEnabled = false;
    @track subscription = {};
    @track error = {};
    @track isMuted = false;
    @track logsByContextId = {};
    @track lastTimestampByContextId = {};

    get labels() {
        return {
            errorLbl,
            muteLbl,
            unmuteLbl,
            clearAllLbl,
            expandAllLbl,
            collapseAllLbl,
            logsAmountAllLbl,
            noLogsYetLbl,
            enableLoggingLbl
        };
    }

    get logsAmountBadge() {
        return `${this.labels.logsAmountAllLbl}: ${
            Object.values(this.logsByContextId).flat().length
        }`;
    }

    get muteIconName() {
        return this.isMuted ? 'utility:volume_off' : 'utility:volume_high';
    }

    get muteButtonLabel() {
        return this.isMuted ? unmuteLbl : muteLbl;
    }

    get hasError() {
        return isNotEmpty(this.error);
    }

    get hasLogs() {
        return isNotEmpty(this.logsByContextId);
    }

    get backgroundSvgUrl() {
        return `${COMMONS_ASSETS}/svg/background1.svg`;
    }

    get disableButtons() {
        return this.hasError || !this.hasLogs;
    }

    get normalizedColumns() {
        return [
            {
                fieldName: 'index',
                label: '#',
                initialWidth: 100
            },
            {
                fieldName: 'data.Quiddity',
                label: 'Quiddity',
                initialWidth: 150,
                actions: []
            },
            {
                fieldName: 'debugLevel',
                label: 'Level',
                initialWidth: 100,
                cellAttributes: {
                    iconName: { fieldName: 'iconName' },
                    iconPosition: 'left'
                }
            },
            {
                fieldName: 'stacktrace',
                label: 'Class > Method > Line',
                wrapText: true,
                cellAttributes: {
                    class: 'slds-text-title'
                }
            },
            {
                fieldName: 'data.Message',
                label: 'Message',
                wrapText: true,
                iconName: 'utility:apex',
                cellAttributes: {
                    class: 'slds-text-title'
                }
            },
            {
                fieldName: 'elapsed',
                label: 'Elapsed (ms)',
                initialWidth: 150
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [{ label: 'View Details', name: 'viewDetails' }]
                }
            }
        ];
    }

    get normalizedData() {
        const clonedLogEntries = cloneObject(Object.values(this.logsByContextId));
        return clonedLogEntries.reduce((accumulator = [], logs = [], currentIndex) => {
            const firstLog = logs[0];
            if (logs.length > 1) {
                // Add remaining logs as child items;
                firstLog._children = logs.slice(1);
            }
            // Assign index;
            firstLog.index = currentIndex + 1;
            // Push to accumulator;
            accumulator.push(firstLog);
            return accumulator;
        }, []);
    }

    get $treeGrid() {
        return this.template.querySelector('lightning-tree-grid');
    }

    // Lifecycle methods;

    connectedCallback() {
        this.subscribe();
    }

    disconnectedCallback() {
        this.unsubscribe();
    }

    // Event Handlers;

    handleToggleMute() {
        this.isMuted = !this.isMuted;
        if (this.isMuted) {
            this.unsubscribe();
        } else {
            this.subscribe();
        }
    }

    handleClearAll() {
        this.reset();
    }

    handleExpandAll() {
        this.$treeGrid.expandAll();
    }

    handleCollapseAll() {
        this.$treeGrid.collapseAll();
    }

    async handleRowAction(event) {
        const { action, row } = event.detail;
        if (action.name === 'viewDetails') {
            const strippedLogDetails = Object.keys(row).reduce((_, key) => {
                if (
                    key.includes('.') &&
                    !key.toLowerCase().includes('Message'.toLocaleLowerCase())
                ) {
                    const normalizedKey = key.split('.')[1];
                    _[normalizedKey] = row[key];
                }
                return _;
            }, {});
            await LightningAlert.open({
                message: JSON.stringify(strippedLogDetails, null, 2),
                theme: 'info',
                label: 'Log Details'
            });
        }
    }

    // Utility Methods;

    subscribe() {
        to(this.subscribeToEvent()).catch(([error]) => {
            this.parseErrorAndShow(error);
        });
    }

    async subscribeToEvent() {
        this.isEmpEnabled = await EMP.isEmpEnabled();
        if (this.isEmpEnabled) {
            // Call this method with `true` parameter in order to enable EMP API debug mode;
            EMP.setDebugFlag(false);
            // Subscribe to PE channel;
            const channel = '/event/Log__e';
            // Store 'subscription';
            this.subscription = await EMP.subscribe(channel, -1, this.handleLogEvent.bind(this));
            // Add error handler;
            EMP.onError(this.parseErrorAndShow.bind(this));
            return Promise.resolve(true);
        } else {
            return Promise.reject({
                message: `EMP API is not enabled/available for the running user [${USER_ID}].`
            });
        }
    }

    unsubscribe() {
        to(this.unsubscribeFromEvent()).catch(([error]) => {
            this.parseErrorAndShow(error);
        });
    }

    async unsubscribeFromEvent() {
        if (this.isEmpEnabled && isNotEmpty(this.subscription)) {
            await EMP.unsubscribe(this.subscription);
        }
    }

    handleLogEvent(message) {
        if (this.isMuted) {
            return;
        }
        const {
            Level__c: debugLevel,
            AuthorId__c: authorId,
            Data__c: dataAsString,
            Context__c: contextId,
            CreatedDate: createdDate
        } = message.data.payload;
        if (authorId === USER_ID) {
            // Normalize PE payload;
            const data = JSON.parse(dataAsString);
            const logItem = flatten({
                uid: uniqueId(),
                contextId,
                debugLevel,
                authorId,
                createdDate,
                data
            });
            // Custom attributes;
            logItem.stacktrace = `${data.Class}.cls > ${data.Method}() > Line #${data.Line}`;
            logItem.iconName = debugLevel === 'ERROR' ? 'utility:bug' : 'utility:info';
            // Calculate 'elapsed' time for the context;
            const currentTimestamp = new Date(createdDate).getTime();
            const lastTimestamp = this.lastTimestampByContextId[contextId] || currentTimestamp;
            logItem.elapsed = currentTimestamp - lastTimestamp;
            this.lastTimestampByContextId[contextId] = lastTimestamp;
            // Push log item into the store;
            const existingLogs = this.logsByContextId[contextId] || [];
            this.logsByContextId[contextId] = [...existingLogs, logItem];
            // Render Tree Grid;
            this.logsByContextId = cloneObject(this.logsByContextId);
        }
    }

    reset() {
        this.error = {};
        this.logsByContextId = {};
        this.lastTimestampByContextId = {};
    }

    parseErrorAndShow(error) {
        const title = this.labels.errorLbl.toUpperCase(),
            { message, code, details } = parseError(error);
        // Alert end user;
        $Toastify.error({ title, message });
        // Define error details;
        this.error = { title, message };
        // Output error info to console;
        console.error('LogMonitor.js', { title, message, code, details });
    }
}
