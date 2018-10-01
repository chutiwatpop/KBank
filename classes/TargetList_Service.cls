public without sharing class TargetList_Service {
    private static Map<String,Integer> mapStatusCallPlanCallReportWithNumber;
    private static Map<String,Integer> mapStatusOpportunityWithNumber;
    private static Map<String,Integer> mapStatusOppPlanWithNumber;
    private static Set<String> setCloseStatusButCanReplace;
    private static Set<String> setCloseStatusCanNotReplace;
    private static Set<String> setCampaignNewBookingAndThankyouCode;
    private static final Integer NUMBER_STATUS_FROM_CALL_REPORT = 10;
    public static final String STAGE_CALL_PLAN_CALL_REPORT = 'Call Plan Call Report';
    public static final String STAGE_OPPORTUNITY_PLANNING = 'Opportunity Planing';
    public static final String STAGE_OPPORTUNITY = 'Opportunity';
    public static final String ERROR_DELETE_MSG = 'Only allow user and user that created record can delete record';
    //public static Set<String> setProfileAbleToDelete = new Set<String>{GlobalConstants.INTEGRATION_USER,GlobalConstants.PROFILE_SOLAR,GlobalConstants.SYSTEM_ADMIN};

    @future(callout=true)
    public static void upsertLeadCST(String targetListId,String oldExternalId) {
        List<Target_List__c> targetLists = new List<Target_List__c>();
        targetLists = [SELECT Id,Name,External_ID__c,External_ID_CDB__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, CIS_ID_Prospect_Name__r.CIS__c, CIS_ID_Prospect_Name__r.Name,CIS_ID_Prospect_Name__r.RecordType.Name, CIS_ID_Prospect_Name__r.Encrypt_Identification_No__c, Personalised_Message__c, CreatedDate, LastModifiedDate, CreatedBy.Employee_Id__c, LastModifiedBy.Employee_Id__c, Created_By_CDB__c, Created_Date_CDB__c, Last_Modified_By_CDB__c, Last_Modified_Date_CDB__c, CIS_ID_Prospect_Name__r.Owner.Employee_Id__c, Status__c FROM Target_List__c WHERE Id = :targetListId LIMIT 1];

        Target_List__c target;
        if(targetLists.isEmpty()) {
            return;
        } else {
            target = targetLists.get(0);
        }

        try {
            // Call Webservice
            CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
            CIBaseResponseModel responseModel = webServiceInstance.upsertCSTWebservice(target,oldExternalId);
            if(responseModel != null && responseModel.success) {
                TriggerHandler.bypass('TargetListTriggerHandler');
                update new Target_List__c(Id = target.Id,IsSyncToCDB__c = true);
            }
        } catch (Exception e) {
            System.debug('Exception:' + e);
            GlobalUtility.logMessage('ERROR','TargetList_Service','upsertLeadCST',null,null,e.getMessage(),null,e,null);
        }
    }

    public static void checkActiveTargetList(Target_List__c targetList,Map<Id,Campaign> mapPlanActiveCampaignMapById){
        if(mapPlanActiveCampaignMapById.containsKey(targetList.Lead_Campaign__c)){
            Campaign campaign = mapPlanActiveCampaignMapById.get(targetList.Lead_Campaign__c);
            if(campaign.Status == GlobalConstants.ACTIVE || campaign.Status == GlobalConstants.PLANNED){
                if(Globalconstants.SET_CAMPAING_RECORD_EVENT_DEV_NAME.contains(campaign.RecordType.DeveloperName)){
                    targetList.Event_Target_Lists__c = targetList.CIS_ID_Prospect_Name__c;
                }else{
                    targetList.Active_Target_List__c = targetList.CIS_ID_Prospect_Name__c;
                }
            }
        }
    }

    public static Boolean changeFieldInDihCondition(Target_List__c newTargetList ,Target_List__c oldTargetList){
        if(newTargetList.Personalised_Message__c != oldTargetList.Personalised_Message__c
            || newTargetList.Status__c != oldTargetList.Status__c
            || newTargetList.External_ID_CDB__c != oldTargetList.External_ID_CDB__c){
            return true;
        }
        return false;
    }

    public static void setFieldCreatedOrLastModifiedCDB(Target_List__c targetList ,User currentUserInfo){
        if(targetList.Created_By_CDB__c == null && targetList.Created_Date_CDB__c == null 
            && targetList.Last_Modified_By_CDB__c == null && targetList.Last_Modified_Date_CDB__c == null){
            targetList.Created_By_CDB__c = currentUserInfo.Employee_ID__c;
            targetList.Created_Date_CDB__c = System.now().format('yyyy-MM-dd');
            targetList.Last_Modified_By_CDB__c = currentUserInfo.Employee_ID__c;
            targetList.Last_Modified_Date_CDB__c = System.now().format('yyyy-MM-dd');
        }
    }

    public static void generateExternalId(Target_List__c newTargetList,Target_List__c oldTargetList,Map<Id, Campaign> campaignMap,Map<Id, Account> mapAccountMapById,Boolean isInsertTargetList,LPM_Customer__c LPMCustomer) {
        if(mapAccountMapById.containsKey(newTargetList.CIS_ID_Prospect_Name__c) 
            && campaignMap.containsKey(newTargetList.Lead_Campaign__c)
            && String.isBlank(newTargetList.External_ID__c)) {
            Campaign campaignOfTargetList = campaignMap.get(newTargetList.Lead_Campaign__c);
            setCampaignNewBookingAndThankyouCode = getSetCampaignNewBookingAndThankyouCode();
            if(GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c','Lead_Referral') == newTargetList.RecordTypeId){
                newTargetList.External_ID__c = campaignOfTargetList.Lead_Campaign_Event_Code__c + ':' + mapAccountMapById.get(newTargetList.CIS_ID_Prospect_Name__c).id +':Refer'+DateTime.now().getTime();
            }else if(!setCampaignNewBookingAndThankyouCode.contains(campaignOfTargetList.Lead_Campaign_Event_Code__c) && campaignOfTargetList.Type__c != GlobalConstants.CAMPAIGN){
                if(newTargetList.External_ID__c == null && campaignOfTargetList.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_DPD && LPMCustomer != null){
                    newTargetList.External_ID__c = campaignOfTargetList.Lead_Campaign_Event_Code__c + ':' + mapAccountMapById.get(newTargetList.CIS_ID_Prospect_Name__c).id + ':' + LPMCustomer.LPM__r.LPM__c;
                }else{
                    if(!isInsertTargetList){
                        if(newTargetList.Lead_Campaign__c != oldTargetList.Lead_Campaign__c || newTargetList.CIS_ID_Prospect_Name__c != oldTargetList.CIS_ID_Prospect_Name__c) {
                            if(newTargetList.Lead_Campaign__c != null){
                                newTargetList.External_ID__c = campaignOfTargetList.Lead_Campaign_Event_Code__c + ':' + mapAccountMapById.get(newTargetList.CIS_ID_Prospect_Name__c).Id;          
                            }
                        }
                    }else{
                        newTargetList.External_ID__c = campaignOfTargetList.Lead_Campaign_Event_Code__c + ':' + mapAccountMapById.get(newTargetList.CIS_ID_Prospect_Name__c).Id;
                    }
                }
            }
        }

        if(isInsertTargetList && newTargetList.External_ID__c != null && newTargetList.External_ID_CDB__c == null) {
            newTargetList.External_ID_CDB__c = newTargetList.External_ID__c;
        }
    }

    public static Set<String> getSetCampaignNewBookingAndThankyouCode(){
        if(setCampaignNewBookingAndThankyouCode == null){
            setCampaignNewBookingAndThankyouCode = new Set<String>();
            Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
            setCampaignNewBookingAndThankyouCode.add(campaignSetting.NewBooking_Code__c);
            setCampaignNewBookingAndThankyouCode.add(campaignSetting.ThankYou_Code__c);
        }
        
        return setCampaignNewBookingAndThankyouCode;
    }

    public static void setFlagSyncDataToCDB(Target_List__c newTargetList ,Target_List__c oldTargetList){
        if(TargetList_Service.changeFieldInDihCondition(newTargetList,oldTargetList)){
            newTargetList.IsSyncToCDB__c = false;
        }
    }

    public static void upsertLeadCST(List<Target_List__c> listNewTargetList,List<Target_List__c> listOldTargetList,Map<Id,Target_List__c> mapOldTargetList,Boolean isInsert) {
        if(!System.isBatch()){
            if(!isInsert){
                if(listNewTargetList.size() == 1 && TargetList_Service.changeFieldInDihCondition(listNewTargetList.get(0),listOldTargetList.get(0))) {
                    TargetList_Service.upsertLeadCST(listNewTargetList.get(0).Id,(mapOldTargetList.get(listNewTargetList.get(0).Id)).External_ID_CDB__c);
                }
            }else{
                if(listNewTargetList.size() == 1) {
                    TargetList_Service.upsertLeadCST(listNewTargetList.get(0).Id,(listNewTargetList.get(0)).External_ID_CDB__c);
                }
            }
        }
    }

    public static void setResposeDateOnStatusChange(Target_List__c oldTarget,Target_List__c newTarget){
        if(oldTarget.Status__c != newTarget.Status__c ){
            if(newTarget.Status__c == GlobalConstants.STATUS_NEW){
                newTarget.Response_Date__c = null;
            }else{
                newTarget.Response_Date__c = System.today();
            }
        }
    }

    public static void inActiveTargetListFromLPMId(Set<Id> LPMIdSet){
        List<Target_List__c> targetListToInactive = [SELECT Id,Active_Target_List__c From Target_List__c WHERE LPM__c IN :LPMIdSet AND Active_Target_List__c != null];
        if(!targetListToInactive.isEmpty()){

            for(Target_List__c eachTargetList : targetListToInactive){
                eachTargetList.Active_Target_List__c = null;
            }
        
            TriggerHandler.bypass('TargetListTriggerHandler');
            if(targetListToInactive.size() > 10000 ){
                Database.executeBatch(new SME_DML_Batch(targetListToInactive) );
            }else{
                update targetListToInactive;
            }
            TriggerHandler.clearbypass('TargetListTriggerHandler');
        }
    }

    public static void changeStatusToExpiredByTargetListExpireDateBeforeUpsert(List<Target_List__c> listTargetList){
        if(listTargetList != null){
            for(Target_List__c eachUpdateTgl : listTargetList){
                if(eachUpdateTgl.Status__c == GlobalConstants.STATUS_NEW && eachUpdateTgl.Expiry_Date__c != null && eachUpdateTgl.Expiry_Date__c < System.today()){
                    eachUpdateTgl.Status__c = GlobalConstants.TG_EXPIRED;
                    eachUpdateTgl.Active_Target_List__c = null;
                }
            }
        }
    }
    
    public static void checkTargerListExpiryDateByCampaignEndDate(Target_List__c targetListObj, Map<Id,Campaign> campaignsMap){
        if(targetListObj.Expiry_Date__c == null){
            Date targetListNewDate = System.today().addMonths(1);

            if(campaignsMap.containsKey(targetListObj.Lead_Campaign__c)){
                Campaign campaign = campaignsMap.get(targetListObj.Lead_Campaign__c);

                if(campaign.Type__c == GlobalConstants.CAMPAIGN){
                    if(targetListNewDate > campaign.EndDate){
                        targetListObj.Expiry_Date__c = campaign.EndDate;
                    }else{
                        targetListObj.Expiry_Date__c = targetListNewDate;
                    }
                }
            }
        }
    }

    public static void autoGenerateOpportunity(Target_List__c oldTarget,Target_List__c newTarget, Map<Id,Opportunity> mapNewOppWithTglId,Map<Id, Account> mapAccountMapById){
        if(isAutoGenerateOpportunity(oldTarget,newTarget)){
            Date currentDate = System.today();
            Integer year = currentDate.year();
            Integer month = currentDate.month();
            Integer day = currentDate.day();
            String stringMonth;
            if(month < 10){
                stringMonth = '0'+month;
            }
            Opportunity newOpp = new Opportunity();
            newOpp.AccountId = newTarget.CIS_ID_Prospect_Name__c;
            newOpp.Name = year+'/'+stringMonth+'/'+day+'_'+ mapAccountMapById.get(newTarget.CIS_ID_Prospect_Name__c).Name;
            newOpp.StageName = Globalconstants.STATUS_OPEN;
            newOpp.CloseDate = System.today() + Integer.valueOf(Label.Default_Job_CloseDate);
            newOpp.IsLead__c = true;
            mapNewOppWithTglId.put(newTarget.Id,newOpp);
        }
    }

    public static void setOpportunityFlagIsLead(Target_List__c oldTarget,Target_List__c newTarget,Map<Id,Opportunity> mapUpdateOppById){
        if(newTarget.Opportunity__c != oldTarget.Opportunity__c){
            if(!String.isBlank(newTarget.Opportunity__c)){
                Opportunity updateOppFlag = new Opportunity(Id = newTarget.Opportunity__c, IsLead__c = true);
                mapUpdateOppById.put(updateOppFlag.Id,updateOppFlag);
            }
            if(!String.isBlank(oldTarget.Opportunity__c)){
                Opportunity updateOppUnflag = new Opportunity(Id = oldTarget.Opportunity__c, IsLead__c = false);
                mapUpdateOppById.put(updateOppUnflag.Id,updateOppUnflag);
            }
        }
    }

    public static Boolean isAutoGenerateOpportunity(Target_List__c oldTarget,Target_List__c newTarget){
        if(!newTarget.DoneCreateJob__c && !oldTarget.Create_New_Job__c && newTarget.Create_New_Job__c){
            return true;
        }
        return false;
    }

    public static void setRelationToOpportunity(Target_List__c newTarget,Opportunity relatedOpp){
        newTarget.Create_New_Job__c = false;
        newTarget.DoneCreateJob__c = true;
        newTarget.Opportunity__c = relatedOpp.Id;
    }

    public static void checkDeletePermission(Target_List__c newTarget,String currentUserProfileName){
        String profileAllowedDelete = Label.Profile_Can_Delete_Target_List;
        if(UserInfo.getUserId() != newTarget.CreatedById && !profileAllowedDelete.containsIgnoreCase(currentUserProfileName)){
            newTarget.addError(ERROR_DELETE_MSG);
        }
    }
}