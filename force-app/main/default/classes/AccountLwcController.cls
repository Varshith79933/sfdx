public with sharing class AccountLwcController {
    private static Integer getConfiguredLimit(String rawLimitValue) {
        Integer parsedLimit = Integer.valueOf(rawLimitValue);
        Integer minimumLimit = Integer.valueOf(System.Label.AccountOverviewMinimumLimit);
        if (parsedLimit < minimumLimit) {
            throw new AuraHandledException(System.Label.AccountOverviewInvalidLimitMessage);
        }
        return parsedLimit;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccount(Id accountId) {
        // Capped list to keep payload size predictable for the overview UI.
        Integer contactsLimit = getConfiguredLimit(System.Label.AccountOverviewContactsLimit);
        return [
            SELECT Id, Name, Email, Phone, Description, AccountId
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastModifiedDate DESC
            LIMIT :contactsLimit
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getClosedWonOpportunities(Id accountId) {
        // Capped list to keep payload size predictable for the overview UI.
        Integer closedWonLimit = getConfiguredLimit(System.Label.AccountOverviewClosedWonLimit);
        String closedWonStageName = System.Label.ClosedWonStageName;
        return [
            SELECT Id, Name, StageName, Amount, CloseDate, AccountId
            FROM Opportunity
            WHERE AccountId = :accountId
            AND StageName = :closedWonStageName
            ORDER BY CloseDate DESC
            LIMIT :closedWonLimit
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getOpenCases(Id accountId) {
        Integer openCasesLimit = getConfiguredLimit(System.Label.AccountOverviewOpenCasesLimit);
        String closedCaseStatus = System.Label.ClosedCaseStatus;
        return [
            SELECT Id, Subject, Status, Priority, CreatedDate, AccountId
            FROM Case
            WHERE AccountId = :accountId
            AND Status != :closedCaseStatus
            ORDER BY CreatedDate DESC
            LIMIT :openCasesLimit
        ];
    }
}
