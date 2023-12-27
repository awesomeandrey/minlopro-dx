import { jestConfig } from '@salesforce/sfdx-lwc-jest/config.js';

export default {
    ...jestConfig,
    moduleNameMapper: {
        '^lightning/platformShowToastEvent$': '<rootDir>/src/minlopro-core/test/jest-mocks/lightning/platformShowToastEvent'
    }
};
