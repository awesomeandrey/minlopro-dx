import {
    publish,
    subscribe,
    createMessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
import { isEmpty, isBoundFunction } from 'c/utilities';

import LMS_CHANNEL from '@salesforce/messageChannel/BridgeChannel__c';

// The contexts gets created ONCE;
const $context = createMessageContext();

/**
 * KEY -> unique event name
 * VALUE -> array of callback functions to invoke
 * @type {Map<string, Array>}
 */
const $eventsMap = new Map();

const $subscription = subscribe(
    $context,
    LMS_CHANNEL,
    ({ eventName, payload }) => {
        if (isEmpty(eventName) && !$eventsMap.has(eventName)) {
            return;
        }
        const callbacksToInvoke = $eventsMap.get(eventName) || [];
        callbacksToInvoke.forEach((callbackItem) => {
            try {
                callbackItem(payload);
            } catch (error) {
                // Fail silently;
                console.error('[bridge.js]: could not execute <callback>', error);
            }
        });
    },
    { scope: APPLICATION_SCOPE }
);

const publishEvent = (eventName, payload) => {
    if (typeof eventName !== 'string' || isEmpty(eventName)) {
        throw new Error('Could not publish event: invalid arguments.');
    }
    publish($context, LMS_CHANNEL, {
        eventName,
        payload
    });
};

const subscribeToEvent = (eventName, callback) => {
    if (typeof eventName !== 'string' || isEmpty(eventName)) {
        throw new Error('Invalid event name!');
    }
    if (!isBoundFunction(callback)) {
        throw new Error('Callback must be a bound function!');
    }
    if (!$eventsMap.has(eventName)) {
        $eventsMap.set(eventName, []);
    }
    $eventsMap.get(eventName).push(callback);
};

const unsubscribeFromEvent = (eventName, callback) => {
    if (typeof eventName !== 'string' || isEmpty(eventName) || typeof callback !== 'function') {
        throw new Error('Could not subscribe to event: invalid arguments.');
    }
    if ($eventsMap.has(eventName)) {
        $eventsMap.set(
            eventName,
            $eventsMap.get(eventName).filter((_) => _ !== callback)
        );
    }
};

export { subscribeToEvent, publishEvent, unsubscribeFromEvent };
