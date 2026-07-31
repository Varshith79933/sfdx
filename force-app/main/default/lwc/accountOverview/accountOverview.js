import { LightningElement, api, track } from 'lwc';
import getContactsByAccount from '@salesforce/apex/AccountLwcController.getContactsByAccount';
import getClosedWonOpportunities from '@salesforce/apex/AccountLwcController.getClosedWonOpportunities';
import getOpenCases from '@salesforce/apex/AccountLwcController.getOpenCases';
import accountTierLabel from '@salesforce/label/c.AccountOverviewTierLabel';
import accountTierValue from '@salesforce/label/c.AccountOverviewTierValue';
import regionLabel from '@salesforce/label/c.AccountOverviewRegionLabel';
import regionValue from '@salesforce/label/c.AccountOverviewRegionValue';
import supportPhoneLabel from '@salesforce/label/c.AccountOverviewSupportPhoneLabel';
import supportPhoneValue from '@salesforce/label/c.AccountOverviewSupportPhoneValue';
import cardTitle from '@salesforce/label/c.AccountOverviewCardTitle';
import refreshLabel from '@salesforce/label/c.AccountOverviewRefreshLabel';
import contactsHeader from '@salesforce/label/c.AccountOverviewContactsHeader';
import closedWonHeader from '@salesforce/label/c.AccountOverviewClosedWonHeader';
import openCasesHeader from '@salesforce/label/c.AccountOverviewOpenCasesHeader';

export default class AccountOverview extends LightningElement {
    labels = {
        accountTierLabel,
        accountTierValue,
        regionLabel,
        regionValue,
        supportPhoneLabel,
        supportPhoneValue,
        cardTitle,
        refreshLabel,
        contactsHeader,
        closedWonHeader,
        openCasesHeader
    };

    @api recordId;
    @track contacts = [];
    @track opportunities = [];
    @track cases = [];
    @track error;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        this.error = undefined;

        Promise.all([
            getContactsByAccount({ accountId: this.recordId }),
            getClosedWonOpportunities({ accountId: this.recordId }),
            getOpenCases({ accountId: this.recordId })
        ])
            .then(([contacts, opportunities, cases]) => {
                this.contacts = contacts;
                this.opportunities = opportunities;
                this.cases = cases;
            })
            .catch((err) => {
                this.error = err;
            });
    }

    handleRefreshClick() {
        // Re-fetches everything again even if no data changed.
        this.loadData();
    }
}
