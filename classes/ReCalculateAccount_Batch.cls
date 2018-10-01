global class ReCalculateAccount_Batch implements Database.Batchable<sObject> {
    String query;
    String queryField = 'SELECT Id, OwnerId, Owner.Profile.Name, Previous_Owner__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Previous_Owner__r.RC_Code__c, Previous_Owner__r.AH_RC_Code__c, Previous_Owner__r.NH_RC_Code__c, Previous_Owner__r.Employee_ID__c FROM Account';
    User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
    User rbsAdminUser = User_Service.getUserInfoWithName('RBS Admin');
    Map<String,Id> teamMapByRc = TeamStructure_Service.getAllTeamStructureMapByRCTeamId();

    global ReCalculateAccount_Batch() {
        this.query = queryField;
    }

    global ReCalculateAccount_Batch(List<Id> accountIdList) {
        this.query = queryField+' WHERE Id IN (\''+ String.join(accountIdList, '\',\'') + '\')';
    }

    // Possible calculate segment SME,CBS,RBS,AF,OTHER
    global ReCalculateAccount_Batch(String calculateSegment) {
        String[] ownerSegmentList = new String[0];
        if(calculateSegment == 'SME'){
            ownerSegmentList.addAll(GlobalConstants.SME_SEGMENT_CODE_SET);
        }else if(calculateSegment == 'CBS'){
            ownerSegmentList.addAll(GlobalConstants.CBS_SEGMENT_CODE_SET);
        }else if(calculateSegment == 'RBS'){
            ownerSegmentList.addAll(GlobalConstants.RBS_PRIMARY_SEGMENT_CODE_SET);
        }else if(calculateSegment == 'AF'){
            ownerSegmentList.addAll(GlobalConstants.AF_PRIMARY_SEGMENT_CODE_SET);
        }
        if(ownerSegmentList.size() > 0){
            this.query = queryField+' WHERE Owner.Segment__c IN (\''+ String.join(ownerSegmentList, '\',\'') + '\') AND Primary_Segment_Code__c IN (\'MI\',\'TC\',\'RO\',\'PC\') AND RecordType.Name NOT IN (\'Organization Prospect\',\'Individual Prospect\') ';
        }else{
            this.query = queryField;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Id> userIdList = new List<Id>();
        Set<Id> accountIdList = new Set<Id>();
        Map<Id,User> possibleUserMap = new Map<Id,User>();
        List<Account> updateAccountList = new List<Account>();
        // List<Opportunity> updateOpportunityList = new List<Opportunity>();
        // AccountChangeOwner accountService = new AccountChangeOwner();
        // Map<Id,List<Opportunity>> possibleJobMap  = new Map<Id,List<Opportunity>>();
        // Map<Id,List<Target_List__c>> possibleTargetListMap  = new Map<Id,List<Target_List__c>>();
        // Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
        // Map<Id,List<Application_History__c>> possibleApplicationHistoryMap  = new Map<Id,List<Application_History__c>>();
        // Map<Id,List<Customer_Ownership_Request__c>> possibleCustomerOwnershipRequestMap  = new Map<Id,List<Customer_Ownership_Request__c>>();
        // for(Account eachAccount : scope){
        //     userIdList.add(eachAccount.OwnerId);
        //     accountIdList.add(eachAccount.Id);
        // }
        
        // possibleJobMap = queryPossibleJobMap(userIdList, accountIdList);
        // possibleTargetListMap = queryPossibleTargetListMap(accountIdList);
        // possibleApplicationHistoryMap = queryPossibleApplicationHistoryMap(userIdList, accountIdList);
        // possibleCustomerOwnershipRequestMap = queryPossibleCustomerOwnershipRequestMap(userIdList, accountIdList);

        // userIdList.add(currentUser.Id);
        // possibleUserMap = User_Service.getUserMapWithId(userIdList);
        // possibleUserExtensionMapWithUserId = UserExtension_Service.getUserExtensionMapByUserId(userIdList);

        // System.debug('possibleJobMap');
        // System.debug(possibleJobMap);
        // System.debug('possibleTargetListMap');
        // System.debug(possibleTargetListMap);
        // System.debug('possibleCustomerOwnershipRequestMap');
        // System.debug(possibleCustomerOwnershipRequestMap);

        for(Account eachAccount : scope){
            eachAccount.OwnerId = rbsAdminUser.Id;
            eachAccount.Port_Pool__c = null;
            eachAccount.Ownership_Text__c = null;
            eachAccount.Trash_Pool_Flag__c = false;
            clearCurrentOwnerFieldsSet(eachAccount);
            clearPermanentOwnerFieldsSet(eachAccount);                   
            updateAccountList.add(eachAccount);
            // if(!possibleJobMap.containsKey(eachAccount.Id) && !possibleTargetListMap.containsKey(eachAccount.Id) && !possibleCustomerOwnershipRequestMap.containsKey(eachAccount.Id)){
            //     setupDefultValue(accountService, eachAccount, teamMapByRc, possibleUserExtensionMapWithUserId);
            //     updateAccountList.add(eachAccount);
            // }else if(possibleJobMap.containsKey(eachAccount.Id) && !possibleTargetListMap.containsKey(eachAccount.Id) && !possibleCustomerOwnershipRequestMap.containsKey(eachAccount.Id)){
            //     setupDefultValue(accountService, eachAccount, teamMapByRc, possibleUserExtensionMapWithUserId);
            //     for(Opportunity eachOpportunity : possibleJobMap.get(eachAccount.Id)){
            //         if(eachOpportunity.StageName == GlobalConstants.ON_PROCESS || eachOpportunity.StageName == GlobalConstants.NEW_OPPORTUNITY){
            //             if(eachOpportunity.OwnerId != eachAccount.OwnerId){
            //                 if(possibleUserExtensionMapWithUserId.get(eachOpportunity.OwnerId) == null){
            //                     eachOpportunity.OwnerId = eachAccount.OwnerId;
            //                     updateOpportunityList.add(eachOpportunity);
            //                 }else{
            //                     eachAccount.SME_Temporary_Customer__c = possibleUserExtensionMapWithUserId.get(eachOpportunity.OwnerId).Id;
            //                     break;
            //                 }
            //             }
            //         }else{
            //             if(possibleApplicationHistoryMap.containsKey(eachAccount.Id)){
            //                 for(Application_History__c eachApplicationHistory : possibleApplicationHistoryMap.get(eachAccount.Id)){
            //                     if(eachApplicationHistory.IsNewCredit__c == 1 && eachApplicationHistory.App_Result__c == GlobalConstants.CLOSED_WON){
            //                         break;
            //                     }
            //                 }
            //             }else{
            //                 eachAccount.Port_Pool__c = GlobalConstants.POOL;
            //                 eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
            //             }
            //         }
            //     }
            //     updateAccountList.add(eachAccount);
            // }else if(!possibleJobMap.containsKey(eachAccount.Id) && possibleTargetListMap.containsKey(eachAccount.Id) && !possibleCustomerOwnershipRequestMap.containsKey(eachAccount.Id)){
            //     setupDefultValue(accountService, eachAccount, teamMapByRc, possibleUserExtensionMapWithUserId);
            //     eachAccount.SME_Temporary_Customer__c = possibleUserExtensionMapWithUserId.get(eachAccount.OwnerId).Id;
            //     updateAccountList.add(eachAccount);
            // }
        }
        if(updateAccountList.size() > 0){
            System.debug('updateAccountList');
            System.debug(updateAccountList.size());
            System.debug(updateAccountList);

            TriggerHandler.bypass('AccountTriggerHandler');
            List<Database.SaveResult> SR = Database.update(updateAccountList,false);
            TriggerHandler.clearBypass('AccountTriggerHandler');
            System.debug(SR);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    // private void setupDefultValue(AccountChangeOwner accountService, Account eachAccount, Map<String,Id> teamMapByRc, Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId){
    //     if(eachAccount.Owner.Profile.Name.contains('RM')){
    //         eachAccount.Port_Pool__c = GlobalConstants.PORT;
    //     }else{
    //         eachAccount.Port_Pool__c = GlobalConstants.POOL;
    //     }
    //     eachAccount.Trash_Pool_Flag__c = false;
    //     eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
    //     eachAccount.SME_Temporary_Customer__c = null;
    //     accountService.setCurrentOwnerFieldsSet(eachAccount, teamMapByRc, possibleUserExtensionMapWithUserId.get(eachAccount.OwnerId));
    //     accountService.setPermanentOwnerFieldsSet(eachAccount, teamMapByRc, possibleUserExtensionMapWithUserId.get(eachAccount.OwnerId));
    // }

    // private Map<Id,List<Opportunity>> queryPossibleJobMap(List<Id> userIdList, Set<Id> accountIdLists){
    //     Map<Id,List<Opportunity>> possibleJobMap  = new Map<Id,List<Opportunity>>();
    //     List<Opportunity> possibleOpportunityList = new List<Opportunity>();
    //     possibleOpportunityList = [SELECT Id, AccountId, OwnerId, Owner.Name, Account.Owner.Name, StageName, LastModifiedBy.Name, CreatedDate, LastModifiedDate FROM Opportunity WHERE AccountId IN:accountIdLists ORDER BY LastModifiedDate];
        
    //     for(Opportunity eachOpportunity : possibleOpportunityList){
    //         userIdList.add(eachOpportunity.OwnerId);
    //         if(possibleJobMap.containsKey(eachOpportunity.AccountId)){
    //             possibleJobMap.get(eachOpportunity.AccountId).add(eachOpportunity);
    //         }else{
    //             List<Opportunity> tempOpportunity = new List<Opportunity>();
    //             tempOpportunity.add(eachOpportunity);
    //             possibleJobMap.put(eachOpportunity.AccountId, tempOpportunity);
    //         }
    //     }
    //     return possibleJobMap;
    // }

    // private Map<Id,List<Target_List__c>> queryPossibleTargetListMap(Set<Id> accountIdLists){
    //     Map<Id,List<Target_List__c>> possibleTargetListMap  = new Map<Id,List<Target_List__c>>();
    //     List<Target_List__c> possibleTargetList = new List<Target_List__c>();
    //     possibleTargetList = [SELECT Id, CIS_ID__c, Lead_Response__c, Status__c FROM Target_List__c WHERE CIS_ID__c IN:accountIdLists AND Lead_Campaign__r.IsActive = true];
        
    //     for(Target_List__c eachTargetList : possibleTargetList){
    //         if(possibleTargetListMap.containsKey(eachTargetList.CIS_ID__c)){
    //             possibleTargetListMap.get(eachTargetList.CIS_ID__c).add(eachTargetList);
    //         }else{
    //             List<Target_List__c> tempTargetList = new List<Target_List__c>();
    //             tempTargetList.add(eachTargetList);
    //             possibleTargetListMap.put(eachTargetList.CIS_ID__c, tempTargetList);
    //         }
    //     }
    //     return possibleTargetListMap;
    // }

    // private Map<Id,List<Customer_Ownership_Request__c>> queryPossibleCustomerOwnershipRequestMap(List<Id> userIdList, Set<Id> accountIdLists){
    //     Map<Id,List<Customer_Ownership_Request__c>> possibleCustomerOwnershipRequestMap  = new Map<Id,List<Customer_Ownership_Request__c>>();
    //     List<Customer_Ownership_Request__c> possibleCustomerOwnershipRequest = new List<Customer_Ownership_Request__c>();
    //     possibleCustomerOwnershipRequest = [SELECT Id, CIS_ID__c, Approval_Status__c, Approved_Date__c, Assigned_Port_Pool__c, Request_Ownership_Type__c, Request_Type__c, Refer_Out_Reason__c, OwnerId, Requestor_Name__c, Current_Owner__c,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c IN:accountIdLists];
        
    //     for(Customer_Ownership_Request__c eachCustomerOwnershipRequest : possibleCustomerOwnershipRequest){
    //         userIdList.add(eachCustomerOwnershipRequest.OwnerId);
    //         userIdList.add(eachCustomerOwnershipRequest.Current_Owner__c);
    //         if(possibleCustomerOwnershipRequestMap.containsKey(eachCustomerOwnershipRequest.CIS_ID__c)){
    //             possibleCustomerOwnershipRequestMap.get(eachCustomerOwnershipRequest.CIS_ID__c).add(eachCustomerOwnershipRequest);
    //         }else{
    //             List<Customer_Ownership_Request__c> tempCustomerOwnershipRequest = new List<Customer_Ownership_Request__c>();
    //             tempCustomerOwnershipRequest.add(eachCustomerOwnershipRequest);
    //             possibleCustomerOwnershipRequestMap.put(eachCustomerOwnershipRequest.CIS_ID__c, tempCustomerOwnershipRequest);
    //         }
    //     }
    //     return possibleCustomerOwnershipRequestMap;
    // }

    // private Map<Id,List<Application_History__c>> queryPossibleApplicationHistoryMap(List<Id> userIdList, Set<Id> accountIdLists){
    //     Map<Id,List<Application_History__c>> possibleApplicationHistoryMap  = new Map<Id,List<Application_History__c>>();
    //     List<Application_History__c> possibleApplicationHistory = new List<Application_History__c>();
    //     possibleApplicationHistory = [SELECT Id, App_Num_Selected__c, IsNewCredit__c, App_Result__c, RMSubmitChannel__c, Current_Owner_Extension__c, Current_Owner_Extension__r.name, Current_Team_Name__c, Current_AH_Team__c, Current_NH_Team__c, Current_Owner_Extension__r.segment__c, OppName__r.owner.name, OppName__r.owner.RC_Code__c, OppName__r.AccountId, OppName__r.owner.Segment__c, OppName__r.Account.owner.name, OppName__r.account.SME_Temporary_Customer__r.name, OppName__r.account.RecordType.name FROM Application_History__c WHERE OppName__r.AccountId IN:accountIdLists];
        
    //     for(Application_History__c eachApplicationHistory : possibleApplicationHistory){
    //         userIdList.add(eachApplicationHistory.OppName__r.AccountId);
    //         if(possibleApplicationHistoryMap.containsKey(eachApplicationHistory.OppName__r.AccountId)){
    //             possibleApplicationHistoryMap.get(eachApplicationHistory.OppName__r.AccountId).add(eachApplicationHistory);
    //         }else{
    //             List<Application_History__c> tempApplicationHistory = new List<Application_History__c>();
    //             tempApplicationHistory.add(eachApplicationHistory);
    //             possibleApplicationHistoryMap.put(eachApplicationHistory.OppName__r.AccountId, tempApplicationHistory);
    //         }
    //     }
    //     return possibleApplicationHistoryMap;
    // }

    private void clearCurrentOwnerFieldsSet(Account accountObj) {
        accountObj.Current_Owner_Extension__c = null;
        accountObj.Current_AH_Name__c         = null;
        accountObj.Current_NH_Name__c         = null;
        accountObj.Current_Team_Name__c       = null;
    }

    private void clearPermanentOwnerFieldsSet(Account accountObj) {
        accountObj.Permanent_Owner__c           = null;
        accountObj.Permanent_Owner_Extension__c = null;
        accountObj.Permanent_AH_Name__c         = null;
        accountObj.Permanent_NH_Name__c         = null;
        accountObj.Permanent_Team_Name__c       = null;
    }
}