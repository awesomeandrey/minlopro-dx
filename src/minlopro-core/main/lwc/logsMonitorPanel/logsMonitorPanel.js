import { LightningElement, track } from 'lwc';
import { to, debounce, isNotEmpty, parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex;
import hasPartitionDefinedApex from '@salesforce/apex/LogsMonitorPanelController.hasPartitionDefined';
import getRatioApex from '@salesforce/apex/LogsMonitorPanelController.getRatio';
import setRatioApex from '@salesforce/apex/LogsMonitorPanelController.setRatio';

/**
 * Events sequence is as follows:
 *  1. mousedown (Bar)
 *  2. mousemove (Container)
 *  3. mouseup (Container)
 *
 *  Useful links:
 *  - https://medium.com/@etherealm/currenttarget-vs-target-in-js-2f3fd3a543e5
 *  - https://salesforce.stackexchange.com/questions/394043/resizable-divs-in-lwc
 */
export default class LogsMonitorPanel extends LightningElement {
    @track $barElement;
    @track isDraggingBar = false;
    @track debouncedPersistSessionRatio = debounce(this.persistSessionRatio.bind(this), 2000);

    connectedCallback() {
        this.fetchSessionRatio();
    }

    // Event handlers;

    handleContainerMouseMove(event) {
        event.preventDefault();
        if (this.isDraggingBar) {
            // Horizontal coordinate within the application's viewport at which the event occurred;
            const clientX = event.clientX;
            // Calculate X delta between bar original position and the new one (caused by 'mousemove' event);
            const deltaX = clientX - (this.$barElement._clientX || clientX);
            // Store new X position of bar element in a custom property;
            this.$barElement._clientX = clientX;
            // Grab references to the resizeable div elements (Element API);
            const { previousElementSibling, nextElementSibling } = this.$barElement;
            // LEFT;
            if (deltaX < 0) {
                // px (pixels);
                const leftDivWidth = Math.round(parseInt(window.getComputedStyle(previousElementSibling).width) + deltaX);
                // % (percentage);
                const leftDivRatio = this.calculateConsumedWidthRatio(leftDivWidth);
                previousElementSibling.style.flex = `0 ${leftDivRatio}%`;
                nextElementSibling.style.flex = '1 0';
                // Persist left div ratio in Session cache;
                this.debouncedPersistSessionRatio(leftDivRatio);
            }
            // RIGHT;
            else if (deltaX > 0) {
                // px (pixels);
                const rightDivWidth = Math.round(parseInt(window.getComputedStyle(nextElementSibling).width) - deltaX);
                // % (percentage);
                const rightDivRatio = this.calculateConsumedWidthRatio(rightDivWidth);
                nextElementSibling.style.flex = `0 ${rightDivRatio}%`;
                previousElementSibling.style.flex = '1 0';
                // Persist left div ratio in Session cache;
                this.debouncedPersistSessionRatio(Math.round(100 - rightDivRatio));
            }
        }
    }

    handleBarMouseDown(event) {
        event.preventDefault();
        // Capture 'bar' element reference;
        this.$barElement = event.currentTarget;
        // Cleanup custom X coordinates (position);
        delete this.$barElement._clientX;
        // Turn on flag telling the component that resizing is in progress;
        this.isDraggingBar = true;
    }

    handleContainerMouseUp(event) {
        event.preventDefault();
        // Turn off flag telling the component that resizing is done;
        this.isDraggingBar = false;
    }

    // Service methods;

    async fetchSessionRatio() {
        const [errorGettingPartition, hasPartition] = await to(hasPartitionDefinedApex());
        if (isNotEmpty(errorGettingPartition)) {
            const { message } = parseError(errorGettingPartition);
            $Toastify.error({ message });
            return;
        }
        if (!hasPartition) {
            $Toastify.info({ message: 'No partition allocated!' });
            return;
        }
        const [errorGettingRatio, ratio] = await to(getRatioApex());
        if (isNotEmpty(errorGettingRatio)) {
            const { message } = parseError(errorGettingRatio);
            $Toastify.error({ message });
        } else {
            const { previousElementSibling, nextElementSibling } = this.refs.bar;
            previousElementSibling.style.flex = `0 ${ratio}%`;
            nextElementSibling.style.flex = '1 0';
        }
    }

    async persistSessionRatio(ratioToPersist) {
        const [error] = await to(
            setRatioApex({
                ratio: ratioToPersist
            })
        );
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            $Toastify.error({ message });
        }
    }

    calculateConsumedWidthRatio(resizableItemWidthInPixels) {
        const containerWidth = Math.round(parseInt(window.getComputedStyle(this.refs.container).width));
        const consumedRatio = Math.round((resizableItemWidthInPixels * 100) / containerWidth);
        return Math.max(25, consumedRatio);
    }
}
