public class AccountHandler {
    public static void processAccounts(List<Account> newAccounts, List<Account> oldAccounts) {
        String hotRating = System.Label.AccountHotRating;
        String priorityContactDescription = System.Label.PriorityContactDescription;
        String closedWonStageName = System.Label.ClosedWonStageName;
        String closedCaseStatus = System.Label.ClosedCaseStatus;
        String escalatedCasePriority = System.Label.EscalatedCasePriority;
        String hotAccountCaseTag = System.Label.HotAccountCaseTag;
        String latestClosedWonMessageTemplate = System.Label.AccountHandlerLatestClosedWonMessage;
        String noClosedWonMessageTemplate = System.Label.AccountHandlerNoClosedWonMessage;
        String escalatedCasesMessageTemplate = System.Label.AccountHandlerEscalatedCasesMessage;

        Map<Id, Account> oldAccountsById = new Map<Id, Account>(oldAccounts);
        Set<Id> hotAccountIds = new Set<Id>();
        Map<Id, String> hotAccountNamesById = new Map<Id, String>();

        for (Account newAcc : newAccounts) {
            Account oldAcc = oldAccountsById.get(newAcc.Id);
            if (oldAcc != null && oldAcc.Rating != hotRating && newAcc.Rating == hotRating) {
                hotAccountIds.add(newAcc.Id);
                hotAccountNamesById.put(newAcc.Id, newAcc.Name);
            }
        }
hello this is varshith
        if (hotAccountIds.isEmpty()) {
            return;
        }

        List<Contact> contactsToUpdate = [
            SELECT Id, Description
            FROM Contact
            WHERE AccountId IN :hotAccountIds
            AND (Description = null OR Description != :priorityContactDescription)
        ];
        for (Contact contactRecord : contactsToUpdate) {
            contactRecord.Description = priorityContactDescription;
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }

        Map<Id, Opportunity> latestClosedWonByAccountId = new Map<Id, Opportunity>();
        for (Opportunity opportunityRecord : [
            SELECT Id, Name, CloseDate, Amount, AccountId
            FROM Opportunity
            WHERE AccountId IN :hotAccountIds
            AND StageName = :closedWonStageName
            ORDER BY AccountId, CloseDate DESC
        ]) {
            if (!latestClosedWonByAccountId.containsKey(opportunityRecord.AccountId)) {
                latestClosedWonByAccountId.put(opportunityRecord.AccountId, opportunityRecord);
            }
        }

        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Integer> escalatedCaseCountByAccountId = new Map<Id, Integer>();
        for (Case caseRecord : [
            SELECT Id, Subject, Priority, Status, AccountId
            FROM Case
            WHERE AccountId IN :hotAccountIds
            AND Status != :closedCaseStatus
            AND (Priority != :escalatedCasePriority OR Subject = null OR Subject NOT LIKE :('%' + hotAccountCaseTag + '%'))
        ]) {
            Boolean shouldUpdate = false;

            if (caseRecord.Priority != escalatedCasePriority) {
                caseRecord.Priority = escalatedCasePriority;
                shouldUpdate = true;
            }

            if (String.isBlank(caseRecord.Subject)) {
                caseRecord.Subject = hotAccountCaseTag;
                shouldUpdate = true;
            } else if (!caseRecord.Subject.contains(hotAccountCaseTag)) {
                caseRecord.Subject += ' ' + hotAccountCaseTag;
                shouldUpdate = true;
            }

            if (!shouldUpdate) {
                continue;
            }

            casesToUpdate.add(caseRecord);
            Integer existingCount = escalatedCaseCountByAccountId.get(caseRecord.AccountId);
            escalatedCaseCountByAccountId.put(caseRecord.AccountId, existingCount == null ? 1 : existingCount + 1);
        }
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        for (Id accountId : hotAccountIds) {
            Opportunity latestClosedWon = latestClosedWonByAccountId.get(accountId);
            String accountName = hotAccountNamesById.get(accountId);
            if (latestClosedWon != null) {
                System.debug(String.format(latestClosedWonMessageTemplate, new List<String>{ accountName, latestClosedWon.Name }));
            } else {
                System.debug(String.format(noClosedWonMessageTemplate, new List<String>{ accountName }));
            }

            Integer escalatedCaseCount = escalatedCaseCountByAccountId.get(accountId);
            String escalatedCount = String.valueOf(escalatedCaseCount == null ? 0 : escalatedCaseCount);
            System.debug(String.format(escalatedCasesMessageTemplate, new List<String>{ escalatedCount, accountName }));
        }
    }
}
