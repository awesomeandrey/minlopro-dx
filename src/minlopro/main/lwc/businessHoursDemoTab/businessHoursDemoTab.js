import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isEmpty, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

import getDefaultBusinessHoursApex from '@salesforce/apex/BusinessHoursController.getDefaultBusinessHours';
import getBusinessHoursApex from '@salesforce/apex/BusinessHoursController.getBusinessHours';
import calculateMetricsByBusinessHoursApex from '@salesforce/apex/BusinessHoursController.calculateMetricsByBusinessHours';

/**
 * NOTE: Salesforce does not allow deletion of Business Hours records.
 * Instead, set Active = FALSE to deactivate them. Keep your org clean by avoiding unnecessary Business Hours.
 */
export default class BusinessHoursDemoTab extends LightningElement {
    @track selectedBusinessHoursId = null;
    @track selectedTimezoneKey = null;
    @track selectedNextSmsDelayHour = '3';
    @track datetime1 = new Date().toISOString();
    @track datetime2 = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
    @track datetimeMetricsData = [];

    get selectedBusinessHours() {
        return this.bhData.find(({ Id }) => Id === this.selectedBusinessHoursId);
    }

    get businessHours() {
        return this.bhData.map(({ Id, Name }) => ({
            label: Name,
            value: Id
        }));
    }

    get businessHoursTimezones() {
        return this.bhData.map(({ TimeZoneSidKey: key }) => ({
            label: key,
            value: key
        }));
    }

    get nextSmsDelayHours() {
        return [3, 5, 10, 12, 24, 48].map((num) => ({ label: `${num} hours`, value: `${num}` }));
    }

    get stats() {
        return {
            'Selected Business Hours ID': this.selectedBusinessHoursId,
            'Selected Business Hours Name': this.selectedBusinessHours?.Name,
            'Selected Timezone SID Key': this.selectedTimezoneKey,
            'Selected Next SMS Delay Hours': this.selectedNextSmsDelayHour,
            'Date #1 (UTC)': this.datetime1
        };
    }

    get error() {
        return this.wiredDefaultBusinessHours?.error || this.wiredBusinessHours?.error;
    }

    get bhColumns() {
        return [
            {
                label: 'Business Hours',
                fieldName: 'Id',
                type: 'customLookup',
                typeAttributes: {
                    objectApiName: 'BusinessHours'
                }
            },
            {
                label: 'Time Zone ID',
                fieldName: 'TimeZoneSidKey',
                type: 'customBadge'
            },
            {
                label: 'Is Active?',
                fieldName: 'IsActive',
                type: 'boolean'
            },
            {
                label: 'Is Default?',
                fieldName: 'IsDefault',
                type: 'boolean'
            }
        ];
    }

    get bhData() {
        if (isEmpty(this.wiredBusinessHours.data)) {
            return [];
        }
        return cloneObject(this.wiredBusinessHours.data);
    }

    get datetimeMetricsColumns() {
        return [
            {
                label: 'Date/Time UTC',
                fieldName: 'formattedDatetimeStampUtc',
                type: 'customCodeSnippet'
            },
            {
                label: 'Target BH',
                fieldName: 'businessHoursId',
                type: 'customLookup',
                typeAttributes: {
                    objectApiName: 'BusinessHours'
                }
            },
            {
                label: 'Date/Time BH',
                fieldName: 'formattedDatetimeStampBh',
                type: 'customCodeSnippet'
            },
            {
                label: 'BH Time Zone ID',
                fieldName: 'businessHoursTimezone',
                type: 'customBadge'
            },
            {
                label: 'Is Working Hours?',
                fieldName: 'isWorkingHours',
                type: 'boolean'
            },
            {
                label: 'Next Start Date/Time BH',
                fieldName: 'formattedNextStartDatetimeBh',
                type: 'customCodeSnippet'
            }
        ];
    }

    get nextSmsMetricsColumns() {
        return [
            {
                label: 'Target BH',
                fieldName: 'businessHoursId',
                type: 'customLookup',
                typeAttributes: {
                    objectApiName: 'BusinessHours'
                }
            },
            {
                label: 'BH Time Zone ID',
                fieldName: 'businessHoursTimezone',
                type: 'customBadge'
            },
            {
                label: 'Date/Time BH',
                fieldName: 'formattedDatetimeStampBh',
                type: 'customCodeSnippet'
            },
            {
                label: 'Is Working Hours?',
                fieldName: 'isWorkingHours',
                type: 'boolean'
            },
            {
                label: `Date/Time BH + ${this.selectedNextSmsDelayHour} hours`,
                fieldName: 'formattedNextSmsDatetimeStampBh',
                type: 'customCodeSnippet'
            },
            {
                label: 'Is Next SMS Working Hours?',
                fieldName: 'isNextSmsWorkingHours',
                type: 'boolean'
            }
        ];
    }

    get disableDatetimeInputs() {
        return (
            isEmpty(this.selectedBusinessHoursId) ||
            isEmpty(this.selectedTimezoneKey) ||
            isEmpty(this.selectedNextSmsDelayHour) ||
            isEmpty(this.datetime1)
        );
    }

    @wire(getDefaultBusinessHoursApex)
    wiredDefaultBusinessHours = {};

    @wire(getBusinessHoursApex)
    wiredBusinessHours = {};

    handleChangeBusinessHours(event) {
        this.selectedBusinessHoursId = event.detail.value;
        this.selectedTimezoneKey = this.bhData.find(({ Id }) => Id === this.selectedBusinessHoursId)?.TimeZoneSidKey;
    }

    handleChangeNextSmsDelayHour(event) {
        this.selectedNextSmsDelayHour = event.detail.value;
    }

    handleChangeDate1(event) {
        this.datetime1 = event.detail.value;
    }

    async handleCalculateMetrics(event) {
        event.preventDefault();
        this.datetimeMetricsData = [];
        try {
            const promises = this.bhData.map(({ Id }) =>
                calculateMetricsByBusinessHoursApex({
                    businessHoursId: Id,
                    datetimeStamp: this.datetime1,
                    nextSmsHoursDelay: Number(this.selectedNextSmsDelayHour)
                })
            );
            const results = await Promise.all(promises);
            this.datetimeMetricsData = results.map(
                ({
                    businessHours,
                    datetimeStamp,
                    formattedDatetimeStampUtc,
                    formattedDatetimeStampBh,
                    formattedNextStartDatetimeBh,
                    isWorkingHours,
                    // Next SMS Date/Time Stamp Calculations
                    nextSmsDatetimeStamp,
                    formattedNextSmsDatetimeStampUtc,
                    formattedNextSmsDatetimeStampBh,
                    isNextSmsWorkingHours
                }) => ({
                    businessHoursId: businessHours.Id,
                    businessHoursTimezone: businessHours.TimeZoneSidKey,
                    datetimeStamp,
                    formattedDatetimeStampUtc,
                    formattedDatetimeStampBh,
                    formattedNextStartDatetimeBh,
                    isWorkingHours,
                    // Next SMS Date/Time Stamp Calculations
                    nextSmsDatetimeStamp,
                    formattedNextSmsDatetimeStampUtc,
                    formattedNextSmsDatetimeStampBh,
                    isNextSmsWorkingHours
                })
            );
        } catch (error) {
            const { message } = parseError(error);
            $Toastify.error({ message }, this);
        }
    }

    async handleReset() {
        await refreshApex(this.wiredDefaultBusinessHours);
        await refreshApex(this.wiredBusinessHours);
        this.datetimeMetricsData = [];
    }
}
