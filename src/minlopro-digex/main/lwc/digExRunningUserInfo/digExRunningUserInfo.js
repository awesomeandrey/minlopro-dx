import { LightningElement, api, track } from 'lwc';
import { cloneObject, isEmpty, isNotEmpty, parseError, to } from 'c/utilities';
import { AuthConfig, getAuthConfigs } from 'c/digExUtil';
import toastify from 'c/toastify';

// Apex;
import getUserInfoByIdApex from '@salesforce/apex/SystemInfoController.getUserInfoById';

// Props;
import $UserId from '@salesforce/user/Id';
import $IsGuest from '@salesforce/user/isGuest';

export default class DigExRunningUserInfo extends LightningElement {
    @api collapsed = false;

    @track userInfoItems = [];
    @track communityInfoItems = [];
    @track userName = '';

    get loading() {
        return isEmpty(this.userInfoItems) || isEmpty(this.communityInfoItems);
    }

    get greeting() {
        return $IsGuest ? "Hi there, you're browsing as a guest." : `Welcome back, ${this.userName}!`;
    }

    get sectionsExpanded() {
        return !this.collapsed;
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
        [error, result = []] = await to(getAuthConfigs());
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        await this.composePortalInfo(result);
    }

    errorCallback(error, stack) {
        console.error(`${this.constructor.name}.js`, error, stack);
    }

    // Service Methods;

    async composeUserInfo(userInfo) {
        this.userName = userInfo.Name;
        this.userInfoItems = [
            { name: 'Name', value: userInfo.Name },
            { name: 'Email', value: userInfo.Email },
            { name: 'Profile', value: userInfo?.Profile?.Name },
            { name: 'User Type', value: userInfo?.UserType }
        ];
    }

    async composePortalInfo(authConfigs) {
        this.communityInfoItems = [
            { name: 'Username/Password Enabled', value: authConfigs[AuthConfig.UsernamePasswordEnabled] },
            { name: 'Self Registration Enabled', value: authConfigs[AuthConfig.SelfRegistrationEnabled] },
            { name: 'Self Registration URL', value: authConfigs[AuthConfig.SelfRegistrationUrl] },
            { name: 'Forgot Password URL', value: authConfigs[AuthConfig.ForgotPasswordUrl] }
        ];
    }
}
