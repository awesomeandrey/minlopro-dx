import { LightningElement, api, track } from 'lwc';
import { cloneObject, isEmpty, isNotEmpty, parseError, to } from 'c/utilities';
import { AuthConfig, getAuthConfigs } from 'c/digExUtil';
import toastify from 'c/toastify';

import getUserInfoByIdApex from '@salesforce/apex/SystemInfoController.getUserInfoById';
import getRunningUserInfoAsPdfApex from '@salesforce/apex/SystemInfoController.getRunningUserInfoAsPdf';

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
            { name: 'Username', value: userInfo.Username },
            { name: 'Email', value: userInfo.Email },
            { name: 'Profile', value: userInfo?.Profile?.Name },
            { name: 'Title', value: userInfo?.Title },
            { name: 'Portal Enabled?', value: userInfo?.IsPortalEnabled },
            { name: 'User Type', value: userInfo?.UserType },
            { name: 'User Role', value: userInfo?.UserRole?.Name },
            { name: 'Account ID', value: userInfo?.AccountId },
            { name: 'Contact ID', value: userInfo?.ContactId }
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

    async handleDownloadUserInfo(event) {
        event.preventDefault();
        const [error, encodedBlob] = await to(getRunningUserInfoAsPdfApex());
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        const finalUrl = `data:application/pdf;base64,${encodedBlob}`;
        const linkElement = this.refs.downloadLink;
        linkElement.href = finalUrl;
        linkElement.download = 'Minlopro DigEx User Info.pdf';
        linkElement.click();
    }
}
