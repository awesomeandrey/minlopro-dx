import { LightningElement, api } from 'lwc';

// Custom CSS stylesheets/classes;
import $Stylesheet from 'c/progressSliderCss';

export default class ProgressSliderSection extends LightningElement {
    static stylesheets = [$Stylesheet];

    @api label;
    @api iconName = 'utility:arrow_right';
}
