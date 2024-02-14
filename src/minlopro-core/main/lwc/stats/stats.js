import { LightningElement, api } from 'lwc';
import { isEmpty, uniqueId } from 'c/utilities';

export default class Stats extends LightningElement {
    @api label = 'Stats';
    @api value = {};
    @api iconName = 'standard:setup_modal';

    get statsAsArray() {
        if (isEmpty(this.value)) {
            return [];
        }
        return Object.entries(this.value)
            .map(([propName, propValue]) => {
                let statLabel = { isLabel: true, value: propName, key: uniqueId() };
                let statValue = { isValue: true, value: propValue, key: uniqueId() };
                return [statLabel, statValue];
            })
            .flat();
    }
}
