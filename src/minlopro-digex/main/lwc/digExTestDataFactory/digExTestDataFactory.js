import { pickRandom } from 'c/utilities';

const FIRST_NAMES = ['Alice', 'Bob', 'Charlie', 'Diana', 'Edward', 'Fiona', 'George', 'Hannah', 'Ivan', 'Julia'];
const LAST_NAMES = ['Anderson', 'Brown', 'Clark', 'Davis', 'Evans', 'Fisher', 'Green', 'Harris', 'Jackson', 'King'];
const WORDS = [
    'account',
    'action',
    'alert',
    'batch',
    'case',
    'click',
    'cloud',
    'code',
    'connect',
    'contact',
    'custom',
    'data',
    'default',
    'deploy',
    'detail',
    'email',
    'error',
    'event',
    'field',
    'filter',
    'flow',
    'form',
    'group',
    'guide',
    'help',
    'import',
    'input',
    'issue',
    'item',
    'label',
    'layout',
    'lead',
    'link',
    'list',
    'login',
    'lookup',
    'merge',
    'modal',
    'name',
    'object',
    'option',
    'output',
    'owner',
    'page',
    'panel',
    'path',
    'picklist',
    'process',
    'profile',
    'query',
    'queue',
    'record',
    'report',
    'request',
    'result',
    'role',
    'rule',
    'search',
    'section',
    'service',
    'setup',
    'share',
    'source',
    'stage',
    'status',
    'subject',
    'submit',
    'support',
    'system',
    'task',
    'template',
    'token',
    'trigger',
    'type',
    'update',
    'upload',
    'user',
    'value',
    'view',
    'widget'
];

/**
 * Returns a random first name.
 * @returns {string}
 */
export function randomFirstName() {
    return pickRandom(FIRST_NAMES);
}

/**
 * Returns a random last name.
 * @returns {string}
 */
export function randomLastName() {
    return pickRandom(LAST_NAMES);
}

/**
 * Returns a random email address derived from a random first and last name.
 * Optionally accepts pre-generated first and last name values.
 * @param {string} [firstName]
 * @param {string} [lastName]
 * @returns {string}
 */
export function randomEmail(firstName, lastName) {
    const first = firstName ?? randomFirstName();
    const last = lastName ?? randomLastName();
    return `${first.toLowerCase()}.${last.toLowerCase()}@sample.com`;
}

/**
 * Returns a random text string of approximately the given character length.
 * Words are picked randomly from a built-in word bank and joined with spaces.
 * @param {number} length - Target character length.
 * @returns {string}
 */
export function randomText(length = 20) {
    let result = '';
    while (result.length < length) {
        const separator = result.length === 0 ? '' : ' ';
        result += separator + pickRandom(WORDS);
    }
    return result.slice(0, length);
}
