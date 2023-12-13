const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^lightning/platformShowToastEvent$': '<rootDir>/src/minlopro-core/test/jest-mocks/lightning/platformShowToastEvent'
    }
};
