import { LightningElement } from 'lwc';
import IMAGES from '@salesforce/resourceUrl/images';

export default class DigExWelcome extends LightningElement {
    get logoUrl() {
        return `${IMAGES}/MinloproAppLogo.png`;
    }
}
