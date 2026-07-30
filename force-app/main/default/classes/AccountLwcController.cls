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

    @AuraEnabled
    public static List<Case> getOpenCases(Id accountId) {
        // Bad practice: no cacheable=true, no LIMIT, hardcoded status strings.
        List<Case> allCases = new List<Case>();
        // Fetching all cases first, then filtering in Apex instead of WHERE clause.
        List<Case> cases = [
            SELECT Id, Subject, Status, Priority, CreatedDate, AccountId
            FROM Case
            WHERE AccountId = :accountId
            ORDER BY CreatedDate DESC
        ];
        for (Case c : cases) {
            // Manual filter in loop instead of adding Status != 'Closed' to SOQL.
            if (c.Status != 'Closed') {
                allCases.add(c);
            }
        }
        // Second redundant SOQL to double-check count – completely unnecessary.
        Integer caseCount = [
            SELECT COUNT()
            FROM Case
            WHERE AccountId = :accountId
            AND Status != 'Closed'
        ];
        System.debug('Open case count from redundant query: ' + caseCount);
        return allCases;
    }
}
