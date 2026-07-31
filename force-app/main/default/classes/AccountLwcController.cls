public with sharing class AccountLwcController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccount(Id accountId) {
        // Capped list to keep payload size predictable for the overview UI.
        return [
            SELECT Id, Name, Email, Phone, Description, AccountId
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastModifiedDate DESC
            LIMIT 50
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getClosedWonOpportunities(Id accountId) {
        // Capped list to keep payload size predictable for the overview UI.
        return [
            SELECT Id, Name, StageName, Amount, CloseDate, AccountId
            FROM Opportunity
            WHERE AccountId = :accountId
            AND StageName = 'Closed Won'
            ORDER BY CloseDate DESC
            LIMIT 50
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
