import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { log } from 'lightning/logger';
import { parseError, debounce } from 'c/utilities';

import isFeatureActiveApex from '@salesforce/apex/FeatureToggle.isActive';
import checkVipStatusApex from '@salesforce/apex/VipIndicatorController.checkVipStatus';

export default class VipIndicator extends LightningElement {
    @api recordId;
    @api debugMode = false;

    @track isFeatureEnabled = false;
    @track bannerStyle;
    @track bannerText;
    @track showBanner = false;

    @track debouncedRefresh = debounce(this.handleRefresh.bind(this), 700);

    get theme() {
        switch (this.bannerStyle) {
            case 'success':
                return { className: 'slds-theme_success', iconName: 'utility:success', iconVariant: 'inverse' };
            case 'error':
                return { className: 'slds-theme_error', iconName: 'utility:error', iconVariant: 'inverse' };
            case 'warning':
                return { className: 'slds-theme_warning', iconName: 'utility:warning' };
            default:
                return { className: null, iconName: 'utility:emoji_average', iconVariant: 'inverse' };
        }
    }

    get themeClassName() {
        return ['slds-notify', 'slds-notify_alert', this.theme.className].join(' ');
    }

    get themeIconName() {
        return this.theme.iconName;
    }

    get themeIconVariant() {
        return this.theme.iconVariant;
    }

    @wire(isFeatureActiveApex, { featureName: 'EnableVipIndicator' })
    wireFeatureToggle({ data }) {
        this.isFeatureEnabled = data === true;
        if (this.isFeatureEnabled || this.debugMode) {
            this.debouncedRefresh();
        }
    }

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord() {
        if (this.isFeatureEnabled || this.debugMode) {
            this.debouncedRefresh();
        }
    }

    handleRefresh(event) {
        event?.preventDefault();
        this.showBanner = false;
        this.handleCheckVipStatus();
    }

    async handleCheckVipStatus() {
        // Invoke Party API and surface the outcome
        let banner = { isVip: false, logMessage: null };
        try {
            banner = await checkVipStatusApex({ accountId: this.recordId });
            const { showBanner, isVip, message, logMessage } = banner;
            this.bannerStyle = (() => {
                if (isVip) return 'success';
                if (showBanner) return 'warning';
                return null;
            })();
            this.bannerText = (() => {
                if (this.debugMode && !!logMessage) {
                    return `${message} | ${logMessage}`;
                }
                return message;
            })();
            this.showBanner = this.debugMode || showBanner;
        } catch (error) {
            console.error('VipIndicator.js', JSON.stringify(error));
            const { message: errorMessage } = parseError(error);
            banner.message = errorMessage;
            this.bannerStyle = 'error';
            this.bannerText = errorMessage;
            this.showBanner = true;
        } finally {
            const logObj = {
                name: 'VIP Indicator',
                accountId: this.recordId,
                isVip: banner.isVip,
                message: banner.message,
                logMessage: banner.logMessage
            };
            log(logObj); // Submit log to Event Monitoring
            if (this.debugMode) {
                console.warn('VipIndicator.js', JSON.stringify(logObj));
            }
        }
    }
}
