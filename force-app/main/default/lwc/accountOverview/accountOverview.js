import { LightningElement, api, track } from 'lwc';
import getContactsByAccount from '@salesforce/apex/AccountLwcController.getContactsByAccount';
import getClosedWonOpportunities from '@salesforce/apex/AccountLwcController.getClosedWonOpportunities';

export default class AccountOverview extends LightningElement {
    @api recordId;
    @track contacts = [];
    @track opportunities = [];
    @track error;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        // Redundant imperative call pattern: same method called twice.
        getContactsByAccount({ accountId: this.recordId })
            .then((result) => {
                this.contacts = result;
            })
            .catch((err) => {
                this.error = err;
            });

        getContactsByAccount({ accountId: this.recordId })
            .then((result) => {
                // Unnecessary re-assignment from duplicate server trip.
                this.contacts = result;
            })
            .catch((err) => {
                this.error = err;
            });

        // Additional non-cached imperative call.
        getClosedWonOpportunities({ accountId: this.recordId })
            .then((result) => {
                this.opportunities = result;
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
