global class CampaignChangeStatus_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	global Set<Id> setCampaignIds;
	String query;
	
	global CampaignChangeStatus_Batch() {
		//this.query = 'SELECT Expiry_Date__c,Lead_Campaign__r.EndDate,Active_Target_List__c,Lead_Status__c, CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.Id, Lead_Campaign__r.Status, Lead_Campaign__r.Type__c, Status__c, Sharing_Status__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,(SELECT Id FROM Call_Reports_Leads__r WHERE Call_Plan_Call_Report__r.Status__c = \''+GlobalConstants.PLAN+'\'),(SELECT Id FROM Opportunities_Leads__r WHERE Opportunity__r.StageName != \''+GlobalConstants.DELETED_OPPORTUNITY+'\') FROM Target_List__c WHERE (Lead_Campaign__r.EndDate < TODAY OR (Expiry_Date__c < TODAY AND Status__c = \''+GlobalConstants.STATUS_NEW+'\')) AND Lead_Campaign__r.Status = \''+GlobalConstants.ACTIVE+'\' ORDER BY CIS_ID_Prospect_Name__c';	
		this.query = 'SELECT Expiry_Date__c,Lead_Campaign__r.EndDate,Active_Target_List__c,Lead_Status__c, CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.Id, Lead_Campaign__r.Status, Lead_Campaign__r.Type__c, Status__c, Sharing_Status__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c FROM Target_List__c WHERE (Lead_Campaign__r.EndDate < TODAY OR (Expiry_Date__c < TODAY AND Status__c = \''+GlobalConstants.STATUS_NEW+'\')) AND Lead_Campaign__r.Status = \''+GlobalConstants.ACTIVE+'\' ORDER BY CIS_ID_Prospect_Name__c';
	}

	global CampaignChangeStatus_Batch(Set<Id> setCampaignIds) {
		if(this.setCampaignIds == null) {
			this.setCampaignIds = new Set<Id>();
		}
		this.setCampaignIds.addAll(setCampaignIds);
		List<Id> campaignIds = new List<Id>(setCampaignIds);
		//this.query = 'SELECT Expiry_Date__c,Lead_Campaign__r.EndDate,Active_Target_List__c,Lead_Status__c, CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.Id, Lead_Campaign__r.Status, Lead_Campaign__r.Type__c, Status__c, Sharing_Status__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c,(SELECT Id FROM Call_Reports_Leads__r WHERE Call_Plan_Call_Report__r.Status__c = \''+GlobalConstants.PLAN+'\'),(SELECT Id FROM Opportunities_Leads__r WHERE Opportunity__r.StageName != \''+GlobalConstants.DELETED_OPPORTUNITY+'\') FROM Target_List__c WHERE Lead_Campaign__c IN (\'' + String.join(campaignIds,'\',\'') + '\') AND (Lead_Campaign__r.Status = \'' + GlobalConstants.CANCEL_PROCESS + '\' OR Lead_Campaign__r.Status = \'' + GlobalConstants.EXPIRE_PROCESS + '\') ORDER BY CIS_ID_Prospect_Name__c';
		this.query = 'SELECT Expiry_Date__c,Lead_Campaign__r.EndDate,Active_Target_List__c,Lead_Status__c, CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.Id, Lead_Campaign__r.Status, Lead_Campaign__r.Type__c, Status__c, Sharing_Status__c,CIS_ID_Prospect_Name__r.Lead_Sharing_Expired_Date__c FROM Target_List__c WHERE Lead_Campaign__c IN (\'' + String.join(campaignIds,'\',\'') + '\') AND (Lead_Campaign__r.Status = \'' + GlobalConstants.CANCEL_PROCESS + '\' OR Lead_Campaign__r.Status = \'' + GlobalConstants.EXPIRE_PROCESS + '\') ORDER BY CIS_ID_Prospect_Name__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Target_List__c> targetList) {
		List<Target_List__c> updateTargetList = new List<Target_List__c>();
		//List<Target_List__c> stopSharingTargetList = new List<Target_List__c>();
		//Set<Id> setStopSharingAccount = new Set<Id>();
		Map<Id, List<Target_List__c>> mapTargetsByAccount = new Map<Id, List<Target_List__c>>();
		Set<Id> setAccountId = new Set<Id>();
		for(Target_List__c eachTarget : targetList){
			setAccountId.add(eachTarget.CIS_ID_Prospect_Name__c);
		}

		//List<AggregateResult> listAllTargetListInAccount = [select CIS_ID_Prospect_Name__c,max(End_Date__c) MaxEndDate from target_list__c where CIS_ID_Prospect_Name__c IN :setAccountId AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES AND Sharing_Status__c = :GlobalConstants.SHARING_WITH_AN AND Lead_Sharing__c = :GlobalConstants.LEAD_SHARING AND Lead_Campaign__r.Status IN (:GlobalConstants.CANCEL_PROCESS,:GlobalConstants.EXPIRE_PROCESS,:GlobalConstants.ACTIVE) group by CIS_ID_Prospect_Name__c];
		//Map<String,AggregateResult> mapMaxEndDateMapByAccountId = new Map<String,AggregateResult>();
		//for(AggregateResult eachTargetListInAccount : listAllTargetListInAccount){
		//	mapMaxEndDateMapByAccountId.put(String.valueof(eachTargetListInAccount.get('CIS_ID_Prospect_Name__c')), eachTargetListInAccount);
		//}

		//Map<String,List<Call_Report__c>> mapListOpenCallReportMapByAccountId = new Map<String,List<Call_Report__c>>();
		//List<Call_Report__c> listCallReport = [SELECT Id,CIS_ID__c FROM Call_Report__c WHERE CIS_ID__c IN :setAccountId AND Status__c = :GlobalConstants.PLAN ];
		//for(Call_Report__c eachCallReport : listCallReport){
		//	if(!mapListOpenCallReportMapByAccountId.containsKey(eachCallReport.CIS_ID__c)){
		//		mapListOpenCallReportMapByAccountId.put(eachCallReport.CIS_ID__c, new List<Call_Report__c>());
		//	}
		//	mapListOpenCallReportMapByAccountId.get(eachCallReport.CIS_ID__c).add(eachCallReport);
		//}

		//Map<String,List<Opportunity>> mapListOpenOpportunityMapByAccountId = new Map<String,List<Opportunity>>();
		//List<Opportunity> listOpportunity = [SELECT Id,AccountId FROM Opportunity WHERE AccountId IN :setAccountId AND StageName NOT IN :ManageSharing_Service.setClosedOpportunityStatus];
		//for(Opportunity eachOpportunity : listOpportunity){
		//	if(!mapListOpenOpportunityMapByAccountId.containsKey(eachOpportunity.AccountId)){
		//		mapListOpenOpportunityMapByAccountId.put(eachOpportunity.AccountId, new List<Opportunity>());
		//	}
		//	mapListOpenOpportunityMapByAccountId.get(eachOpportunity.AccountId).add(eachOpportunity);
		//}

		for(Target_List__c eachTarget : targetList){
			if(eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.CAMPAIGN || eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_SALES || eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_TO_DO || eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_TO_INFORM || eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER || eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_FEEDBACK){
				if(eachTarget.Lead_Campaign__r.Status == GlobalConstants.EXPIRE_PROCESS || eachTarget.Lead_Campaign__r.Status == GlobalConstants.CANCEL_PROCESS || eachTarget.Lead_Campaign__r.EndDate < System.today() || eachTarget.Expiry_Date__c < System.today()){
					if(eachTarget.Status__c == GlobalConstants.STATUS_NEW){
						if(eachTarget.Lead_Campaign__r.Type__c == GlobalConstants.CAMPAIGN){
							eachTarget.Status__c = GlobalConstants.LEAD_EXPIRED;
						}else{
							if(eachTarget.Lead_Campaign__r.Status == GlobalConstants.EXPIRE_PROCESS || eachTarget.Lead_Campaign__r.EndDate < System.today()){
								eachTarget.Status__c = GlobalConstants.LEAD_EXPIRED;
							}else if(eachTarget.Expiry_Date__c < System.today()){
								eachTarget.Status__c = GlobalConstants.TG_EXPIRED;
							}else{
								eachTarget.Status__c = GlobalConstants.CANCEL_LEAD;
							}
						}
						eachTarget.Active_Target_List__c = null;
					}else if(eachTarget.Status__c == GlobalConstants.REJECTED || eachTarget.Status__c == GlobalConstants.AUTO_CLOSED || eachTarget.Status__c == GlobalConstants.DELETED_OPPORTUNITY){
						eachTarget.Active_Target_List__c = null;
					}

					//if(eachTarget.Sharing_Status__c == GlobalConstants.SHARING_WITH_AN){
					//	if(mapMaxEndDateMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c) != null && mapMaxEndDateMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).get('MaxEndDate') != null && Date.valueOf(mapMaxEndDateMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).get('MaxEndDate')) < System.today()){
					//		if((!mapListOpenOpportunityMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c) && !mapListOpenCallReportMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c))
					//		|| (mapListOpenOpportunityMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c) && mapListOpenOpportunityMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).size() == 0 && mapListOpenCallReportMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c) && mapListOpenCallReportMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).size() == 0) ){
					//			setStopSharingAccount.add(eachTarget.CIS_ID_Prospect_Name__r.Id);
					//		}else if(eachTarget.Status__c == GlobalConstants.STATUS_NEW){
					//			stopSharingTargetList.add(eachTarget);
					//		}
					//	}
					//}
				}
			}
			updateTargetList.add(eachTarget);
		}
        if (!updateTargetList.isEmpty()) {
            update updateTargetList;
        }

        //if(!stopSharingTargetList.isEmpty()){
        //	ManageSharing_Service.calculateTargetListExpiredThenDeleteSharing(stopSharingTargetList); 
        //}

        //if(!setStopSharingAccount.isEmpty()){
        //	ManageSharing_Service.calculateTargetListExpiredThenDeleteSharing(setStopSharingAccount); 	
        //}
	}
	
	global void finish(Database.BatchableContext BC) {
		List<Campaign> updateCampaigns = new List<Campaign>();
		List<Campaign> newCampaigns = new List<Campaign>();
		if(setCampaignIds != null){
			newCampaigns = [SELECT Id, Status,EndDate,IsActive FROM Campaign WHERE Id IN :setCampaignIds];
		}else{
			newCampaigns = [SELECT Id, Status,EndDate,IsActive FROM Campaign WHERE EndDate < :System.today() AND Status = :GlobalConstants.ACTIVE];
		}
		for (Campaign eachCamp : newCampaigns) {
			if(eachCamp.EndDate < System.today() || eachCamp.Status == GlobalConstants.CANCEL_PROCESS || eachCamp.Status == GlobalConstants.EXPIRE_PROCESS){
				eachCamp.Status = (eachCamp.Status==GlobalConstants.EXPIRE_PROCESS || eachCamp.Status==GlobalConstants.ACTIVE)?GlobalConstants.EXPIRED:GlobalConstants.CANCEL;
				eachCamp.IsActive = false;
			}
			updateCampaigns.add(eachCamp);
		}
		if (!updateCampaigns.isEmpty()) update updateCampaigns;
	}
	
}