import { LightningElement } from 'lwc';
import { isNotEmpty, parseError, to } from 'c/utilities';
import toastify from 'c/toastify';
import { NavigationMixin } from 'lightning/navigation';

// Apex;
import getRunningUserInfoAsPdfApex from '@salesforce/apex/SystemInfoController.getRunningUserInfoAsPdf';

// Static Resources;
import COMMONS_ASSETS from '@salesforce/resourceUrl/CommonsAssets';

// Custom Labels;
import helpTextLbl from '@salesforce/label/c.DigEx_Download_User_Details';

export default class RunningUserInfoGenerator extends NavigationMixin(LightningElement) {
    get backgroundSvgUrl() {
        return `${COMMONS_ASSETS}/svg/background1.svg`;
    }

    get helpText() {
        return helpTextLbl;
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
        const linkElement = this.refs.link;
        linkElement.href = finalUrl;
        linkElement.download = 'UserInfo.pdf';
        linkElement.click();
        console.log('>>> Clicked on link');
    }
}
