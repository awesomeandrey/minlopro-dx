import { LightningElement, api, track, wire } from 'lwc';
import EMP from 'lightning/empApi';
import LogModal from 'c/logModal';
import $Toastify from 'c/toastify';
import { isNotEmpty, parseError, to, cloneObject, flatten, uniqueId, wait, isEmptyArray, copyToClipboard } from 'c/utilities';
import { MULTI_PICKLIST_SEPARATOR } from 'c/comboboxUtils';

import $UserId from '@salesforce/user/Id';

// Apex;
import getUserInfoByIdApex from '@salesforce/apex/SystemInfoController.getUserInfoById';
import getLoggerSettingsBySetupOwnersApex from '@salesforce/apex/LogsMonitorPanelController.getLoggerSettingsBySetupOwners';

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
    @api mode = 'compact';

    @track isEmpEnabled = false;
    @track subscription = {};
    @track error = {};
    @track isMuted = false;
    @track logsByTransactionId = {};
    @track lastTimestampByTransactionId = {};
    @track selectedLogOwnerIds = [];
    /**
     * The list of setup owner definitions for which logger settings are created & active.
     * Sample setup owner definition:
     * {
     *   ownerId - User or Profile ID (e.g. '00e1l000000IM9GAAW')
     *   name - User or Profile Name (e.g. 'DigEx Profile')
     *   type - Setup Owner Type (e.g. 'user' or 'profile')
     * }
     * Note that owr-default setting is ignored!
     * @type {[]}
     */
    @track logOwners = [];

    get logOwnerOptions() {
        return this.logOwners.map(({ name, ownerId, type }) => {
            return {
                label: `${name} (${type.toUpperCase()})`,
                value: ownerId,
                iconName: type === 'user' ? 'standard:user' : 'standard:individual'
            };
        });
    }

    get selectedLogOwnersAsValue() {
        return this.logOwners
            .filter(({ ownerId }) => {
                return this.selectedLogOwnerIds.includes(ownerId);
            })
            .map(({ ownerId }) => ownerId)
            .join(MULTI_PICKLIST_SEPARATOR);
    }

    get selectedLogOwnersAsPills() {
        return this.logOwners
            .filter(({ ownerId }) => {
                return this.selectedLogOwnerIds.includes(ownerId);
            })
            .map(({ name, ownerId, type }) => {
                return {
                    type: 'avatar',
                    label: name,
                    name: ownerId,
                    fallbackIconName: type === 'user' ? 'standard:user' : 'standard:individual'
                };
            });
    }

    get comboboxPlaceholder() {
        if (isEmptyArray(this.logOwners)) {
            return '- There are no Log Owners configured -';
        }
        return 'Select Log Owners To Track';
    }

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
        return `${this.labels.logsAmountAllLbl}: ${Object.values(this.logsByTransactionId).flat().length}`;
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
        return isNotEmpty(this.logsByTransactionId);
    }

    get backgroundSvgUrl() {
        return `${COMMONS_ASSETS}/svg/background1.svg`;
    }

    get disableButtons() {
        return this.hasError || !this.hasLogs;
    }

    get isDetailedMode() {
        return !this.isCompactMode;
    }

    get isCompactMode() {
        return this.mode === 'compact';
    }

    get normalizedColumns() {
        return [
            {
                fieldName: 'index',
                label: '#',
                initialWidth: 100,
                visible: true
            },
            {
                fieldName: 'author',
                label: 'Author',
                visible: true,
                cellAttributes: {
                    iconName: {
                        fieldName: 'authorIconName'
                    }
                }
            },
            {
                fieldName: 'data.Quiddity',
                label: 'Quiddity',
                initialWidth: 150,
                visible: this.isDetailedMode
            },
            {
                fieldName: this.isCompactMode ? 'unknownFieldName' : 'debugLevel',
                label: 'Level',
                initialWidth: 100,
                cellAttributes: {
                    iconName: { fieldName: 'iconName' },
                    iconPosition: 'left'
                },
                visible: true
            },
            {
                fieldName: 'stacktrace',
                label: 'Class > Method > Line',
                wrapText: true,
                visible: true
            },
            {
                fieldName: 'data.Message',
                label: 'Message',
                wrapText: true,
                iconName: 'utility:apex',
                visible: true
            },
            {
                fieldName: 'elapsed',
                label: 'Elapsed (ms)',
                initialWidth: 150,
                visible: this.isDetailedMode
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        { label: 'View Details', name: 'viewDetails' },
                        { label: 'Copy Message', name: 'copyMessage' }
                    ]
                },
                visible: true
            }
        ].filter(({ visible = false }) => Boolean(visible));
    }

    get normalizedData() {
        const clonedLogEntries = cloneObject(Object.values(this.logsByTransactionId));
        return clonedLogEntries.reduce((accumulator = [], logs = [], currentIndex) => {
            const firstLog = logs[0];
            // Check whether log should be shown based on predefined log owners;
            const doShow = this.selectedLogOwnerIds.some((_) => {
                return firstLog.logOwnerIds.includes(_);
            });
            if (!doShow) {
                return accumulator;
            }
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

    get runningUserId() {
        return this.wiredRunningUser?.data?.Id;
    }

    get runningUserProfileId() {
        return this.wiredRunningUser?.data?.ProfileId;
    }

    get $treeGrid() {
        return this.template.querySelector('lightning-tree-grid');
    }

    @wire(getUserInfoByIdApex, { userId: $UserId })
    wiredRunningUser = {};

    // Lifecycle methods;

    async connectedCallback() {
        // Subscribe to EMP;
        this.subscribe();
        // Retrieve info about all eligible log filters;
        const [error, result] = await to(getLoggerSettingsBySetupOwnersApex());
        if (isNotEmpty(error)) {
            this.parseErrorAndShow(error);
            return;
        }
        this.logOwners = cloneObject(result);
        // Auto-select option for running user (if applicable);
        wait(() => {
            const logSettingsForRunningUser = this.logOwners.filter(({ ownerId }) => {
                return [this.runningUserId, this.runningUserProfileId].includes(ownerId);
            });
            if (isNotEmpty(logSettingsForRunningUser)) {
                this.selectedLogOwnerIds = logSettingsForRunningUser.map(({ ownerId }) => ownerId);
            }
        });
    }

    disconnectedCallback() {
        this.unsubscribe();
    }

    errorCallback(error, stack) {
        console.error('LogMonitor.js', error, stack);
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
            await LogModal.open({
                label: 'Log Details',
                size: 'small',
                value: cloneObject(row)
            });
        } else if (action.name === 'copyMessage') {
            const logToCopy = row['data.Message'];
            const [error] = await to(copyToClipboard(logToCopy));
            if (!!error) {
                $Toastify.error({ message: `Could not copy log message due to: ${error}` });
            } else {
                $Toastify.info({ message: 'Copied log message to clipboard.' });
            }
        }
    }

    handleSelectLogOwner(event) {
        const { selectedOptions = [] } = event.detail;
        this.selectedLogOwnerIds = cloneObject(selectedOptions.map(({ value }) => value));
    }

    handleRemoveLogOwner(event) {
        const ownerIdToRemove = event.detail.item.name;
        this.selectedLogOwnerIds = this.selectedLogOwnerIds.filter((_) => _ !== ownerIdToRemove);
    }

    handleToggleMode() {
        this.mode = this.isCompactMode ? 'detailed' : 'compact';
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
            // Control EMP API debug mode;
            EMP.setDebugFlag(true);
            // Subscribe to PE channel;
            const channel = '/event/Log__e';
            // Store 'subscription';
            this.subscription = await EMP.subscribe(channel, -1, this.handleLogEvent.bind(this));
            // Add error handler;
            EMP.onError(this.parseErrorAndShow.bind(this));
            return Promise.resolve(true);
        } else {
            return Promise.reject({
                message: `EMP API is not enabled/available for the running user.`
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

    handleLogEvent(logPlatformEvent) {
        if (this.isMuted) {
            return;
        }
        const {
            Level__c: debugLevel,
            AuthorId__c: authorId,
            AuthorProfileId__c: authorProfileId,
            Data__c: dataAsString,
            TransactionId__c: transactionId,
            CreatedDate: createdDate
        } = logPlatformEvent.data.payload;
        const matchedLogOwners = this.findMatchedLogOwners({ authorId, authorProfileId });
        if (isNotEmpty(matchedLogOwners)) {
            // Normalize PE payload;
            const data = JSON.parse(dataAsString);
            const logItem = flatten({
                uid: uniqueId(),
                transactionId,
                debugLevel,
                authorId,
                createdDate,
                data
            });

            // Custom attributes;
            logItem.stacktrace = (() => {
                let dto = JSON.parse(data['StackTrace']) || {};
                return dto['toString'];
            })();
            logItem.iconName = debugLevel === 'ERROR' ? 'utility:bug' : 'utility:info';
            logItem.logOwnerIds = matchedLogOwners.map(({ ownerId }) => ownerId);

            // Extract log author;
            logItem.author = matchedLogOwners[0].name;
            logItem.authorIconName = matchedLogOwners[0].type === 'user' ? 'standard:user' : 'standard:individual';

            // Calculate 'elapsed' time for the context;
            const currentTimestamp = new Date(createdDate).getTime();
            const lastTimestamp = this.lastTimestampByTransactionId[transactionId] || currentTimestamp;
            logItem.elapsed = currentTimestamp - lastTimestamp;
            this.lastTimestampByTransactionId[transactionId] = lastTimestamp;

            // Push log item into the store;
            const existingLogs = this.logsByTransactionId[transactionId] || [];
            this.logsByTransactionId[transactionId] = [...existingLogs, logItem];

            // Render Tree Grid;
            this.logsByTransactionId = cloneObject(this.logsByTransactionId);
        }
    }

    reset() {
        this.error = {};
        this.logsByTransactionId = {};
        this.lastTimestampByTransactionId = {};
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

    findMatchedLogOwners(logEvent) {
        const { authorId, authorProfileId } = logEvent;
        return this.logOwners
            .filter(({ ownerId }) => this.selectedLogOwnerIds.includes(ownerId))
            .filter(({ ownerId }) => ownerId === authorId || ownerId === authorProfileId)
            .sort(({ type: typeA }, { type: typeB }) => {
                // User-level log settings take precedence over Profile-level log settings;
                return typeB.localeCompare(typeA);
            });
    }
}
