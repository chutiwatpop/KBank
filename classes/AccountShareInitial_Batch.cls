/**
* @author komsan.wi@beryl8.com
* @05/08/2015 createddate
*/
global class AccountShareInitial_Batch implements Database.Batchable<sObject>,Database.Stateful {
    private Map<String,String> userRoleMapping;
    private Map<Id,User> ownerUserMap;
    private String query;
    private List<Id> queryOwnerIds;
    
    global AccountShareInitial_Batch() {
        this.query = 'SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c,CIS__c FROM Account';
        userRoleMapping = User_Service.queryUserRole();
        ownerUserMap = new Map<Id,User>([SELECT Id,UserRole.Name,AH_RC_CODE__c,NH_RC_CODE__c,UserRole.DeveloperName,Manager.UserRole.Name,Manager.UserRole.DeveloperName,Manager.Manager.UserRole.Name,Manager.Manager.UserRole.DeveloperName,IsActive,ProfileId,Profile.Name, ManagerId,Manager.Name,Manager.IsActive,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.IsActive,Manager.Manager.ProfileId,Manager.Manager.Profile.Name,RC_Code__c FROM User]);
    }
    
    global AccountShareInitial_Batch(Set<Id> accountIdSet) {
        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(accountIdSet);
        String queryJoinSet = String.join(queryOwnerIds,'\',\'');

        this.query = 'SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c,CIS__c FROM Account WHERE Id IN (\''+queryJoinSet+'\')';
        userRoleMapping = User_Service.queryUserRole();
        ownerUserMap = new Map<Id,User>([SELECT Id,UserRole.Name,AH_RC_CODE__c,NH_RC_CODE__c,UserRole.DeveloperName,Manager.UserRole.Name,Manager.UserRole.DeveloperName,Manager.Manager.UserRole.Name,Manager.Manager.UserRole.DeveloperName,IsActive,ProfileId,Profile.Name, ManagerId,Manager.Name,Manager.IsActive,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.IsActive,Manager.Manager.ProfileId,Manager.Manager.Profile.Name,RC_Code__c FROM User]);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountScope) {
        List<Account_MaskModel> accountTargetList = new List<Account_MaskModel>();
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        Map<String,List<String>> accountIdByGroupNameMap = new Map<String,List<String>>();
        Set<Id> sharingRuleDeleteSet = new Set<Id>();
        List<String> accountIdByGroupNameList = new List<String>();
        Set<Id> relatedUpdateSet = new Set<Id>(); //Add For CR018
        for(Account eachAccount : accountScope){
            accountTargetList.add(new Account_MaskModel(eachAccount));
        }
        for(Account_MaskModel maskObj : accountTargetList){
            maskObj
                .setPreviousOwner(ownerUserMap.get(maskObj.accObj.Previous_Owner__c))
                .setOwner(ownerUserMap.get(maskObj.accObj.OwnerId));

            if(maskObj.haveToDeletedSharingRule) sharingRuleDeleteSet.add(maskObj.accObj.Id);

            List<String> sharingGroupNameList = Account_Service.getSharingGroupNameWithConfig(maskObj,userRoleMapping);
            System.debug(sharingGroupNameList);
            if(sharingGroupNameList!=null && sharingGroupNameList.size() > 0){
                accountIdByGroupNameList.addAll(sharingGroupNameList);
                accountIdByGroupNameMap.put(maskObj.accObj.Id, sharingGroupNameList);
            }
            relatedUpdateSet.add(maskObj.accObj.Id);
        }

        if(!sharingRuleDeleteSet.isEmpty())
            delete [SELECT Id FROM AccountShare WHERE AccountId in :sharingRuleDeleteSet AND RowCause = 'Manual'];

        if(!accountIdByGroupNameMap.isEmpty()){
            List<Group> groupList = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName in :accountIdByGroupNameList AND Type='RoleAndSubordinates'];
            for(String eachAccountId :accountIdByGroupNameMap.keyset()){
                for(Group eachGroup : groupList){

                    List<String> tempGroupList = accountIdByGroupNameMap.get(eachAccountId);
                    for(String eachtempGroup : tempGroupList){
                        if(eachGroup.DeveloperName == eachtempGroup){
                            accountShareInsertList.add(new AccountShare(
                                    CaseAccessLevel = 'none',
                                    OpportunityAccessLevel = 'none',
                                    AccountAccessLevel = 'read',
                                    AccountId = eachAccountId,
                                    UserOrGroupId = eachGroup.Id
                            ));
                        }
                    }
                }
            }
            if(!accountShareInsertList.isEmpty()){
                insert accountShareInsertList;
            }
        }

        //Add For CR020&CR018
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        List<OpportunityShare> opportunityShareUpdateList = new List<OpportunityShare>();
        Set<Id> oppsharingDeleteSet = new Set<Id>();
        Boolean toUpdate = false;

        opportunityUpdateList = [SELECT Id,StageName,IsClosed,OwnerId,AccountId,Account.OwnerId,Account.Owner.ProfileId,Account.Owner.Profile.Name, Current_Team_Name__r.RC_Code__c FROM Opportunity WHERE AccountId IN :relatedUpdateSet];
        if(opportunityUpdateList!=null && opportunityUpdateList.size() > 0){
            for(Opportunity eachOpportunity : opportunityUpdateList){
                for(Account_MaskModel eachMask : accountTargetList){
                    if(eachMask.accObj.Id == eachOpportunity.AccountId){
                        //CR018 put to DeleteOppShare
                        if(eachMask.haveToDeletedSharingRule){
                            oppsharingDeleteSet.add(eachOpportunity.AccountId);
                        }
                    }
                }
                //Add For CR018 accountShareInsertList
                if(!accountShareInsertList.isEmpty()){
                    for(AccountShare eachAccountShare : accountShareInsertList){
                        if(eachAccountShare.AccountId == eachOpportunity.AccountId){
                            opportunityShareUpdateList.add(new OpportunityShare(
                                OpportunityAccessLevel = 'read',
                                OpportunityId = eachOpportunity.Id,
                                UserOrGroupId = eachAccountShare.UserOrGroupId
                            ));
                        }
                    }
                }
            }
            // ADD For CR020 Dec2016 & CR 018
            if(opportunityShareUpdateList !=null) {
                opportunityShareUpdateList.addAll(Account_Service.setOpportunityShareInsertList(opportunityUpdateList,accountTargetList));
            }
            if(!oppsharingDeleteSet.isEmpty()){
                delete [SELECT Id FROM OpportunityShare WHERE OpportunityId in :oppsharingDeleteSet AND RowCause = 'Manual'];
            }
            if(!opportunityShareUpdateList.isEmpty()){
                insert opportunityShareUpdateList;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}