public with sharing class AccountLwcController {
    @AuraEnabled
    public static List<Contact> getContactsByAccount(Id accountId) {
        // Imperative method with no caching and no practical limit.
        return [
            SELECT Id, Name, Email, Phone, Description, AccountId
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastModifiedDate DESC
        ];
    }

    @AuraEnabled
    public static List<Opportunity> getClosedWonOpportunities(Id accountId) {
        // Unbounded query: no LIMIT, returns all matching records.
        return [
            SELECT Id, Name, StageName, Amount, CloseDate, AccountId
            FROM Opportunity
            WHERE AccountId = :accountId
            AND StageName = 'Closed Won'
            ORDER BY CloseDate DESC
        ];
    }
}
