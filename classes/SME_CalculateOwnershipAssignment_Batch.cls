global class SME_CalculateOwnershipAssignment_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;

    private Set<Id> hrisDiffIds;
    private Set<Id> hrisInActiveIds;
    private Map<String, User> userMapByNewRoleRC;
    private Map<String, User_MaskModel> userMaskMapByEmpId;
    private List<Id> queryOwnerIds; 
    global SME_CalculateOwnershipAssignment_Batch(Map<String, User_MaskModel> userMaskMap, Map<String, User> userMapByNewRoleRC, Set<Id> hrisDiffSet, Set<Id> hrisInActiveSet) {
        this.userMaskMapByEmpId = userMaskMap;
        this.userMapByNewRoleRC = userMapByNewRoleRC;
        this.hrisDiffIds = hrisDiffSet;
        this.hrisInActiveIds = hrisInActiveSet;

        queryOwnerIds = new List<Id>();
        queryOwnerIds.addAll(hrisDiffSet);
        queryOwnerIds.addAll(hrisInActiveSet);

        String queryJoinSet = String.join(queryOwnerIds,'\',\'');

        this.query = 'SELECT Id, Permanent_Owner_Extension__c, Permanent_Owner_Extension__r.User__c, Ownership_Text__c, Port_Pool__c, Service_RM__c, OwnerId, Owner.Profile.Name, Owner.Employee_Id__c, Owner.RC_Code__c, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Owner.Job_Code__c, Owner.ManagerId, Owner.Manager.ManagerId, Owner.Manager.Manager.ManagerId, Owner.Manager.IsActive, Owner.Manager.Manager.IsActive, Owner.Manager.Manager.Manager.IsActive, Owner.Manager.RC_Code__c, Owner.Manager.Manager.RC_Code__c, Owner.Manager.Manager.Manager.RC_Code__c, Owner.Manager.Job_Code__c, Owner.Manager.Manager.Job_Code__c, Owner.Manager.Manager.Manager.Job_Code__c FROM Account WHERE (OwnerId IN (\'' + queryJoinSet + '\') OR Permanent_Owner_Extension__r.User__c IN (\'' + queryJoinSet + '\') OR Service_RM__c IN (\'' + queryJoinSet + '\')) ORDER BY Permanent_Owner_Extension__c NULLS LAST, Service_RM__c NULLS LAST, OwnerId';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //INC000000640518
        //Account_Service.callingFromCalculateBatch = true;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        Account_Service.resetAllFlagOwnership();
		Account_Service.isBulk = true;
        SME_CalculateOwnershipAssignment_Service.createBulkAssignment(accountList, userMapByNewRoleRC, userMaskMapByEmpId, hrisDiffIds, hrisInActiveIds);
    }
    
    global void finish(Database.BatchableContext BC) {
        if(queryOwnerIds.size() > 0){
            SME_CalculateOwnershipAssignment_Service.assignUserRelatedObject(userMapByNewRoleRC, userMaskMapByEmpId, queryOwnerIds);
            SME_CalculateOwnershipAssignment_Service.assignOneTeamShareBackToOwner(queryOwnerIds);
        }
        //Add for INC000000784492  
        if(Task_Service.relateTaskList != NULL && Task_Service.relateTaskList.size() > 0){
            update Task_Service.relateTaskList;
        }
    }
    
}