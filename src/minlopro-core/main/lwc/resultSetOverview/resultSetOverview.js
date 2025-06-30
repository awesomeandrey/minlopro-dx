import { LightningElement, api } from 'lwc';
import { isEmptyArray, isNotEmpty } from 'c/utilities';

import COMMONS_ASSETS from '@salesforce/resourceUrl/CommonsAssets';

export default class ResultSetOverview extends LightningElement {
    @api data = [];
    @api backgroundSvgUrl = `${COMMONS_ASSETS}/svg/background1.svg`;
    @api infoTextTitle = 'No Results Found';
    @api infoTextMessage = 'Try to refine search criteria';

    get hasData() {
        if (Array.isArray(this.data)) {
            return !isEmptyArray(this.data);
        }
        return isNotEmpty(this.data);
    }
}
