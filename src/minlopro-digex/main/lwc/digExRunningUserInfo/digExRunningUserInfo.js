import { LightningElement, track } from 'lwc';
import { cloneObject, isEmpty, isNotEmpty, parseError, to } from 'c/utilities';
import toastify from 'c/toastify';

// Apex;
import getUserInfoByIdApex from '@salesforce/apex/SystemInfoController.getUserInfoById';
import getAuthConfigurationApex from '@salesforce/apex/SystemInfoController.getAuthConfiguration';

// Props;
import $UserId from '@salesforce/user/Id';
import $IsGuest from '@salesforce/user/isGuest';

export default class DigExRunningUserInfo extends LightningElement {
    @track userInfoItems = [];
    @track communityInfoItems = [];

    get loading() {
        return isEmpty(this.userInfoItems) || isEmpty(this.communityInfoItems);
    }

    get userInfoStats() {
        return this.userInfoItems.reduce((acc, { name, value }) => {
            acc[name] = value;
            return acc;
        }, {});
    }

    get communityInfoStats() {
        return this.communityInfoItems.reduce((acc, { name, value }) => {
            acc[name] = value;
            return acc;
        }, {});
    }

    async connectedCallback() {
        // Pull user info;
        let [error, result = []] = await to(getUserInfoByIdApex({ userId: $UserId }));
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        await this.composeUserInfo(cloneObject(result));

        // Pull auth configurations;
        [error, result = []] = await to(getAuthConfigurationApex());
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        await this.composePortalInfo(cloneObject(result));
    }

    errorCallback(error, stack) {
        console.error(`${this.constructor.name}.js`, error, stack);
    }

    // Service Methods;

    async composeUserInfo(userInfo) {
        this.userInfoItems = [
            { name: 'Name', value: userInfo.Name },
            { name: 'Username', value: userInfo.Username },
            { name: 'Email', value: userInfo.Email },
            { name: 'Profile', value: userInfo?.Profile?.Name },
            { name: 'User Type', value: userInfo?.UserType },
            { name: 'Is Guest', value: $IsGuest },
            { name: 'Is Portal Enabled', value: userInfo.IsPortalEnabled },
            { name: 'Profile User License', value: userInfo?.Profile?.UserLicense?.Name }
        ];
    }

    async composePortalInfo(authConfigs) {
        this.communityInfoItems = [
            { name: 'Username/Password Enabled', value: authConfigs['usernamePasswordEnabled'] },
            { name: 'Self Registration Enabled', value: authConfigs['selfRegistrationEnabled'] },
            { name: 'Self Registration URL', value: authConfigs['selfRegistrationUrl'] },
            { name: 'Forgot Password URL', value: authConfigs['forgotPasswordUrl'] }
        ];
    }
}
