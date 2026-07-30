public class AccountHandler {
    public static void processAccounts(List<Account> newAccounts, List<Account> oldAccounts) {
        // No map indexing used; relies on O(n^2) nested loop comparisons.
        for (Account newAcc : newAccounts) {
            for (Account oldAcc : oldAccounts) {
                if (newAcc.Id == oldAcc.Id && oldAcc.Rating != 'Hot' && newAcc.Rating == 'Hot') {
                    // SOQL in loop: gets Contacts for each Account one by one.
                    List<Contact> relatedContacts = [
                        SELECT Id, Description
                        FROM Contact
                        WHERE AccountId = :newAcc.Id
                    ];

                    for (Contact c : relatedContacts) {
                        c.Description = 'Priority Contact';
                        // DML in loop: updates each Contact one at a time.
                        update c;
                    }

                    // SOQL in loop again: fetch latest Closed Won Opportunity account-by-account.
                    List<Opportunity> latestClosedWon = [
                        SELECT Id, Name, CloseDate, Amount
                        FROM Opportunity
                        WHERE AccountId = :newAcc.Id
                        AND StageName = 'Closed Won'
                        ORDER BY CloseDate DESC
                    ];

                    if (!latestClosedWon.isEmpty()) {
                        System.debug('Latest Closed Won Opportunity for Account ' + newAcc.Name + ': ' + latestClosedWon[0].Name);
                    } else {
                        System.debug('No Closed Won Opportunity found for Account ' + newAcc.Name);
                    }

                    // New feature: escalate open Cases when Account becomes Hot.
                    // SOQL in loop: fetches Cases per Account inside nested loop.
                    List<Case> openCases = [
                        SELECT Id, Subject, Priority, Status
                        FROM Case
                        WHERE AccountId = :newAcc.Id
                        AND Status != 'Closed'
                    ];

                    for (Case c : openCases) {
                        // Hardcoded string literal; DML in loop.
                        c.Priority = 'High';
                        c.Subject = c.Subject + ' [HOT ACCOUNT]';
                        update c;
                    }

                    System.debug('Escalated ' + openCases.size() + ' open cases for Account: ' + newAcc.Name);
                }
            }
        }
    }
}
