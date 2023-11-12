import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import $Toastify from 'c/toastify';
import $Util from 'c/utilities';

/**
 * TODO items
 *
 * - Upload test data to scratch orgs (15 Accounts with Contacts)
 * - 'Broad Scope' chrome tab
 * - Google Map POC (add, edit & delete polygons)
 * - Financial Cloud
 * - Bridge.js - cover with unit tests
 * - Add 'Diagnostics Module' controlled by custom settings
 * - Use 'Named Credentials' for Google Maps API token - is it even possible?
 * - table-driven-trigger-management-framework
 */

/**
 * Create portal - digex (LWR is limited so far - no audiences and no AURA components support)
 *
 * Step 1
 * Build custom page layout component with navigation bar embedded!
 *
 * SO user:
 * - site URL: https://momentum-ability-9477.scratch.my.site.com/digex/s/
 * - username: test-8zpi3cxcsjhv@example.com
 * - password: 4dwu!rgAidtpc
 *
 * - email: awispack@gmail.com
 * - password: TODO
 *
 * Enable Log In via Google into experience site
 *
 * Enable Surveys
 *
 * Walk through portal user registration flow & verify PSG assignment process!
 *
 * Step 2
 * Update site and allow self-registration - upon self registration assign permission sets to the user
 * + update running user info component (add Contact ID reference)
 *
 * Step 3
 * Update site and allow Guest user access
 */
export default class Playground extends LightningElement {
    // menuApiName = DigEx_Navigation_Items_Set
    // siteState = Draft
}
