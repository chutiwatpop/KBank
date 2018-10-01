public class OpportunityProductTriggerHandler extends TriggerHandler {
	public static final Set<String> closeStatusSet = new Set<String>{GlobalConstants.CLOSED_WON,GlobalConstants.CLOSE_LOST};
	private Map<Id,List<OpportunityLineItem>> possibleOpportunityLineItemMap = null;
	private static Map<Id,OpportunityLineItem> oldMapData = null;
	public OpportunityProductTriggerHandler() {
		
	}

	public override void allBefore(){
		oldMapData = (Map<Id,OpportunityLineItem>)Trigger.oldMap;
	}

	public override void allAfter(){
		Set<Id> appIdSet = new Set<Id>();
		Set<Id> appIdUpdate = new Set<Id>();
		Map<Id,Application_History__c> updateAppHisMap = new Map<Id,Application_History__c>();//ID of apphistory
		Map<Id,OpportunityLineItem> relateOppLineItemMap = new Map<Id,OpportunityLineItem>();
		Map<String,Integer> productJobResultPriority = new Map<String,Integer>();
		Set<Id> oppRelatedSet = new Set<Id>();
		Map<Id,Opportunity> oppRelatedByIdMap = new Map<Id,Opportunity>();
		Map<Id,Opportunity> updateRelatedByIdMap = new Map<Id,Opportunity>();
		possibleOpportunityLineItemMap = new Map<Id,List<OpportunityLineItem>>();
		productJobResultPriority.put('สนใจ และขายได้',1);
		productJobResultPriority.put('สนใจ แต่ติดเงื่อนไข',2);
		productJobResultPriority.put('ไม่สนใจ',3);
		for (OpportunityLineItem eachOpportunityLineItem : ((List<OpportunityLineItem>) Trigger.new)) {
			if(eachOpportunityLineItem.Application__c !=NULL){
				appIdSet.add(eachOpportunityLineItem.Application__c);
				appIdUpdate.add(eachOpportunityLineItem.Application__c);
			}
			if(possibleOpportunityLineItemMap.containsKey(eachOpportunityLineItem.OpportunityId)){
                possibleOpportunityLineItemMap.get(eachOpportunityLineItem.OpportunityId).add(eachOpportunityLineItem);
            }else{
                List<OpportunityLineItem> newOpportunityLineItemList = new List<OpportunityLineItem>();
                newOpportunityLineItemList.add(eachOpportunityLineItem);
                possibleOpportunityLineItemMap.put(eachOpportunityLineItem.OpportunityId , newOpportunityLineItemList);
            }
			relateOppLineItemMap.put(eachOpportunityLineItem.Id, eachOpportunityLineItem);
			oppRelatedSet.add(eachOpportunityLineItem.OpportunityId);	
		}
		if(!oppRelatedSet.isEmpty()){
			List<Opportunity> oppList =[SELECT Id,Job_Result__c FROM Opportunity WHERE Id=:oppRelatedSet];
			for(Opportunity eachOpp :oppList){
				oppRelatedByIdMap.put(eachOpp.Id, eachOpp);
			}
		}

		for (OpportunityLineItem eachOpportunityLineItem : ((List<OpportunityLineItem>) Trigger.new)) {
			OpportunityLineItem oldRecord = (Trigger.oldMap != null) ? (OpportunityLineItem)Trigger.oldMap.get(eachOpportunityLineItem.Id) : null;
			if(oppRelatedByIdMap.containsKey(eachOpportunityLineItem.OpportunityId) && (oldRecord == null || eachOpportunityLineItem.Product_Results__c != oldRecord.Product_Results__c)){
				if(!String.isEmpty(eachOpportunityLineItem.Product_Results__c) && eachOpportunityLineItem.Product_Results__c.length() > 3){
					String tempResult = eachOpportunityLineItem.Product_Results__c.substring(3);
					Opportunity oppRelated = oppRelatedByIdMap.get(eachOpportunityLineItem.OpportunityId);
					if(productJobResultPriority.containsKey(tempResult)){
						if(oppRelated.Job_Result__c !=NULL && oppRelated.Job_Result__c !='' && productJobResultPriority.containsKey(oppRelated.Job_Result__c)){
							if(productJobResultPriority.get(tempResult) < productJobResultPriority.get(oppRelated.Job_Result__c)){
								if(updateRelatedByIdMap.containsKey(eachOpportunityLineItem.OpportunityId)){
									updateRelatedByIdMap.get(eachOpportunityLineItem.OpportunityId).Job_Result__c = tempResult;
								}else{
									oppRelated.Job_Result__c = tempResult;
									updateRelatedByIdMap.put(oppRelated.Id, oppRelated);
								}
							}
						}else{
							if(updateRelatedByIdMap.containsKey(eachOpportunityLineItem.OpportunityId)){
								updateRelatedByIdMap.get(eachOpportunityLineItem.OpportunityId).Job_Result__c = tempResult;
							}else{
								oppRelated.Job_Result__c = tempResult;
								updateRelatedByIdMap.put(oppRelated.Id, oppRelated);
							}
						}
					}
				}
			}
		}

		if(!updateRelatedByIdMap.isEmpty()){
			TriggerHandler.bypass('OpportunityTriggerHandler');
            	update updateRelatedByIdMap.values();
        	TriggerHandler.clearBypass('OpportunityTriggerHandler');
		}


		if(trigger.IsUpdate){
			for (OpportunityLineItem eachOpportunityLineItemID : ((List<OpportunityLineItem>) Trigger.old)) {
				if(eachOpportunityLineItemID.Application__c != NULL){
					appIdSet.add(eachOpportunityLineItemID.Application__c);					
				}
			}
		}
		if(appIdSet.size() > 0){
			List<OpportunityLineItem> queryOppProductList = [SELECT Id, Name, Application__c, Report_Latest_Actual_Visit_Date__c, Volume_Limit__c FROM OpportunityLineItem WHERE Application__c IN :appIdSet];	
			for(OpportunityLineItem eachOpportunityLineItem : queryOppProductList){
				if(!relateOppLineItemMap.containsKey(eachOpportunityLineItem.Id)){
					relateOppLineItemMap.put(eachOpportunityLineItem.Id, eachOpportunityLineItem);	
				}			
			}

			List<Application_History__c> queryappHistoryList = [SELECT Id, Name, Report_Actual_Visit_Date__c, VolumeLimit__c FROM Application_History__c WHERE Id IN :appIdSet];
			for(Application_History__c appHis : queryappHistoryList){
				updateAppHisMap.put(appHis.Id, appHis);
			}

			Boolean isFlagUpdate = true;
			Map<Id,Double> sumVolume = new Map<Id,Double>();
			for(OpportunityLineItem eachOpportunityProduct : relateOppLineItemMap.values()){
				if(updateAppHisMap.containsKey(eachOpportunityProduct.Application__c)){
					Application_History__c appData = updateAppHisMap.get(eachOpportunityProduct.Application__c);
		            Double volumeApp = sumVolume.get(appData.Id) == null ? 0 : sumVolume.get(appData.Id);
		            Double volumeOppProduct = eachOpportunityProduct.Volume_Limit__c == null ? 0 : eachOpportunityProduct.Volume_Limit__c;
		            appData.VolumeLimit__c = volumeApp + volumeOppProduct;
					if(appData.Report_Actual_Visit_Date__c == null){
						appData.Report_Actual_Visit_Date__c = eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c;
						appData.ManualSP__c = True;
						updateAppHisMap.put(appData.Id, appData);
		                sumVolume.put(appData.Id, appData.VolumeLimit__c);
					}else if(appData.Report_Actual_Visit_Date__c != null){
						if(!appIdUpdate.contains(appData.Id)){
							if(isFlagUpdate){
								appData.Report_Actual_Visit_Date__c = eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c;
								appData.ManualSP__c = True;
								updateAppHisMap.put(appData.Id, appData);
	                            sumVolume.put(appData.Id, appData.VolumeLimit__c);
								isFlagUpdate = false;
							}else if(appData.Report_Actual_Visit_Date__c > eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c){
								appData.Report_Actual_Visit_Date__c = eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c;
								appData.ManualSP__c = True;
								updateAppHisMap.put(appData.Id, appData);
	                            sumVolume.put(appData.Id, appData.VolumeLimit__c);
							}
						}else if(appData.Report_Actual_Visit_Date__c > eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c){
							appData.Report_Actual_Visit_Date__c = eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c;
							appData.ManualSP__c = True;
							updateAppHisMap.put(appData.Id, appData);
	                        sumVolume.put(appData.Id, appData.VolumeLimit__c);
						}
					}
				}
			}
		}
		
 		TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
            update updateAppHisMap.values();
        TriggerHandler.clearBypass('ApplicationHistoryTriggerHandler');
	}

	private String convertAppResultToStatus(String appResult) {
		String resultStatus = '';
		if(appResult == GlobalConstants.WORK_IN_PROGRESS) {
			resultStatus = GlobalConstants.ON_PROCESS;
		} else {
			resultStatus = appResult;
		}
		return resultStatus;
	}

	public override void beforeInsert() {
		//stampTeamStructure();
		List<Id> oppIdList = new List<Id>();
		List<Id> createbyIdList = new List<Id>();
		Map<Id, Event> callReportMap = new Map<Id, Event>();
		Map<Id, Event> callReportForSaleMap = new Map<Id, Event>();
		Set<Id> appRelateSetId = new Set<Id>();

		for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
			oppIdList.add(eachOpportunityProduct.OpportunityId);
			if(eachOpportunityProduct.Application_CBS__c !=null){
				appRelateSetId.add(eachOpportunityProduct.Application_CBS__c);
			}
			if(eachOpportunityProduct.Application__c !=null){
				appRelateSetId.add(eachOpportunityProduct.Application__c);
			}
		}

		List<Event> eventCallReportList = [SELECT Id, StartDateTime, Subject, Visit_Objective__c, WhatId FROM Event WHERE WhatId IN :oppIdList AND Status__c = 'Contacted' ORDER BY WhatId, CreatedDate DESC];
		User_Extension__c currentUserExt = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
		
		Map<Id,Application_History__c> relatedAppHistoryMap = new Map<Id,Application_History__c>();
		if(!appRelateSetId.isEmpty()){
			List<Application_History__c> relatedAppHistoryList = [SELECT Id,App_Result__c FROM Application_History__c WHERE Id=:appRelateSetId];
			if(relatedAppHistoryList !=NULL && !relatedAppHistoryList.isEmpty()){
				for(Application_History__c eachApp :relatedAppHistoryList){
					relatedAppHistoryMap.put(eachApp.Id, eachApp);
				}
			}
		}

		// Create Map for list of call report and opp product
		for (Event eventCallReportItem : eventCallReportList) {
			if (!callReportMap.containsKey(eventCallReportItem.WhatId)) {
				callReportMap.put(eventCallReportItem.WhatId, eventCallReportItem);
			}
			if (!callReportForSaleMap.containsKey(eventCallReportItem.WhatId) && eventCallReportItem.Visit_Objective__c == GlobalConstants.CALL_REPORT_FOR_SALE) {
				callReportForSaleMap.put(eventCallReportItem.WhatId, eventCallReportItem);
			}
		}

		// Loop all opportunity product again and set callreport to each value
		for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
			Event callReportForSale = callReportForSaleMap.get(eachOpportunityProduct.OpportunityId);
			Event callReport = callReportMap.get(eachOpportunityProduct.OpportunityId);
			eachOpportunityProduct.Report_Latest_Actual_Visit_Date_Sales__c = callReportForSale == null ? null : callReportForSale.StartDateTime.date();
			eachOpportunityProduct.Report_Latest_Call_Report_ID_Sales__c = callReportForSale == null ? null : callReportForSale.Id;
			eachOpportunityProduct.Report_Latest_Call_Report_Name_Sales__c = callReportForSale == null ? null : callReportForSale.Subject;
			eachOpportunityProduct.Report_Latest_Actual_Visit_Date__c = callReport == null ? null : callReport.StartDateTime.date();
			eachOpportunityProduct.Report_Latest_Call_Report_ID__c = callReport == null ? null :  callReport.Id;
			eachOpportunityProduct.Report_Latest_Call_Report_Name__c = callReport == null ? null :  callReport.Subject;
			
			if(currentUserExt != null) {
				eachOpportunityProduct.Created_By_User_Extension__c = currentUserExt.Id;
				eachOpportunityProduct.OwnerExtension__c = currentUserExt.Id;
				eachOpportunityProduct.TeamName__c 		 = currentUserExt.Team_Structure__c;
				eachOpportunityProduct.AHName__c 		 = currentUserExt.Team_Structure__r.AH_Name__c;
				eachOpportunityProduct.NHName__c 		 = currentUserExt.Team_Structure__r.NH_Name__c;
			}

			if(relatedAppHistoryMap!=NULL && eachOpportunityProduct.Application__c !=NULL  && relatedAppHistoryMap.containsKey(eachOpportunityProduct.Application__c)){
				eachOpportunityProduct.Status_CBS__c = convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application__c).App_Result__c);
			}
			if(relatedAppHistoryMap!=NULL && eachOpportunityProduct.Application_CBS__c !=NULL  && relatedAppHistoryMap.containsKey(eachOpportunityProduct.Application_CBS__c)){
				eachOpportunityProduct.Status_CBS__c = convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application_CBS__c).App_Result__c);
			}
			if(closeStatusSet.contains(eachOpportunityProduct.Status_CBS__c) &&  eachOpportunityProduct.Close_Date__c == NULL){
				eachOpportunityProduct.Close_Date__c = System.today();
			}
		}
	}

	public override void beforeUpdate(){
		User currentUser = UserService.getCurrentUserInfo();
		if(!Account_Service.byPassValidateOpportunityProduct && !GlobalConstants.PROFILE_KBANK_ADMIN_SET.contains(currentUser.Profile.Name) && currentUser.Profile.Name != GlobalConstants.KBANK_BIU ){
			Set<Id> userIdRelatedSet = new Set<Id>();
			Map<Id,User_Extension__c> userExtRelatedMap;	
			for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
			 	userIdRelatedSet.add(eachOpportunityProduct.OwnerExtension__c);
			}
			if(!userIdRelatedSet.isEmpty()){
				userExtRelatedMap = new Map<Id,User_Extension__c>([SELECT Id,User__r.Segment__c FROM User_Extension__c WHERE ID=:userIdRelatedSet]);
			}
			for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
				if(userExtRelatedMap.containsKey(eachOpportunityProduct.OwnerExtension__c) 
					&& userExtRelatedMap.get(eachOpportunityProduct.OwnerExtension__c).User__r.Segment__c != NULL 
					&& userExtRelatedMap.get(eachOpportunityProduct.OwnerExtension__c).User__r.Segment__c != currentUser.Segment__c){
					eachOpportunityProduct.addError(ExceptionMessage.OTHERSEGMENT_CANNOT_EDITPRODUCT);
				}
			}	
		}

		if(GlobalConstants.PROFILE_SME_SALE_SET.contains(currentUser.Profile.Name) || GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)){
			Map<Id,OpportunityLineItem> oppLineOldMap = (Map<Id,OpportunityLineItem>)Trigger.oldMap;
			Set<Id> appRelateSetId = new Set<Id>();
			for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
				if(eachOpportunityProduct.Application_CBS__c !=null){
					appRelateSetId.add(eachOpportunityProduct.Application_CBS__c);
				}
				if(eachOpportunityProduct.Application__c !=null){
					appRelateSetId.add(eachOpportunityProduct.Application__c);
				}
			}

			Map<Id,Application_History__c> relatedAppHistoryMap = new Map<Id,Application_History__c>();
			if(!appRelateSetId.isEmpty()){
				List<Application_History__c> relatedAppHistoryList = [SELECT Id,App_Result__c FROM Application_History__c WHERE Id=:appRelateSetId];
				if(relatedAppHistoryList !=NULL && !relatedAppHistoryList.isEmpty()){
					for(Application_History__c eachApp :relatedAppHistoryList){
						relatedAppHistoryMap.put(eachApp.Id, eachApp);
					}
				}
			}

			for (OpportunityLineItem eachOpportunityProduct : ((List<OpportunityLineItem>) Trigger.new)) {
				if(!ApplicationHistory_Service.byPassValidateOpportunityProduct){
					if(GlobalConstants.PROFILE_CBS_SALE_SET.contains(currentUser.Profile.Name)) {
						/*if(closeStatusSet.contains(eachOpportunityProduct.Status_CBS__c) && oppLineOldMap.get(eachOpportunityProduct.Id).Status_CBS__c == eachOpportunityProduct.Status_CBS__c){
							eachOpportunityProduct.addError(Label.CBS_Cannot_Edit_CloseApp);
						} else*/
						if(closeStatusSet.contains(oppLineOldMap.get(eachOpportunityProduct.Id).Status_CBS__c)) {
							eachOpportunityProduct.addError(Label.CBS_Cannot_Edit_CloseApp);
						} else if(oppLineOldMap.get(eachOpportunityProduct.Id).Status_CBS__c == GlobalConstants.CANCELLED) {
							//waiting for migrate
							//if(oppLineOldMap.get(eachOpportunityProduct.Id).Application__c == null && oppLineOldMap.get(eachOpportunityProduct.Id).Application__c != eachOpportunityProduct.Application__c)
							if(oppLineOldMap.get(eachOpportunityProduct.Id).Application_CBS__c == null && oppLineOldMap.get(eachOpportunityProduct.Id).Application_CBS__c != eachOpportunityProduct.Application_CBS__c) {
								eachOpportunityProduct.addError(Label.CBS_Cannot_Edit_CloseApp);
							}
						}
					}

					if(relatedAppHistoryMap!=NULL && eachOpportunityProduct.Application__c !=NULL && relatedAppHistoryMap.containsKey(eachOpportunityProduct.Application__c)){
						if(oppLineOldMap.get(eachOpportunityProduct.Id).Application__c != eachOpportunityProduct.Application__c) {
							eachOpportunityProduct.Status_CBS__c = convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application__c).App_Result__c);
						} else if(convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application__c).App_Result__c) != eachOpportunityProduct.Status_CBS__c) {
							eachOpportunityProduct.addError(Label.Not_Allow_to_update_product);
						}
					}
					
					if(relatedAppHistoryMap!=NULL && eachOpportunityProduct.Application_CBS__c !=NULL && relatedAppHistoryMap.containsKey(eachOpportunityProduct.Application_CBS__c)){
						if(oppLineOldMap.get(eachOpportunityProduct.Id).Application_CBS__c != eachOpportunityProduct.Application_CBS__c) {
							eachOpportunityProduct.Status_CBS__c = convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application_CBS__c).App_Result__c);
						} else if(convertAppResultToStatus(relatedAppHistoryMap.get(eachOpportunityProduct.Application_CBS__c).App_Result__c) != eachOpportunityProduct.Status_CBS__c) {
							eachOpportunityProduct.addError(Label.Not_Allow_to_update_product);
						}
					}
				}
				
				if(closeStatusSet.contains(eachOpportunityProduct.Status_CBS__c) &&  eachOpportunityProduct.Close_Date__c == NULL){
					eachOpportunityProduct.Close_Date__c = System.today();
				}
			}
		}
	}

	public override void afterInsert(){
		// Update Junction
		System.debug('afterInsert');
		System.debug(possibleOpportunityLineItemMap);
		JunctionService junction_service = new JunctionService();
		junction_service.initialJunctionWithOpportunityId(possibleOpportunityLineItemMap.keySet());
	}

	public override void afterUpdate(){
		// Update Junction
		System.debug('afterUpdate');
		System.debug(possibleOpportunityLineItemMap);
		JunctionService junction_service = new JunctionService();
		junction_service.initialJunctionWithOpportunityId(possibleOpportunityLineItemMap.keySet());
	}
}