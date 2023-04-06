import { LightningElement, api, track } from 'lwc';
import { uniqueId } from 'c/utilities';

export default class StencilSkeleton extends LightningElement {
    @api repeat = 1;
    @api shortLines = 2;
    @api mediumLines = 2;
    @api longLines = 2;

    @track uuid;

    constructor() {
        super();
        this.uuid = uniqueId();
    }

    get skeletons() {
        const repeat = Number(this.repeat);
        if (isNaN(repeat) || repeat < 0) {
            return [`skeleton-${this.uuid}-1`];
        }
        return new Array(repeat).fill('skeleton').map((value, index) => {
            return `${value}-${this.uuid}-${index + 1};`;
        });
    }
}
