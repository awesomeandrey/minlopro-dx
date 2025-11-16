import { jestConfig } from '@salesforce/sfdx-lwc-jest/config.js';

console.log('Successfully read Jest config file!');

export default {
    ...jestConfig,
    moduleNameMapper: {
        '^lightning/platformShowToastEvent$': '<rootDir>/src/minlopro-core/test/jest-mocks/lightning/platformShowToastEvent'
    },
    reporters: ['default', 'jest-junit']
};
