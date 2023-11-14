import { LightningElement, api } from 'lwc';

export default class Stencil extends LightningElement {
    @api height = 0.33; // REM
    @api width = 100; // %
    @api count = 1;

    get containerStyle() {
        return `${this.containerHeight}; ${this.containerWidth}`;
    }

    get containerHeight() {
        return `height: ${this.height}rem`;
    }

    get containerWidth() {
        if (!this.width) {
            return 'width: 100%';
        }
        return `width: ${this.width}%`;
    }

    get items() {
        const itemArray = [];
        for (let i = 0; i < this.count; i++) {
            itemArray.push(i.toString());
        }
        return itemArray;
    }
}
