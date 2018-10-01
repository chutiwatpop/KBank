public class CBSChangeOwner implements IOwnerExecution {
	AccountChangeOwner accountService = new AccountChangeOwner();
    List<Account> possibleChangeOwnerLists = new List<Account>();
	Map<Id,User> possibleUserMap = new Map<Id,User>();
    Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
	
    public CBSChangeOwner(List<Account> accountLists, Map<Id,Account> oldAccountMap, User currentUser) {
        possibleChangeOwnerLists = accountService.possibleChangeOwner(accountLists, oldAccountMap);
        if(!possibleChangeOwnerLists.isEmpty()) {
            List<Id> userIdList = new List<Id>();
            userIdList.add(currentUser.Id);
            for(Account eachAccount : possibleChangeOwnerLists){
                userIdList.add(eachAccount.OwnerId);
                userIdList.add(oldAccountMap.get(eachAccount.Id).OwnerId);
            }
            possibleUserMap = User_Service.getUserMapWithId(userIdList);
            possibleUserExtensionMapWithUserId = UserExtension_Service.getUserExtensionMapByUserId(userIdList);
        }
    }
    
	public void executeChangeOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, User currentUser, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<String,Id> teamMapByRc){
        changeAccountOwner(possibleChangeOwnerLists, oldAccountMap, currentUser, teamMapByRc, possibleUserExtensionMapWithUserId);
    }

    public void executeChangeJob(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){

    }

    public void executeChangeEvent(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap, Map<Id,User_Extension__c> userExtensionMapWithUserId, Map<Id,User_Extension__c> userExtensionMapWithId, Map<String,Id> teamMapByRc){

    }

    private void changeAccountOwner(List<Account> possibleChangeOwnerLists, Map<Id,Account> oldAccountMap, User currentUser, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
        String fromTo = '';
        List<Id> changeAccountOwnerIdLists = new List<Id>();
        List<Id> oldUserOwnerIdLists = new List<Id>();
        List<Id> userOwnerIdLists = new List<Id>();
        Map<Id,User> mapUserWithId = new Map<Id,User>();
        Map<Id,Account> mapAccountWithId = new Map<Id,Account>();
        Map<Id,Account> changeAccountOwnerIdMap = new Map<Id,Account>();
        for(Account eachAccount : possibleChangeOwnerLists){
            userOwnerIdLists.add(eachAccount.OwnerId);
            userOwnerIdLists.add(oldAccountMap.get(eachAccount.Id).OwnerId);
            mapAccountWithId.put(eachAccount.Id, eachAccount);
        }
        mapUserWithId = User_Service.getUserMapWithId(userOwnerIdLists);
        
        for(Account eachAccount : possibleChangeOwnerLists){
            String segmentFromTo = GlobalUtility.isSegmentFromTo(mapUserWithId.get(oldAccountMap.get(eachAccount.Id).OwnerId),mapUserWithId.get(eachAccount.OwnerId));
            fromTo = segmentFromTo;
            accountService.updateOwnerFieldsSet(eachAccount, oldAccountMap.get(eachAccount.Id), teamMapByRc, possibleUserExtensionMapWithUserId);
            if(possibleUserExtensionMapWithUserId.containsKey(eachAccount.OwnerId)){
                eachAccount.Primary_Segment_Code__c =  accountService.calculatePrimarySegment(possibleUserExtensionMapWithUserId.get(eachAccount.OwnerId).User__r, eachAccount, String.valueOf(eachAccount.Sales_Size__c));
                changeAccountOwnerIdLists.add(eachAccount.Id);
                changeAccountOwnerIdMap.put(eachAccount.Id, eachAccount);
                oldUserOwnerIdLists.add(oldAccountMap.get(eachAccount.Id).OwnerId);
            }
        }

        if(changeAccountOwnerIdMap.size()>0){
            accountService.closeAllEvent(changeAccountOwnerIdLists);
            if(Account_Service.isRelease && fromTo == 'SMEtoCBS'){
                accountService.changeAllOpenJob(changeAccountOwnerIdMap, possibleUserExtensionMapWithUserId);
            }else{
                accountService.changeAllJob(changeAccountOwnerIdMap, possibleUserExtensionMapWithUserId);
            }
            accountService.updateIndividualContactOwner(changeAccountOwnerIdMap);
        }
    }
}