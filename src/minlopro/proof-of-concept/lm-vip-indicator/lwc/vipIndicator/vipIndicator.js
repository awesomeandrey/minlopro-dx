import { LightningElement, api, track, wire } from 'lwc';
import { log } from 'lightning/logger';
import { refreshApex } from '@salesforce/apex';
import { parseError, debounce } from 'c/utilities';

import isFeatureActiveApex from '@salesforce/apex/FeatureToggle.isActive';
import computeBannerApex from '@salesforce/apex/VipIndicatorController.computeBanner';

export default class VipIndicator extends LightningElement {
    @api recordId;
    @api debugMode = false;

    @track isFeatureEnabled = false;
    @track accountId = undefined;
    @track wiredBanner = {};

    @track debouncedRefresh = debounce(this.handleRefresh.bind(this), 700);

    get showBanner() {
        return this.normalizedBanner.doShow;
    }

    get bannerText() {
        const { message, logMessage } = this.normalizedBanner;
        if (this.debugMode && !!logMessage) {
            return `${message} | ${logMessage}`;
        }
        return message;
    }

    get normalizedBanner() {
        let banner = {
            doShow: false,
            isVip: false,
            message: null,
            logMessage: null,
            style: null
        };
        if (this.wiredBanner.data) {
            const { showBanner, isVip, message, logMessage } = this.wiredBanner.data;
            banner.doShow = this.debugMode || showBanner;
            banner.isVip = isVip;
            banner.message = message;
            banner.logMessage = logMessage;
            banner.style = (() => {
                if (isVip) return 'success';
                if (showBanner) return 'warning';
                return null;
            })();
        } else if (this.wiredBanner.error) {
            const { message: errorMessage } = parseError(this.wiredBanner.error);
            banner.doShow = true;
            banner.isVip = false;
            banner.message = errorMessage;
            banner.logMessage = null;
            banner.style = 'error';
        }
        return banner;
    }

    get theme() {
        switch (this.normalizedBanner.style) {
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
            this.accountId = this.recordId; // Entry point for Apex 'wire' below
        }
    }

    @wire(computeBannerApex, { accountId: '$accountId' })
    wireComputeBannerApex(wiredBanner) {
        // Store reference for cache refresh
        this.wiredBanner = wiredBanner;
        const { data, error } = wiredBanner;
        if (data === undefined && error === undefined) {
            return;
        }
        if (error) {
            console.error('VipIndicator.js', JSON.stringify(error));
        }
        this.submitLog(this.normalizedBanner);
    }

    submitLog({ isVip = false, message, logMessage = null }) {
        const logObj = {
            name: 'VIP Indicator',
            accountId: this.recordId,
            isVip: isVip,
            message: message,
            logMessage: logMessage
        };
        log(logObj); // Submit log to Event Monitoring
        if (this.debugMode) {
            console.warn('VipIndicator.js', JSON.stringify(logObj));
        }
    }

    handleRefresh(event) {
        event?.preventDefault();
        refreshApex(this.wiredBanner);
    }
}
