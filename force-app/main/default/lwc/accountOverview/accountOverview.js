import { LightningElement, api, track } from 'lwc';
import getContactsByAccount from '@salesforce/apex/AccountLwcController.getContactsByAccount';
import getClosedWonOpportunities from '@salesforce/apex/AccountLwcController.getClosedWonOpportunities';
import getOpenCases from '@salesforce/apex/AccountLwcController.getOpenCases';

export default class AccountOverview extends LightningElement {
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
