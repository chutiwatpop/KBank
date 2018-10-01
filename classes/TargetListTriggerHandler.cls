public without sharing class TargetListTriggerHandler extends TriggerHandler {
    private User currentUser;
    public static Map<Id,Id> campaignIdMap;
    public static Map<Id,Campaign> mapAllCampaignMapById;
    public static Map<Id, Account> mapAccountMapById;
    public static Boolean isBypassLeadBackward = false;
    public static Boolean isBypassGenerateExternalId = false;

    public override void allBefore() {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
        campaignIdMap = new Map<Id,Id>();
        currentUser = [SELECT Id,Name,Employee_ID__c,Profile.Name FROM User WHERE ID = :UserInfo.getUserId()];
        if(!Trigger.isDelete){
            mapAllCampaignMapById = new Map<Id,Campaign>([SELECT Id, Type__c, Status,Sub_Type__c, Lead_Campaign_Event_Code__c,EndDate,RecordType.DeveloperName FROM Campaign]);
            for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
                if(eachTarget.CIS_ID_Prospect_Name__c != null){
                    accountIds.add(eachTarget.CIS_ID_Prospect_Name__c);
                }

                if(eachTarget.Lead_Campaign__c != null && !campaignIdMap.containsKey(eachTarget.Lead_Campaign__c)){
                    campaignIdMap.put(eachTarget.Lead_Campaign__c,eachTarget.Lead_Campaign__c);
                }

                if(eachTarget.Create_New_Job__c && !String.isBlank(eachTarget.Opportunity__c)){
                    eachTarget.addError(LABEL.PLEASE_CHOOSE_NEW_OR_EXISTING_JOB);
                }
            }

            mapAccountMapById = new Map<Id, Account>([SELECT Id, RecordTypeId, CIS__c,OwnerId,Name  FROM Account WHERE Id IN :accountIds]);
            TargetList_Service.changeStatusToExpiredByTargetListExpireDateBeforeUpsert((List<Target_List__c>)Trigger.new);
        }
    }

    public override void beforeInsert() {
        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
            
            TargetList_Service.setFieldCreatedOrLastModifiedCDB(eachTarget, currentUser);

            TargetList_Service.checkActiveTargetList(eachTarget, mapAllCampaignMapById);
            TargetList_Service.checkTargerListExpiryDateByCampaignEndDate(eachTarget, mapAllCampaignMapById);

            if(!isBypassGenerateExternalId){
                TargetList_Service.generateExternalId(eachTarget,null, mapAllCampaignMapById, mapAccountMapById, Trigger.isInsert,null);
            }
        }
    }

    public override void beforeUpdate() {
        Target_List__c oldRecord;
        Map<Id,Opportunity> mapNewOppByTglId = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapUpdateOppById = new Map<Id,Opportunity>();
        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
            oldRecord = (Target_List__c) Trigger.oldMap.get(eachTarget.Id);

            TargetList_Service.setFlagSyncDataToCDB(eachTarget,oldRecord);

            TargetList_Service.setResposeDateOnStatusChange(oldRecord,eachTarget);
            
            TargetList_Service.autoGenerateOpportunity(oldRecord,eachTarget,mapNewOppByTglId,mapAccountMapById);

            TargetList_Service.setOpportunityFlagIsLead(oldRecord,eachTarget,mapUpdateOppById);
            
            if(!isBypassGenerateExternalId){
                TargetList_Service.generateExternalId(eachTarget,oldRecord, mapAllCampaignMapById, mapAccountMapById, Trigger.isInsert,null);
            }

            if(eachTarget.Status__c != oldRecord.Status__c){
                eachTarget.RBS_Path__c = eachTarget.Status__c;
            }
        }

        if(!mapUpdateOppById.values().isEmpty()){
            update mapUpdateOppById.values();
        }

        if(!mapNewOppByTglId.values().isEmpty()){
            insert mapNewOppByTglId.values();
            Target_List__c newTglAutoGenOpp;
            for(Id tglId : mapNewOppByTglId.keySet()){
                newTglAutoGenOpp = (Target_List__c) Trigger.newMap.get(tglId);
                oldRecord = (Target_List__c) Trigger.oldMap.get(tglId);
                if(TargetList_Service.isAutoGenerateOpportunity(oldRecord,newTglAutoGenOpp)){
                    TargetList_Service.setRelationToOpportunity(newTglAutoGenOpp,mapNewOppByTglId.get(newTglAutoGenOpp.Id));
                }
            }
        }
    }

    public override void afterInsert() {
        Map<Id,Target_List__c> targetListWithTargetListIdMap = new Map<Id,Target_List__c>();
        for (Target_List__c eachTargetList : (List<Target_List__c>)Trigger.new){
            if(eachTargetList.Opportunity__c != null && !targetListWithTargetListIdMap.containsKey(eachTargetList.Opportunity__c)) targetListWithTargetListIdMap.put(eachTargetList.Opportunity__c,eachTargetList);
        }
        TargetList_Service.upsertLeadCST((List<Target_List__c>)Trigger.new, (List<Target_List__c>)Trigger.old, (Map<Id,Target_List__c>) Trigger.oldMap, true);
        GroupSubGroup_Service.setAccountGroupSubGroupUpdate((List<Target_List__c>)Trigger.new);
        if(targetListWithTargetListIdMap.size() > 0){
            JunctionService junction_service = new JunctionService();
		    junction_service.initialJunctionWithOpportunityId(targetListWithTargetListIdMap.keySet());
        }
    }

    public override void afterUpdate() {
        List<Id> removeJunctionList = new List<Id>();
        Map<Id,Target_List__c> targetListWithTargetListIdMap = new Map<Id,Target_List__c>();
        for (Target_List__c eachTargetList : (List<Target_List__c>)Trigger.new){
            if(eachTargetList.Opportunity__c != null && !targetListWithTargetListIdMap.containsKey(eachTargetList.Opportunity__c)) targetListWithTargetListIdMap.put(eachTargetList.Opportunity__c,eachTargetList);
            Target_List__c oldTargetList = (Target_List__c) Trigger.oldMap.get(eachTargetList.Id);
            if(oldTargetList.Opportunity__c != null && eachTargetList.Opportunity__c == null) removeJunctionList.add(eachTargetList.Id);
        }
        TargetList_Service.upsertLeadCST((List<Target_List__c>)Trigger.new, (List<Target_List__c>)Trigger.old, (Map<Id,Target_List__c>) Trigger.oldMap, false);
        if(targetListWithTargetListIdMap.size() > 0){
            JunctionService junction_service = new JunctionService();
		    junction_service.initialJunctionWithOpportunityId(targetListWithTargetListIdMap.keySet());
        }
        if(removeJunctionList.size() > 0){
            List<Junction__c> deleteJunctionList = [SELECT Id FROM Junction__c WHERE Target_List__c IN:removeJunctionList];
            Delete deleteJunctionList;
        }
    }

    public override void beforeDelete() {
        String currentUserProfileName = currentUser.Profile.Name;
        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.old) {
            TargetList_Service.checkDeletePermission(eachTarget,currentUserProfileName);
        }
    }
}