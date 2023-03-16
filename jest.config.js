const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^lightning/platformShowToastEvent$':
            '<rootDir>/src/commons/test/jest-mocks/lightning/platformShowToastEvent'
    }
};
