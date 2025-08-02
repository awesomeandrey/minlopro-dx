import { LightningElement, api, track } from 'lwc';
import { isNotEmpty, uniqueId, waitAsync } from 'c/utilities';

const FADE_OUT_CLASS_NAME = 'fade-out';
export default class Confetti extends LightningElement {
    @track items = [];
    @track intervalIds = [];
    @track debugModeEnabled = false;

    @api async celebrate() {
        if (isNotEmpty(this.intervalIds)) {
            this.log('Already running confetti!');
            return;
        }
        this.debugModeEnabled && console.group('Confetti');
        this.log('Invoke "celebrate()" function.');
        this.refs.container.classList.remove(FADE_OUT_CLASS_NAME);
        const { promise, resolve } = Promise.withResolvers();
        setTimeout(resolve, 5000);
        this.log('Created promise with resolver.');
        this.generateConfetti();
        this.log('Generated confetti items with intervals.');
        await promise;
        this.log('setTimeout() invoked "resolve" function.');
        this.log('Time to hide confetti.');
        this.refs.container.classList.add(FADE_OUT_CLASS_NAME);
        await waitAsync(2000);
        this.log('Resetting confetti items & intervals.');
        this.items = [];
        this.intervalIds.forEach(clearInterval);
        this.intervalIds = [];
        this.debugModeEnabled && console.groupEnd();
    }

    log(message) {
        this.debugModeEnabled && console.log(message);
    }

    generateConfetti() {
        for (let i = 0; i < 100; i++) {
            this.items.push({
                id: uniqueId(),
                style: this.generateConfettiStyle()
            });
        }
        let intervalId = setInterval(() => {
            this.items = this.items.map((confetti) => {
                return {
                    ...confetti,
                    style: this.updateConfettiStyle(confetti.style)
                };
            });
        }, 50);
        this.intervalIds.push(intervalId);
    }

    generateConfettiStyle() {
        const x = Math.floor(Math.random() * window.innerWidth);
        const y = Math.floor(Math.random() * -window.innerHeight);
        const size = Math.floor(Math.random() * 5 + 5);
        const color = this.generateRandomColor();
        return `left: ${x}px; top: ${y}px; width: ${size}px; height: ${size}px; background-color: ${color};`;
    }

    updateConfettiStyle(style) {
        const currentTop = parseInt(style.split(';')[1].split(':')[1], 10);
        const updatedTop = currentTop + 10;
        return style.replace(`top: ${currentTop}px`, `top: ${updatedTop}px`);
    }

    generateRandomColor() {
        const colorArray = ['red', 'green', 'blue', 'purple', 'orange'];
        const randomIndex = Math.floor(Math.random() * colorArray.length);
        return colorArray[randomIndex];
    }
}
