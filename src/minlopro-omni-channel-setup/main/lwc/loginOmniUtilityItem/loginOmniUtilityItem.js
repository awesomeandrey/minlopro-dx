import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { cloneObject, isEmpty, isNotEmpty, parseError } from 'c/utilities';
import Toastify from 'c/toastify';

import getServicePresenceStatusesApex from '@salesforce/apex/OmniChannelController.getServicePresenceStatuses';

const STEPS = {
    STEP_1_LOAD_STATUSES: 'loadPresenceStatuses',
    STEP_2_INIT_OMNI_TOOLKIT_API: 'initOmniToolkitApi',
    STEP_3_LOGIN_OMNI: 'loginOmniChannel',
    STEP_4_NAVIGATE_HOME: 'navigateToHomePage'
};
const LOGIN_STATUS_API_NAME = 'Available';

export default class LoginOmniUtilityItem extends NavigationMixin(LightningElement) {
    @api omniToolkit = null;
    @track currentStepName = STEPS.STEP_1_LOAD_STATUSES;
    @track presenceStatuses = [];
    @track loading = false;
    @track errorMessage = null;
    @track isDebugMode = false;

    get progressSteps() {
        return [
            {
                label: 'Load Service Presence Statuses',
                name: STEPS.STEP_1_LOAD_STATUSES
            },
            {
                label: 'Initialize Omni Toolkit API',
                name: STEPS.STEP_2_INIT_OMNI_TOOLKIT_API
            },
            {
                label: 'Login Omni Channel',
                name: STEPS.STEP_3_LOGIN_OMNI
            },
            {
                label: 'Navigate to Home page',
                name: STEPS.STEP_4_NAVIGATE_HOME
            }
        ];
    }

    get currentProgressStep() {
        return this.progressSteps.find(({ name }) => name === this.currentStepName);
    }

    get hasError() {
        return isNotEmpty(this.errorMessage);
    }

    @wire(IsConsoleNavigation)
    isConsoleNavigation = false;

    @wire(CurrentPageReference)
    wirePageReference(pageRef) {
        this.isDebugMode = isNotEmpty(pageRef?.state?.c__debug);
        if (!this.isDebugMode) {
            this.loginOmni();
        }
    }

    async handleLoginBtn(event) {
        event.preventDefault();
        await this.loginOmni();
    }

    async loginOmni() {
        this.loading = true;
        this.errorObj = null;
        try {
            for (const { name: stepName } of this.progressSteps) {
                this.currentStepName = stepName;
                if (stepName === STEPS.STEP_1_LOAD_STATUSES) {
                    this.presenceStatuses = cloneObject(await getServicePresenceStatusesApex()) || [];
                    if (isEmpty(this.presenceStatuses)) {
                        throw new Error('There are no Service Presence Statuses available for the user.');
                    }
                } else if (stepName === STEPS.STEP_2_INIT_OMNI_TOOLKIT_API) {
                    if (!this.isConsoleNavigation) {
                        throw new Error('Omni Toolkit API is available in Console-navigation application only.');
                    }
                    if (isEmpty(this.omniToolkit)) {
                        throw new Error('Omni Toolkit API is not defined/available.');
                    }
                } else if (stepName === STEPS.STEP_3_LOGIN_OMNI) {
                    const loginStatus = this.presenceStatuses.find(
                        ({ DeveloperName }) => DeveloperName === LOGIN_STATUS_API_NAME
                    );
                    if (isEmpty(loginStatus)) {
                        throw new Error(`Invalid auto-login Service Presence Status configured: ${LOGIN_STATUS_API_NAME}`);
                    }
                    const statusId = loginStatus.Id.slice(0, 15);
                    await this.omniToolkit.login({ statusId });
                    Toastify.success({ message: 'Logged in Omni-Widget' });
                } else if (stepName === STEPS.STEP_4_NAVIGATE_HOME) {
                    const { tabId } = await getFocusedTabInfo();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: { pageName: 'home' }
                    });
                    if (!this.isDebugMode) {
                        await closeTab(tabId);
                    }
                }
            }
        } catch (error) {
            this.errorMessage = parseError(error).message;
        } finally {
            this.loading = false;
        }
    }
}
