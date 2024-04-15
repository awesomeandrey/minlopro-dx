import { cloneObject } from 'c/utilities';

// Apex;
import getAuthConfigurationApex from '@salesforce/apex/SystemInfoController.getAuthConfiguration';

export const AuthConfig = {
    UsernamePasswordEnabled: 'usernamePasswordEnabled',
    SelfRegistrationEnabled: 'selfRegistrationEnabled',
    SelfRegistrationUrl: 'selfRegistrationUrl',
    ForgotPasswordUrl: 'forgotPasswordUrl'
};

export const getAuthConfigs = async () => {
    const result = await getAuthConfigurationApex();
    const authConfigs = cloneObject(result);
    return Object.values(AuthConfig).reduce((resultObj, authConfigApexKey) => {
        resultObj[authConfigApexKey] = authConfigs[authConfigApexKey];
        return resultObj;
    }, {});
};

export const PageReference = {
    Login: {
        type: 'comm__loginPage',
        attributes: {
            actionName: 'login'
        }
    },
    Logout: {
        type: 'comm__loginPage',
        attributes: {
            actionName: 'logout'
        }
    },
    Home: {
        type: 'comm__namedPage',
        attributes: {
            name: 'Home'
        }
    }
};
