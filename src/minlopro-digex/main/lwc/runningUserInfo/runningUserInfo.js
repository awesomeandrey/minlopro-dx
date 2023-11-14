import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { cloneObject, isEmpty, isNotEmpty, parseError, to } from 'c/utilities';
import toastify from 'c/toastify';

// Apex;
import getUserInfoByIdApex from '@salesforce/apex/SystemInfoController.getUserInfoById';

// Props;
import $UserId from '@salesforce/user/Id';
import $IsGuest from '@salesforce/user/isGuest';

export default class RunningUserInfo extends NavigationMixin(LightningElement) {
    @track userInfoItems = [];
    @track communityInfoItems = [];

    get loading() {
        return isEmpty(this.userInfoItems) || isEmpty(this.communityInfoItems);
    }

    async connectedCallback() {
        const [error, result = []] = await to(getUserInfoByIdApex({ userId: $UserId }));
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        const userInfo = cloneObject(result);
        const userLink = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: userInfo.Id || $UserId,
                actionName: 'view'
            }
        });
        const profileLink = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: userInfo?.Profile?.Id,
                actionName: 'view'
            }
        });
        this.userInfoItems = [
            { name: 'Name', value: userInfo.Name, link: userLink },
            { name: 'Username', value: userInfo.Username },
            { name: 'Email', value: userInfo.Email },
            { name: 'Profile', value: userInfo?.Profile?.Name, link: profileLink },
            { name: 'User Type', value: userInfo?.UserType }
        ];
        this.communityInfoItems = [
            // {name: "Community Base Path", value: $CommunityBasePath},
            { name: 'Is Guest', value: $IsGuest, isCheckbox: true },
            { name: 'Is Portal Enabled', value: userInfo.IsPortalEnabled, isCheckbox: true },
            { name: 'Profile User License', value: userInfo?.Profile?.UserLicense?.Name }
            // {
            //     name: 'Is Portal Self Registered',
            //     value: userInfo.IsPortalSelfRegistered,
            //     isCheckbox: true
            // }
        ];
    }

    errorCallback(error, stack) {
        console.error('RunningUserInfo.js', error, stack);
    }
}
