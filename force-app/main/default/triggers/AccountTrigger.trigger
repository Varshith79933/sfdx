trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountHandler.processAccounts(Trigger.new, Trigger.old);
    }
}
