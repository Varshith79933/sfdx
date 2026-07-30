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

        // Bad practice: no cacheable, duplicate call on every loadData invocation.
        getOpenCases({ accountId: this.recordId })
            .then((result) => {
                this.cases = result;
            })
            .catch((err) => {
                this.error = err;
            });

        // Redundant second call to getOpenCases – overwrites the first result unnecessarily.
        getOpenCases({ accountId: this.recordId })
            .then((result) => {
                this.cases = result;
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
