public with sharing class AccountLwcController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccount(Id accountId) {
        // Imperative method with no caching and no practical limit.
        return [
            SELECT Id, Name, Email, Phone, Description, AccountId
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastModifiedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
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

    @AuraEnabled(cacheable=true)
    public static List<Case> getOpenCases(Id accountId) {
        return [
            SELECT Id, Subject, Status, Priority, CreatedDate, AccountId
            FROM Case
            WHERE AccountId = :accountId
            AND Status != 'Closed'
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}
