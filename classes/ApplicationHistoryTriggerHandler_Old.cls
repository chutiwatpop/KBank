public without sharing class ApplicationHistoryTriggerHandler_Old extends TriggerHandler{
    private Map<String,String> mapCreditModel = new Map<String,String>{'DLA' => 'A','FL' => '1','HPL' => '8','PL' => '9'};
    public static Map<String,Business_Code__c> mapRelatedBusinessCode;
    private static Map<Id, User> oppOwnerMap;

    public override void beforeInsert(){
    	Map<String, Application_Number__c> appNumberUpsertMapByRC = new Map<String, Application_Number__c>();
    	String currentYear = String.valueOf(GlobalUtility.getYearInBuddhistCalendar(System.today()));
    	Set<Id> relatedOppIDSet = new Set<Id>();
    	Map<Id,Opportunity> opportunityByOppIdMap = new Map<Id,Opportunity>();

    	for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
    		if(eachApp.RMSubmitChannel__c == GlobalConstants.NON_CMAS){
    			relatedOppIDSet.add(eachApp.OppName__c);
    		}
    	}

    	List<Opportunity> oppList = [SELECT Id,Account.RC_Code__c,Business_Code_Text__c FROM Opportunity WHERE Id=:relatedOppIDSet];
    	for(Opportunity eachOpp : oppList){
    		opportunityByOppIdMap.put(eachOpp.Id,eachOpp);
    	}

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new) {
            if(opportunityByOppIdMap.containsKey(eachApp.OppName__c)){
            	if(eachApp.Business_Code_Text__c == null){
            		eachApp.Business_Code_Text__c = opportunityByOppIdMap.get(eachApp.OppName__c).Business_Code_Text__c;
	        	}
                if(eachApp.RunningRC__c == null && eachApp.AppNum_NonCMAS__c == null){
                    String rcCode;
                    if (opportunityByOppIdMap.get(eachApp.OppName__c) != null) {
                        rcCode = opportunityByOppIdMap.get(eachApp.OppName__c).Account.RC_Code__c;
                    } else {
                        rcCode = GlobalConstants.NO_RC_CODE;
                    }

                    Application_Number__c applicationNumberByRC = Application_Number__c.getValues(rcCode);
                    if(applicationNumberByRC != null){
                        applicationNumberByRC.Running_Number__c = applicationNumberByRC.Running_Number__c + 1;
                        if (currentYear != applicationNumberByRC.Year__c) {
                            applicationNumberByRC.Year__c = currentYear;
                            applicationNumberByRC.Running_Number__c = 1;
                            applicationNumberByRC.Name = rcCode;
                        }
                    }else{
                        applicationNumberByRC = new Application_Number__c();
                        applicationNumberByRC.Name = rcCode;
                        applicationNumberByRC.Running_Number__c = 1;
                        applicationNumberByRC.Year__c = currentYear;
                    }
                    String runningNumberString = '000' + Integer.valueOf(applicationNumberByRC.Running_Number__c);
                    eachApp.RunningRC__c = runningNumberString.substring(runningNumberString.length() - 4);
                    appNumberUpsertMapByRC.put(rcCode, applicationNumberByRC);
                }
            }
        }

        if (appNumberUpsertMapByRC.size() > 0) {
            upsert appNumberUpsertMapByRC.values();
        }

    }

    public override void beforeUpdate() {

        for (Application_History__c eachApplicationHistory : ((List<Application_History__c>) Trigger.new)) {

            if(GlobalConstants.APP_HISTORY_STATUS_FOR_UPDATE_APPHISTORY.contains(eachApplicationHistory.App_Result__c)){

                user userData = UserService.getCurrentUserInfo();
                User_Extension__c user = [select id,User__c,name,Team_Structure__c,Team_Structure__r.name, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c from User_Extension__c where user__c = :userData.Id];
                eachApplicationHistory.OwnerExtension__c = user.Id;
                eachApplicationHistory.TeamStructure__c = user.Team_Structure__c;
                eachApplicationHistory.AHName__c = user.Team_Structure__r.AH_Name__c;
                eachApplicationHistory.NHName__c = user.Team_Structure__r.NH_Name__c;

            }
        }
      }

    public override void allAfter(){
        //industry data
        mapRelatedBusinessCode = new Map<String,Business_Code__c>();
        List<String> listBusinessCodeFromAppHis = new List<String>();
        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
            listBusinessCodeFromAppHis.add(eachApp.SPBusinessCode__c);
        }
        Map<String,Business_Code__c> mapTempBusinessCode = new Map<String,Business_Code__c>();
        List<Business_Code__c> listRelatedBusinessCode = [SELECT Id,Name,Segment__c FROM Business_Code__c WHERE Name IN :listBusinessCodeFromAppHis];
        for(Business_Code__c eachBusinessCode : listRelatedBusinessCode){
            mapTempBusinessCode.put(eachBusinessCode.Name+':'+eachBusinessCode.Segment__c, eachBusinessCode);
        }

        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
            if(mapTempBusinessCode.containsKey(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c)){
                mapRelatedBusinessCode.put(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c, mapTempBusinessCode.get(eachApp.SPBusinessCode__c+':'+eachApp.Owner_Segment__c));
            }
        }

    }

    public override void afterInsert() {
        ApplicationHistory_Service.insertOpportunityProductNonCMAS((List<Application_History__c>) Trigger.new);
    }

    public override void afterUpdate() {
        ApplicationHistory_Service.updateOpportunityProductNonCMAS((List<Application_History__c>) Trigger.new,(Map<Id,Application_History__c>)Trigger.newMap);
    	oppOwnerMap  = new Map<Id, User>();
    	Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
    	Map<String, Set<String>> completeOppIdsMapBySegment = new Map<String, Set<String>>();
    	Map<Id, Target_List__c> targetNewbookingMapByAppId = new Map<Id, Target_List__c>();
        List<Target_List__c> deleteTargetList = new List<Target_List__c>();
        List<Opportunity> relatedOppList = new List<Opportunity>();
        Set<Id> relatedOppIDSet = new Set<Id>();
		Set<Id> relatedUserIDSet = new Set<Id>();
		Map<Id,User> allUserRelateByUserIdMap = new Map<Id,User>();
        

        String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        String RECORDTYPE_TARGETLIST_STANDARD = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Target_List__c','Standard'); 

        if(campaignNewBookingCode != null) {
            for(Target_List__c target : [Select Application_History__c, Lead_Campaign__c, Name, Status__c, Approved_Amount__c, Setup_Amount__c, Campaign_Reward_Calc__c, Option__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c = :campaignNewBookingCode AND Application_History__c IN :Trigger.New]){
                targetNewbookingMapByAppId.put(target.Application_History__c, target);    
            }
        }


        for(Application_History__c eachApp : (List<Application_History__c>) Trigger.new){
    		relatedOppIDSet.add(eachApp.OppName__c);
    	}
		
		relatedOppList = [SELECT Id,OwnerId FROM Opportunity WHERE Id=:relatedOppIDSet];
    	for(Opportunity eachOpp : relatedOppList){
    		relatedUserIDSet.add(eachOpp.OwnerId);
    	}

    	List<User> appOwnerList = [SELECT Id,Segment__c FROM User WHERE ID =:relatedUserIDSet];

    	for(User eachUser : appOwnerList){
    		allUserRelateByUserIdMap.put(eachUser.Id,eachUser);
    	}

    	for(Opportunity eachOpp : relatedOppList){
    		if(allUserRelateByUserIdMap.containsKey(eachOpp.OwnerId)){
    			oppOwnerMap.put(eachOpp.Id,allUserRelateByUserIdMap.get(eachOpp.OwnerId));
    		}
    	}

        for(Application_History__c eachApplicationHistory : (List<Application_History__c>)Trigger.new){
            User oppOwner = oppOwnerMap.get(eachApplicationHistory.OppName__c);
            Application_History__c oldApp = (Application_History__c) Trigger.oldMap.get(eachApplicationHistory.Id);
                
            if(oldApp.App_Result__c != eachApplicationHistory.App_Result__c){
                if(eachApplicationHistory.App_Result__c == GlobalConstants.CLOSED_WON) {
                    if(!targetNewbookingMapByAppId.containsKey(eachApplicationHistory.Id)) {
                        
                        if(!completeOppIdsMapBySegment.containsKey(oppOwner.Segment__c)){
                            completeOppIdsMapBySegment.put(oppOwner.Segment__c, new Set<String>());
                        }else{
                            completeOppIdsMapBySegment.get(oppOwner.Segment__c).add(eachApplicationHistory.Id);
                        }
                    }
                } else if(oldApp.App_Result__c == GlobalConstants.CLOSED_WON) { // Back Stage
                    if(targetNewbookingMapByAppId.containsKey(eachApplicationHistory.Id)) {
                        if(targetNewbookingMapByAppId.get(eachApplicationHistory.Id).Status__c == GlobalConstants.STATUS_NEW)
                        deleteTargetList.add(targetNewbookingMapByAppId.get(eachApplicationHistory.Id));
                    }
                }
            }
        }
        
        if(!completeOppIdsMapBySegment.isEmpty()) CampaignRewardCalculation.insertTargetList(completeOppIdsMapBySegment, RECORDTYPE_TARGETLIST_STANDARD);
        if(!deleteTargetList.isEmpty()) delete deleteTargetList;    
    }
}