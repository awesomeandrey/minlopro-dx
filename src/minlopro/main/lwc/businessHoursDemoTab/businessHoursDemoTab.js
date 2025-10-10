import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { isNotEmpty } from 'c/utilities';

import getDefaultBusinessHoursApex from '@salesforce/apex/BusinessHoursController.getDefaultBusinessHours';
import calculateMetricsApex from '@salesforce/apex/BusinessHoursController.calculateMetrics';

export default class BusinessHoursDemoTab extends LightningElement {
    @track timezoneKey = 'Europe/Kiev';
    @track datetime1 = new Date().toISOString();
    @track datetime2 = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

    get timezones() {
        return ['Europe/Kiev', 'America/Los_Angeles', 'America/New_York', 'Europe/London', 'Europe/Paris'].map((key) => ({
            label: key,
            value: key
        }));
    }

    get stats() {
        return {
            'Default Business Hours': this.defaultBusinessHoursLabel,
            'Selected Timezone SID Key': this.timezoneKey,
            'Date #1 (UTC)': this.datetime1,
            'Date #2 (UTC)': this.datetime2
        };
    }

    get defaultBusinessHoursLabel() {
        const { data } = this.wiredDefaultBusinessHours;
        if (isNotEmpty(data)) {
            return `${data.Name} (${data.TimeZoneSidKey})`;
        }
        return null;
    }

    get error() {
        return this.wiredCalculatedMetrics?.error;
    }

    get isDate1BusinessDay() {
        return this.wiredCalculatedMetrics?.data?.isBusinessDay;
    }

    get date1NextBusinessDay() {
        return this.wiredCalculatedMetrics?.data?.nextBusinessDay;
    }

    get date1And2Diff() {
        const ms = this.wiredCalculatedMetrics?.data?.diff;
        if (typeof ms !== 'number' || ms < 0) return '0h 0m 0s';
        const totalSeconds = Math.floor(ms / 1000);
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        return `${hours}h ${minutes}m ${seconds}s (${ms})`;
    }

    @wire(calculateMetricsApex, { datetime1: '$datetime1', datetime2: '$datetime2' })
    wiredCalculatedMetrics = {};

    @wire(getDefaultBusinessHoursApex)
    wiredDefaultBusinessHours = {};

    handleChangeTimezone(event) {
        this.timezoneKey = event.detail.value;
    }

    handleChangeDate1(event) {
        this.datetime1 = event.detail.value;
    }

    handleChangeDate2(event) {
        this.datetime2 = event.detail.value;
    }

    async handleReset() {
        await refreshApex(this.wiredCalculatedMetrics);
    }
}
