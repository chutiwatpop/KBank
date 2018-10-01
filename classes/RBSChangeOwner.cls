public  class RBSChangeOwner implements IOwnerExecution {
	AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
    Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();

    public RBSChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser){
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
    }
    
    public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        Map<Id, Account> changeAccountOwnerIdMap = new Map<Id, Account>();
        possibleUserExtensionMapWithUserId = userExtensionMapWithUserId;
        for(Account eachAccount : possibleChangeOwnerLists){
            accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
            changeAccountOwnerIdMap.put(eachAccount.Id, eachAccount);
        }
        accountService.updateIndividualContactOwner(changeAccountOwnerIdMap);
    }

    public void executeChangeJob(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){

    }

    public void executeChangeEvent(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){

    }
}