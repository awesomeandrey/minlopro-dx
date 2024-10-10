import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { isNotEmpty, parseError } from 'c/utilities';
import { PageReference } from 'c/digExUtil';
import toastify from 'c/toastify';

// Apex;
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import getNavigationMenuItemsApex from '@salesforce/apex/NavigationMenuItemsController.getNavigationMenuItems';

// Constants;
import $IsGuestUser from '@salesforce/user/isGuest';
import $BasePath from '@salesforce/community/basePath';

export default class DigExNavigationBar extends NavigationMixin(LightningElement) {
    @api menuApiName;

    @track currentUrlPath = '/';
    @track siteState = 'Draft';
    @track navigationItems = undefined;

    get hasLoaded() {
        return this.navigationItems !== undefined;
    }

    get isGuestUser() {
        return $IsGuestUser;
    }

    get logoutLink() {
        const sitePrefix = $BasePath.replace(/\/s$/i, ''); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + '/secur/logout.jsp';
    }

    get visibleNavigationItems() {
        if (!this.hasLoaded) {
            return [];
        }
        return this.navigationItems
            .filter(({ accessRestriction = '' }) => {
                if (accessRestriction === 'None') {
                    return true;
                } else if (accessRestriction === 'LoginRequired' && !$IsGuestUser) {
                    return true;
                }
                return false;
            })
            .map((_) => {
                const selected = (() => {
                    if (_.target === '/') {
                        // Exception for HOME page;
                        return this.currentUrlPath === '/';
                    }
                    return this.currentUrlPath.startsWith(_.target);
                })();
                return {
                    ..._,
                    selected,
                    className: `slds-context-bar__item ${selected ? 'slds-is-active' : 'slds-is-relative'}`
                };
            });
    }

    @wire(CurrentPageReference)
    wireCurrentPageReference(currentPageReference) {
        const app = currentPageReference?.state?.app;
        if (app === 'commeditor') {
            this.siteState = 'Draft';
        } else {
            this.siteState = 'Live';
        }
        // Update current URL path;
        // https://...site.com/digex/s/org-limits -> /org-limits
        // this.currentUrlPath = window.location.pathname.replace($BasePath, '');
    }

    @wire(getNavigationMenuItemsApex, {
        menuApiName: '$menuApiName',
        siteState: '$siteState'
    })
    wireMenuItems({ error, data }) {
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message }, this);
            return;
        }
        this.navigationItems = (data || []).map((_) => ({
            id: `${_.Target}:${_.Type}`,
            label: _.Label,
            target: _.Target,
            type: _.Type,
            accessRestriction: _.AccessRestriction,
            defaultListViewId: _.DefaultListViewId,
            status: _.Status,
            parentId: _.ParentId,
            targetPrefs: _.TargetPrefs
        }));
    }

    handleNavigate(event) {
        event.preventDefault();
        const navigationItemId = event.target.dataset.id;
        const navigationItem = this.navigationItems.find(({ id }) => id === navigationItemId);
        if (navigationItem) {
            this.navigate(navigationItem);
        }
    }

    handleNavigateHome(event) {
        event.preventDefault();
        const homeNavItem = this.navigationItems.find(({ target }) => target === '/');
        if (homeNavItem) {
            this.navigate(homeNavItem);
        }
    }

    handleNavigateLogin(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate](PageReference.Login);
    }

    handleNavigateLogout(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate](PageReference.Logout, true);
    }

    navigate(navigationItem) {
        const { type, target, defaultListViewId } = navigationItem;
        // Get the correct PageReference object for the menu item type
        if (type === 'SalesforceObject') {
            // aka "Salesforce Object" menu item
            this.pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: target,
                    actionName: 'list'
                },
                state: {
                    filterName: defaultListViewId
                }
            };
        } else if (type === 'InternalLink') {
            // aka "Site Page" menu item
            // WARNING: Normally you shouldn't use 'standard__webPage' for internal relative targets, but
            // we don't have a way of identifying the Page Reference type of an InternalLink URL
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: $BasePath + target
                }
            };
        } else if (type === 'ExternalLink') {
            // aka "External URL" menu item
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: target
                }
            };
        } else if (type === 'Event') {
            // There are 3 event-like navigation items: login, logout & switch account;
            this.pageReference = {
                type: 'comm__loginPage',
                attributes: {
                    actionName: target.toLowerCase()
                }
            };
        }
        if (this.pageReference) {
            this[NavigationMixin.Navigate](this.pageReference);
        } else {
            toastify.error({
                message: `Navigation menu type "${type}" is not implemented for item ${JSON.stringify(navigationItem)}`
            });
        }
    }
}
