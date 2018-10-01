global without sharing class OpportunityPlanning_Service {
	//public static Map<String,Opportunity_Planning_Type__c> oppPlanningCSMapByOppPlanType; 
	//public static Set<String> oppPlanningFields;
	

	//public static Set<Id> createOpportunityFromCallReport(
	//				Account targetAccount, 
	//				Call_Report__c targetCallReport, 
	//				List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList,
	//				List<GroupOpportunityPlanningWrapper> groupOppPlanningList) 
	//{
	//	OpportunityPlanning_Service.setUpStaticVariable();
	//	Map<String, Id> oppRecordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Opportunity');
	//	Map<String, Call_Report_Opportunity__c> callReportOppInsertMap = new Map<String, Call_Report_Opportunity__c>();
	//	Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
	//	Map<String, List<Opportunity_Product_CBS__c>> oppProductMap = new Map<String, List<Opportunity_Product_CBS__c>>();
	//	Map<String, Opportunity_Planning__c> oppPlanningMap = new Map<String, Opportunity_Planning__c>();
	//	Map<String, List<Opportunity_Planning_Line_Item__c>> oppPlanningLineItemMap = new Map<String, List<Opportunity_Planning_Line_Item__c>>();
	//	Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByExistingOppId = new Map<Id, List<Opportunity_Planning__c>>();
	//	Map<Id, List<CBS_OpportunityPlanningWrapper>> oppPlanningWrapperMapByExistingOppId = new Map<Id, List<CBS_OpportunityPlanningWrapper>>();
	//	Map<String, List<Opportunity_Planning__c>> listOppPlanningMapByOppTempKey = new Map<String, List<Opportunity_Planning__c>>();
	//	List<Opportunity_Product_CBS__c> newOppProductList = new List<Opportunity_Product_CBS__c>();
	//	List<Opportunity_Planning__c> listUpdateServicingOppPlan = new List<Opportunity_Planning__c>();
	//	Set<String> updatedStatusOppPlanningKeys = new Set<String>();
	//	Set<Id> opportunityIdResults = new Set<Id>();
	//	User currentUser = [SELECT Segment__c FROM User Where Id = :UserInfo.getUserId()];
	//	List<Business_Code__c> listBusinessCodeMaster = [SELECT ID,Name FROM Business_Code__c WHERE Segment__c = :currentUser.Segment__c AND Name = :targetAccount.Customer_s_Business_Code__c];
	//	Business_Code__c businessCodeMaster; 
	//	if(listBusinessCodeMaster.size() > 0){
	//		businessCodeMaster = listBusinessCodeMaster[0];
	//	}

	//	Integer tempIndex = 0;
	//	Integer tempPlanningIndex = 0;
	//	for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningWrapperList) {
	//		if(!eachOppPlanningWrapper.isGrouped){
	//			Opportunity_Planning__c eachOppPlanning = eachOppPlanningWrapper.opportunityPlanning;
				
	//			tempPlanningIndex++;
	//			String tempPlanningKey = tempPlanningIndex + '';
	//			oppPlanningMap.put(tempPlanningKey, eachOppPlanning);
	//			if(eachOppPlanning.Status__c != eachOppPlanningWrapper.oldStatus || eachOppPlanning.Id == null) {
	//				updatedStatusOppPlanningKeys.add(tempPlanningKey);
	//			}
	//			if(!String.isBlank(eachOppPlanning.Add_to_Existing_Opportunity__c)) {
	//				if(!oppPlanningMapByExistingOppId.containsKey(eachOppPlanning.Add_to_Existing_Opportunity__c)){
	//					oppPlanningMapByExistingOppId.put(eachOppPlanning.Add_to_Existing_Opportunity__c, new List<Opportunity_Planning__c>());
	//					oppPlanningWrapperMapByExistingOppId.put(eachOppPlanning.Add_to_Existing_Opportunity__c, new List<CBS_OpportunityPlanningWrapper>());
	//				}
	//				oppPlanningMapByExistingOppId.get(eachOppPlanning.Add_to_Existing_Opportunity__c).add(eachOppPlanning);
	//				opportunityIdResults.add(eachOppPlanning.Add_to_Existing_Opportunity__c);
	//				oppPlanningWrapperMapByExistingOppId.get(eachOppPlanning.Add_to_Existing_Opportunity__c).add(eachOppPlanningWrapper);
	//			}

	//			String tempKey = eachOppPlanning.Product_Type__c;
	//			if(!String.isBlank(eachOppPlanning.Add_to_Existing_Opportunity__c)) {
	//				if(!callReportOppInsertMap.containsKey(targetCallReport.Id + '-' + eachOppPlanning.Add_to_Existing_Opportunity__c)) {
	//					callReportOppInsertMap.put(targetCallReport.Id + '-' + eachOppPlanning.Add_to_Existing_Opportunity__c, new Call_Report_Opportunity__c(
	//	                    Call_Plan_Call_Report__c = targetCallReport.Id,
	//	                    Opportunity_Name__c = eachOppPlanning.Add_to_Existing_Opportunity__c
	//	                ));
	//				}
	//			} else if(eachOppPlanning.Status__c != eachOppPlanningWrapper.oldStatus && eachOppPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE) { 
	//				Opportunity tempOpp = newOpportunity(targetAccount.Name, eachOppPlanning.CIS_ID__c, eachOppPlanning);
	//				calculteOpportunityAmount(tempOpp,eachOppPlanningWrapper.opportunityPlanning);
	//				if(businessCodeMaster != null){
	//					tempOpp.Business_Code__c = businessCodeMaster.Id;
	//				}

	//				if(checkIsProductTypeCreditsetOpportunitySubmitIssue(tempOpp,eachOppPlanning) ){
	//					tempOpp.RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME);
	//					tempKey = tempKey + '' + tempPlanningIndex;
	//				}else{
	//					tempOpp.RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.NON_CREDIT_OPPORTUNITY_DEVNAME);
	//	                tempKey = tempKey + '' + tempIndex;
	//	                tempIndex++;
	//				}
	//				opportunityMap.put(tempKey, tempOpp);
	//				if(!listOppPlanningMapByOppTempKey.containsKey(tempKey)){
	//					listOppPlanningMapByOppTempKey.put(tempKey,new List<Opportunity_Planning__c>());
	//				}
	
	//				listOppPlanningMapByOppTempKey.get(tempKey).add(eachOppPlanning);
	//			}

	//			for(Opportunity_Planning_Line_Item__c eachLineItem : eachOppPlanningWrapper.oppPlanningLineItems) {
	//				if(!oppPlanningLineItemMap.containsKey(tempPlanningKey)) {
	//					oppPlanningLineItemMap.put(tempPlanningKey, new List<Opportunity_Planning_Line_Item__c>());
	//				}
	//				oppPlanningLineItemMap.get(tempPlanningKey).add(eachLineItem);

	//				if(String.isBlank(eachOppPlanning.Add_to_Existing_Opportunity__c)) {
	//					if(eachOppPlanning.Status__c != eachOppPlanningWrapper.oldStatus && eachOppPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE) {
	//						Opportunity_Product_CBS__c tempOppProduct = newOpportunityProduct(eachOppPlanning, eachLineItem);
	//						if(!oppProductMap.containsKey(tempKey)) {
	//							oppProductMap.put(tempKey, new List<Opportunity_Product_CBS__c>());
	//						}
	//						oppProductMap.get(tempKey).add(tempOppProduct);
	//					}
	//				}
	//			}
	//		}
	//	}

	//	Integer tempPlanningAndPlanLineTempIndex = 0;
	//	for(GroupOpportunityPlanningWrapper eachGroupOpportunityPlanningWrapper : groupOppPlanningList){
	//		String tempKey = eachGroupOpportunityPlanningWrapper.sum_productName;
	//		Set<String> productList = new Set<String>();
	//		Boolean hasCredit = false;
	//		Boolean hasServicing = false;
	//		tempPlanningAndPlanLineTempIndex++;
	//		String tempPlanningKey = 'Group'+tempPlanningAndPlanLineTempIndex;
	//		tempPlanningIndex++;
	//		tempKey = tempKey + '' + tempPlanningIndex;
	//		Opportunity tempOpp = null;
	//		if(String.isBlank(eachGroupOpportunityPlanningWrapper.addToExistingOpp.Id)){
	//			tempOpp = new Opportunity(
	//	            Name = targetAccount.Name, 
	//	            AccountId = targetAccount.Id,
	//	            CloseDate = System.today(),
	//	            Amount = 0,
	//	            Opportunity_Planning_Remark__c = eachGroupOpportunityPlanningWrapper.remark,
	//	            Product_List_CBS__c = String.join(new List<String>(productList), ','),
	//	            StageName = GlobalConstants.STOCK_NEGOTIATION,
	//	            RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME)
	//	        );
	//	        if(businessCodeMaster != null){
	//				tempOpp.Business_Code__c = businessCodeMaster.Id;
	//			}

	//			if(hasCredit){
	//				tempOpp.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
 //               }else{
 //               	if(hasServicing){
	//                	tempOpp.Submit_Issue__c = GlobalConstants.SERVICING;
	//                }else{
	//                	tempOpp.Submit_Issue__c = GlobalConstants.RENEW_SERVICING;
	//                }
 //               }
	//		}

	//		Integer oppPlanIndex =0;
	//		for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : eachGroupOpportunityPlanningWrapper.oppPlanningWrapperList){
	//			oppPlanIndex++;
	//			tempPlanningKey = tempPlanningKey + oppPlanIndex;
	//			oppPlanningMap.put(tempPlanningKey, eachOppPlanningWrapper.opportunityPlanning);

	//			if(eachOppPlanningWrapper.opportunityPlanning.Status__c != eachOppPlanningWrapper.oldStatus || eachOppPlanningWrapper.opportunityPlanning.Id == null) {
	//				updatedStatusOppPlanningKeys.add(tempPlanningKey);
	//			}
			
	//			if(String.isBlank(eachGroupOpportunityPlanningWrapper.addToExistingOpp.Id) && tempOpp != null){
	//				calculteOpportunityAmount(tempOpp,eachOppPlanningWrapper.opportunityPlanning);

	//				for(Opportunity_Planning_Line_Item__c eachLineItem : eachOppPlanningWrapper.oppPlanningLineItems) {
	//					if(!oppPlanningLineItemMap.containsKey(tempPlanningKey)) {
	//						oppPlanningLineItemMap.put(tempPlanningKey, new List<Opportunity_Planning_Line_Item__c>());
	//					}
	//					oppPlanningLineItemMap.get(tempPlanningKey).add(eachLineItem);

	//					if(String.isBlank(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__r.Id)) {
	//						if(eachOppPlanningWrapper.opportunityPlanning.Status__c != eachOppPlanningWrapper.oldStatus && eachOppPlanningWrapper.opportunityPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE) {
	//							Opportunity_Product_CBS__c tempOppProduct = newOpportunityProduct(eachOppPlanningWrapper.opportunityPlanning, eachLineItem);
	//							if(!oppProductMap.containsKey(tempKey)) {
	//								oppProductMap.put(tempKey, new List<Opportunity_Product_CBS__c>());
	//							}
	//							oppProductMap.get(tempKey).add(tempOppProduct);
	//						}
	//					}
	//				}

	//				if(!listOppPlanningMapByOppTempKey.containsKey(tempKey)){
	//					listOppPlanningMapByOppTempKey.put(tempKey,new List<Opportunity_Planning__c>());
	//				}
	//				listOppPlanningMapByOppTempKey.get(tempKey).add(eachOppPlanningWrapper.opportunityPlanning);
	//			}else{
	//				for(Opportunity_Planning_Line_Item__c eachLineItem : eachOppPlanningWrapper.oppPlanningLineItems) {
	//					if(!oppPlanningLineItemMap.containsKey(tempPlanningKey)) {
	//						oppPlanningLineItemMap.put(tempPlanningKey, new List<Opportunity_Planning_Line_Item__c>());
	//					}
	//					oppPlanningLineItemMap.get(tempPlanningKey).add(eachLineItem);
	//				}
	//			}

	//			productList.add(eachOppPlanningWrapper.opportunityPlanning.Product_List_CBS__c);

	//			if(isProductTypeCredit(eachOppPlanningWrapper.opportunityPlanning)){
	//				hasCredit = true;
	//			}else if(isProductTypeServicing(eachOppPlanningWrapper.opportunityPlanning)){
	//				hasServicing= true;
	//			}

	//			if(!String.isBlank(eachGroupOpportunityPlanningWrapper.addToExistingOpp.Id)){
	//				eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c = eachGroupOpportunityPlanningWrapper.addToExistingOpp.Id;
	//				if(!oppPlanningMapByExistingOppId.containsKey(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c)){
	//					oppPlanningMapByExistingOppId.put(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c, new List<Opportunity_Planning__c>());
	//					oppPlanningWrapperMapByExistingOppId.put(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c, new List<CBS_OpportunityPlanningWrapper>());
	//				}
	//				oppPlanningMapByExistingOppId.get(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c).add(eachOppPlanningWrapper.opportunityPlanning);
	//				oppPlanningWrapperMapByExistingOppId.get(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c).add(eachOppPlanningWrapper);
	//				opportunityIdResults.add(eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c);

	//				if(!callReportOppInsertMap.containsKey(targetCallReport.Id + '-' + eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c)) {
	//					callReportOppInsertMap.put(targetCallReport.Id + '-' + eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c, new Call_Report_Opportunity__c(
	//	                    Call_Plan_Call_Report__c = targetCallReport.Id,
	//	                    Opportunity_Name__c = eachOppPlanningWrapper.opportunityPlanning.Add_to_Existing_Opportunity__c
	//	                ));
	//				}
	//			}
	//		}

	//		if(String.isBlank(eachGroupOpportunityPlanningWrapper.addToExistingOpp.Id) &&  tempOpp != null){
	//			if(hasCredit){
	//				tempOpp.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
 //               }else{
 //               	if(hasServicing){
	//                	tempOpp.Submit_Issue__c = GlobalConstants.SERVICING;
	//                }else{
	//                	tempOpp.Submit_Issue__c = GlobalConstants.RENEW_SERVICING;
	//                }
 //               }
 //               tempOpp.Product_List_CBS__c = String.join(new List<String>(productList), ',');
 //               opportunityMap.put(tempKey, tempOpp);
	//		}
	//	}

	//	if(!oppPlanningMapByExistingOppId.isEmpty()) {
	//		List<Opportunity> existingOpportunities = new List<Opportunity>();
	//		List<Opportunity_Planning__c> listOppPlanningReleateOpp = new List<Opportunity_Planning__c>();
	//		List<Application_History__c> listUpdateRecordTypeAppHis = new List<Application_History__c>();
	//		Id recordtypeIdAppHisCredit = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Credit_Application_History');
	//		existingOpportunities = getExisitingOpportunity(oppPlanningMapByExistingOppId);
	//		for(Opportunity existingOpp : existingOpportunities) {
	//			Set<String> oppProductSet = new Set<String>();
	//			if(existingOpp.Product_List_CBS__c != null) {
	//				oppProductSet.addAll(existingOpp.Product_List_CBS__c.split(','));
	//			}

	//			if(existingOpp.Amount == null ){
	//				existingOpp.Amount = 0;
	//			}

	//			for(CBS_OpportunityPlanningWrapper eachWrapper : oppPlanningWrapperMapByExistingOppId.get(existingOpp.Id)){
	//				Opportunity_Planning__c eachOppPlanning = eachWrapper.opportunityPlanning;
	//				for(Opportunity_Planning_Line_Item__c eachLineItem : eachWrapper.oppPlanningLineItems) {
	//					newOppProductList.add(newOpportunityProductFromExistingOpp(eachOppPlanning, eachLineItem));
	//				}

	//				Set<String> oppPlanningProductSet = new Set<String>();
	//				eachOppPlanning.Opportunity__c = existingOpp.Id;
	//				listOppPlanningReleateOpp.add(eachOppPlanning);
	//				if(eachOppPlanning.Product_List_CBS__c != null) {
	//					oppPlanningProductSet.addAll(eachOppPlanning.Product_List_CBS__c.split(','));
	//				}

	//				if(existingOpp.Submit_Issue__c == GlobalConstants.RENEW_SERVICING && 
	//					(oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c != GlobalConstants.RENEW_SERVICING  )
	//				){
	//					existingOpp.Submit_Issue__c = oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c;
					
	//				}else if(existingOpp.Submit_Issue__c == GlobalConstants.SERVICING &&
	//					(oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c == GlobalConstants.NEW_CREDIT)
	//				){
	//					existingOpp.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
	//				}

	//				oppProductSet.addAll(oppPlanningProductSet);
	//				calculteOpportunityAmount(existingOpp,eachOppPlanning);
	//				existingOpp.Product_List_CBS__c = String.join(new List<String>(oppProductSet), ',');
	//			}
	//		}
	//		update existingOpportunities;

	//		if(!listOppPlanningReleateOpp.isEmpty()){
	//			TriggerHandler.bypass('OpportunityPlanningTriggerHandler');
	//			upsert listOppPlanningReleateOpp;
	//			TriggerHandler.clearbypass('OpportunityPlanningTriggerHandler');
	//		}

	//		if(!listUpdateRecordTypeAppHis.isEmpty()){
	//			TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
	//			update listUpdateRecordTypeAppHis;
	//			TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
	//		}
	//	}


	//	if(!oppPlanningMap.isEmpty()) {
	//		upsert oppPlanningMap.values();

	//		List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();
	//		List<Call_Report_Opportunity_Planning__c> callReportOppPlanList = new List<Call_Report_Opportunity_Planning__c>();
	//		Set<String> opLineItemDelSet = new Set<String>();
	//		for(String eachKey : oppPlanningMap.keySet()) {
	//			if(oppPlanningMap.containsKey(eachKey)) {
	//				Opportunity_Planning__c eachOppPlanning = oppPlanningMap.get(eachKey);

	//				if(updatedStatusOppPlanningKeys.contains(eachKey)) {
	//					callReportOppPlanList.add(newCallReportOpportunityPlanning(targetCallReport.Id, eachOppPlanning));
	//				}

	//				if(oppPlanningLineItemMap.containsKey(eachKey)) {
	//					for(Opportunity_Planning_Line_Item__c eachLineItem : oppPlanningLineItemMap.get(eachKey)) {
	//						if(eachLineItem.Id==null)
	//							opLineItemDelSet.add(eachOppPlanning.Id);
	//						eachLineItem.Opportunity_Planning__c = eachOppPlanning.Id;
	//						newLineItems.add(eachLineItem);
	//					}
	//				}
	//			}
	//		}
	//		delete [select id from Opportunity_Planning_Line_Item__c where Opportunity_Planning__c in :opLineItemDelSet and id not in :newLineItems];
	//		if(!newLineItems.isEmpty())
	//			upsert newLineItems;

	//		if(!callReportOppPlanList.isEmpty())
	//			insert callReportOppPlanList;
	//	}

	//	List<Opportunity_Planning__c> listUpdateOppPlanWithOppty = new List<Opportunity_Planning__c>();
	//	if(!opportunityMap.isEmpty()) {
	//		insert opportunityMap.values();

	//		for(String eachKey : opportunityMap.keySet()) {
	//			Id tempOppId = opportunityMap.get(eachKey).Id;
	//			opportunityIdResults.add(tempOppId);
	//			for(Opportunity_Product_CBS__c eachOppProduct : oppProductMap.get(eachKey)) {
	//				eachOppProduct.Opportunity_CBS__c = tempOppId;
	//				newOppProductList.add(eachOppProduct);
	//			}

	//			for(Opportunity_Planning__c eachOppPlanning : listOppPlanningMapByOppTempKey.get(eachKey)){
	//				eachOppPlanning.Opportunity__c = tempOppId;
	//				listUpdateOppPlanWithOppty.add(eachOppPlanning);
	//			}

	//			if(!callReportOppInsertMap.containsKey(targetCallReport.Id + '-' + tempOppId)) {
	//				callReportOppInsertMap.put(targetCallReport.Id + '-' + tempOppId, new Call_Report_Opportunity__c(
	//                    Call_Plan_Call_Report__c = targetCallReport.Id,
	//                    Opportunity_Name__c = tempOppId
	//                ));
	//			}
	//		}
	//	}
	
	//	if(!newOppProductList.isEmpty())
	//		insert newOppProductList;

	//	TriggerHandler.bypass('CallReportOpportunityTriggerHandler');
	//	if(!callReportOppInsertMap.isEmpty())
	//		insert callReportOppInsertMap.values();
	//	TriggerHandler.clearBypass('CallReportOpportunityTriggerHandler');

	//	TriggerHandler.bypass('OpportunityPlanningTriggerHandler');
	//	if(!listUpdateOppPlanWithOppty.isEmpty()){
	//		upsert listUpdateOppPlanWithOppty;
	//	}
	//	TriggerHandler.clearbypass('OpportunityPlanningTriggerHandler');

	//	TriggerHandler.bypass('OpportunityPlanningTriggerHandler');
	//	if(!listUpdateServicingOppPlan.isEmpty()){
	//		update listUpdateServicingOppPlan;
	//	}
	//	TriggerHandler.clearbypass('OpportunityPlanningTriggerHandler');

	//	return opportunityIdResults;
	//}

	//public static Set<Id> createOpportunityFromOpportunityTab(
	//						Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport, 
	//						Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning, 
	//						Map<Id, Account> accountNameMapByOppPlanning,
	//						Map<String,Opportunity_Custom_Controller.OppPlanningWrapper> mapAllGroupedOppPlanningMapByOppPlanId,
	//						Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService,
	//						Map<String,String> mapBusinessCodeByOppPlanId) 
	//{
	//	OpportunityPlanning_Service.setUpStaticVariable();
	//	User currentUser = [SELECT Segment__c FROM User Where Id = :UserInfo.getUserId()];
	//	List<Business_Code__c> listBusinessCodeMaster = [SELECT ID,Name FROM Business_Code__c WHERE Segment__c = :currentUser.Segment__c AND Name IN :mapBusinessCodeByOppPlanId.values()];
	//	Map<String,Business_Code__c> mapBusinessCodeByBusinessCodeName = new Map<String,Business_Code__c>();
	//	for(Business_Code__c eachBusinessCode : listBusinessCodeMaster){
	//		mapBusinessCodeByBusinessCodeName.put(eachBusinessCode.Name, eachBusinessCode);
	//	}

	//	Map<Id,Set<Id>> mapSetCallReportByOppId = new Map<Id,Set<Id>>();
	//	List<Call_Report_Opportunity__c> listCallReportOpp = [SELECT Id,Call_Plan_Call_Report__c,Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c IN :oppPlanningMapByCallReport.keySet()];
	//	for(Call_Report_Opportunity__c eachCallRepOpp : listCallReportOpp){
	//		if(!mapSetCallReportByOppId.containsKey(eachCallRepOpp.Opportunity_Name__c)){
	//			mapSetCallReportByOppId.put(eachCallRepOpp.Opportunity_Name__c,new Set<Id>());
	//		}
	//		mapSetCallReportByOppId.get(eachCallRepOpp.Opportunity_Name__c).add(eachCallRepOpp.Call_Plan_Call_Report__c);
	//	}

	//	Map<String, Id> oppRecordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Opportunity');
	//	Set<Id> opportunityIdResults = new Set<Id>();

	//	List<Call_Report_Opportunity_Planning__c> callReportOppPlanList = new List<Call_Report_Opportunity_Planning__c>();

	//	Map<String, Call_Report_Opportunity__c> callReportOppInsertMap = new Map<String, Call_Report_Opportunity__c>();
	//	Map<String, Id> callReportIdMap = new Map<String, Id>();
	//	Map<String, List<Id>> listCallReportIdMap = new Map<String, List<Id>>();
	//	Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
	//	Map<String, List<Opportunity_Product_CBS__c>> oppProductMap = new Map<String, List<Opportunity_Product_CBS__c>>();
	//	Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByExistingOppId = new Map<Id, List<Opportunity_Planning__c>>();
	//	Map<String, List<Opportunity_Planning__c>> listOppPlanningMapByOppTempKey = new Map<String, List<Opportunity_Planning__c>>();
	//	List<Opportunity_Product_CBS__c> newOppProductList = new List<Opportunity_Product_CBS__c>();

	//	Integer tempIndexOppCredit = 0;	
	//	Integer tempIndex = 0;
	//	for(Id callReportId : oppPlanningMapByCallReport.keySet()) {
	//		for(Opportunity_Planning__c eachOppPlanning : oppPlanningMapByCallReport.get(callReportId)) {
	//			tempIndexOppCredit++;
	//			if(eachOppPlanning.Add_to_Existing_Opportunity__c != null) {
	//				if(!oppPlanningMapByExistingOppId.containsKey(eachOppPlanning.Add_to_Existing_Opportunity__c)){
	//					oppPlanningMapByExistingOppId.put(eachOppPlanning.Add_to_Existing_Opportunity__c, new List<Opportunity_Planning__c>());
	//				}
	//				oppPlanningMapByExistingOppId.get(eachOppPlanning.Add_to_Existing_Opportunity__c).add(eachOppPlanning);
	//				opportunityIdResults.add(eachOppPlanning.Add_to_Existing_Opportunity__c);
	//			}

	//			callReportOppPlanList.add(newCallReportOpportunityPlanning(callReportId, eachOppPlanning));

	//			if(eachOppPlanning.Status__c == GlobalConstants.OPP_PLAN_WIN_MANDATE) {
	//				String tempKey = eachOppPlanning.Product_Type__c;
	//				if(eachOppPlanning.Add_to_Existing_Opportunity__c != null) {
	//	                if((!mapSetCallReportByOppId.containsKey(eachOppPlanning.Add_to_Existing_Opportunity__c) || (mapSetCallReportByOppId.containsKey(eachOppPlanning.Add_to_Existing_Opportunity__c) && !mapSetCallReportByOppId.get(eachOppPlanning.Add_to_Existing_Opportunity__c).contains(callReportId)))
	//	                	&& !callReportOppInsertMap.containsKey(callReportId + '-' + eachOppPlanning.Add_to_Existing_Opportunity__c)) {
	//	                	callReportOppInsertMap.put(callReportId + '-' + eachOppPlanning.Add_to_Existing_Opportunity__c, new Call_Report_Opportunity__c(
	//		                    Call_Plan_Call_Report__c = callReportId,
	//		                    Opportunity_Name__c = eachOppPlanning.Add_to_Existing_Opportunity__c
	//		                ));
	//	                }
	//				}

	//				if(!mapAllGroupedOppPlanningMapByOppPlanId.containsKey(eachOppPlanning.Id)){
	//					if(eachOppPlanning.Add_to_Existing_Opportunity__c == null){
	//						Account targetAccount = accountNameMapByOppPlanning.get(eachOppPlanning.Id);
	//						Opportunity tempOpp = newOpportunity(targetAccount.Name, targetAccount.Id, eachOppPlanning);
	//						tempOpp.Amount = 0;
	//						calculteOpportunityAmount(tempOpp,eachOppPlanning);
	//						if(mapBusinessCodeByBusinessCodeName.get(mapBusinessCodeByOppPlanId.get(eachOppPlanning.Id)) != null){
	//							tempOpp.Business_Code__c = mapBusinessCodeByBusinessCodeName.get(mapBusinessCodeByOppPlanId.get(eachOppPlanning.Id)).Id;
	//						}

	//						if(checkIsProductTypeCreditsetOpportunitySubmitIssue(tempOpp,eachOppPlanning) ){
	//							tempOpp.RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME);
	//							tempKey = tempKey + '' + tempIndexOppCredit;
	//						}else{
	//							tempOpp.RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.NON_CREDIT_OPPORTUNITY_DEVNAME);
	//			                tempKey = tempKey + '' + tempIndex;
	//			                tempIndex++;
	//						}

	//						opportunityMap.put(tempKey, tempOpp);
	//						callReportIdMap.put(tempKey, callReportId);
	//					}else{
	//						tempKey = tempKey + '' + tempIndex;
	//						tempIndex++;
	//						callReportIdMap.put(tempKey, callReportId);
	//					}

	//					if(!listOppPlanningMapByOppTempKey.containsKey(tempKey)){
	//						listOppPlanningMapByOppTempKey.put(tempKey,new List<Opportunity_Planning__c>());
	//					}
	//					listOppPlanningMapByOppTempKey.get(tempKey).add(eachOppPlanning);

	//					if(oppLineItemMapByOppPlanning.containsKey(eachOppPlanning.Id) && !oppLineItemMapByOppPlanning.isEmpty())
	//					for(Opportunity_Planning_Line_Item__c eachLineItem : oppLineItemMapByOppPlanning.get(eachOppPlanning.Id)) {
	//						if(eachOppPlanning.Add_to_Existing_Opportunity__c == null){
	//							Opportunity_Product_CBS__c tempOppProduct = newOpportunityProduct(eachOppPlanning, eachLineItem);
	//							if(!oppProductMap.containsKey(tempKey)) {
	//								oppProductMap.put(tempKey, new List<Opportunity_Product_CBS__c>());
	//							}
	//							oppProductMap.get(tempKey).add(tempOppProduct);
	//						}
	//					}
	//				}
	//			}
	//		}
	//	}
	//	Savepoint dbSavePoint = Database.setSavepoint();
	//	try {
	//		Integer tempOppGroupIndex = 1;
	//		for(GroupOpportunityPlanningWrapper eachGroupOpportunityPlanningWrapper : mapGroupingOppPlanningService.values()){
	//			Boolean isCreateOpp = true;
	//			if(eachGroupOpportunityPlanningWrapper.isGroup){
	//				String tempKey = '';
	//				Set<String> productList = new Set<String>();
	//				Account targetAccount = null;
	//				Boolean hasCredit = false;
	//				Boolean hasServicing = false;
	//				for(Opportunity_Custom_Controller.OppPlanningWrapper eachOppPlanningWrapper : eachGroupOpportunityPlanningWrapper.oppPlanningPageWrapperList){
	//					tempKey = tempKey+''+eachOppPlanningWrapper.newOppPlanning.Product_Type__c;
	//					productList.add(eachOppPlanningWrapper.newOppPlanning.Product_List_CBS__c);
	//					targetAccount = accountNameMapByOppPlanning.get(eachOppPlanningWrapper.newOppPlanning.Id);
						
	//					if(isProductTypeCredit(eachOppPlanningWrapper.newOppPlanning)){
	//						hasCredit = true;
	//					}else if(isProductTypeServicing(eachOppPlanningWrapper.newOppPlanning)){
	//						hasServicing= true;
	//					}


	//					if(eachOppPlanningWrapper.newOppPlanning.Add_to_Existing_Opportunity__c != null){
	//						isCreateOpp = false;
	//					}
	//				}

	//				if(!isCreateOpp){
	//					continue;
	//				}
	//				Opportunity tempOpp = new Opportunity(
	//		            Name = targetAccount.Name, 
	//		            AccountId = targetAccount.Id,
	//		            CloseDate = System.today(),
	//		            Amount = 0,
	//		            Opportunity_Planning_Remark__c = eachGroupOpportunityPlanningWrapper.remark,
	//		            Product_List_CBS__c = String.join(new List<String>(productList), ','),
	//		            StageName = GlobalConstants.STOCK_NEGOTIATION,
	//		            RecordTypeId = oppRecordTypeMapByDevName.get(GlobalConstants.CREDIT_OPPORTUNITY_DEVNAME)
	//		        );
	//		        if(hasCredit){
	//		        	tempOpp.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
	//		        }else{
	//		        	if(hasServicing){
	//						tempOpp.Submit_Issue__c = GlobalConstants.SERVICING;
	//					}else{
	//						tempOpp.Submit_Issue__c = GlobalConstants.RENEW_SERVICING;
	//					}
	//		        }
	//		        tempKey = tempKey + '' + tempIndexOppCredit;
	//		        tempIndexOppCredit++;

	//		        opportunityMap.put(tempKey, tempOpp);
	//		        if(!listOppPlanningMapByOppTempKey.containsKey(tempKey)){
	//					listOppPlanningMapByOppTempKey.put(tempKey,new List<Opportunity_Planning__c>());
	//				}
	//				for(Opportunity_Custom_Controller.OppPlanningWrapper eachOppPlanningWrapper : eachGroupOpportunityPlanningWrapper.oppPlanningPageWrapperList){
	//					listOppPlanningMapByOppTempKey.get(tempKey).add(eachOppPlanningWrapper.newOppPlanning);
	//					if(oppLineItemMapByOppPlanning.containsKey(eachOppPlanningWrapper.newOppPlanning.Id)){

	//						if(mapBusinessCodeByBusinessCodeName.get(mapBusinessCodeByOppPlanId.get(eachOppPlanningWrapper.newOppPlanning.Id)) != null){
	//							tempOpp.Business_Code__c = mapBusinessCodeByBusinessCodeName.get(mapBusinessCodeByOppPlanId.get(eachOppPlanningWrapper.newOppPlanning.Id)).Id;
	//						}
	//						calculteOpportunityAmount(tempOpp,eachOppPlanningWrapper.newOppPlanning);
	//						for(Opportunity_Planning_Line_Item__c eachLineItem : oppLineItemMapByOppPlanning.get(eachOppPlanningWrapper.newOppPlanning.Id)) {
	//							if(eachOppPlanningWrapper.newOppPlanning.Add_to_Existing_Opportunity__c == null){
	//								Opportunity_Product_CBS__c tempOppProduct = newOpportunityProduct(eachOppPlanningWrapper.newOppPlanning, eachLineItem);
	//								if(!oppProductMap.containsKey(tempKey)) {
	//									oppProductMap.put(tempKey, new List<Opportunity_Product_CBS__c>());
	//								}
	//								oppProductMap.get(tempKey).add(tempOppProduct);
	//							}
	//						}

	//						if(!listCallReportIdMap.containsKey(tempKey)){
	//							listCallReportIdMap.put(tempKey,new List<Id>());
	//						}
	//						listCallReportIdMap.get(tempKey).add(eachOppPlanningWrapper.newOppPlanning.Call_Report_CBS__c);
	//					}
	//				}
	//			}
	//		}
	//	    if(!oppPlanningMapByExistingOppId.isEmpty()) {
	//			List<Opportunity> existingOpportunities = new List<Opportunity>();
	//			List<Opportunity_Planning__c> listOppPlanningReleateOpp = new List<Opportunity_Planning__c>();
	//			List<Application_History__c> listUpdateRecordTypeAppHis = new List<Application_History__c>();
	//			Id recordtypeIdAppHisCredit = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Application_History__c','Credit_Application_History');
	//			existingOpportunities = getExisitingOpportunity(oppPlanningMapByExistingOppId);
	//			for(Opportunity existingOpp : existingOpportunities) {
	//				Set<String> oppProductSet = new Set<String>();
	//				if(existingOpp.Product_List_CBS__c != null) {
	//					oppProductSet.addAll(existingOpp.Product_List_CBS__c.split(','));
	//				}

	//				if(existingOpp.Amount == null ){
	//					existingOpp.Amount = 0;
	//				}
	//				for(Opportunity_Planning__c eachOppPlanning : oppPlanningMapByExistingOppId.get(existingOpp.Id)) {
	//					Set<String> oppPlanningProductSet = new Set<String>();
	//					eachOppPlanning.Opportunity__c = existingOpp.Id;
	//					listOppPlanningReleateOpp.add(eachOppPlanning);
	//					if(eachOppPlanning.Product_List_CBS__c != null) {
	//						oppPlanningProductSet.addAll(eachOppPlanning.Product_List_CBS__c.split(','));
	//					}

	//					if(existingOpp.Submit_Issue__c == GlobalConstants.RENEW_SERVICING && 
	//						(oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c != GlobalConstants.RENEW_SERVICING  )
	//					){
	//						existingOpp.Submit_Issue__c = oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c;
						
	//					}else if(existingOpp.Submit_Issue__c == GlobalConstants.SERVICING &&
	//						(oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c == GlobalConstants.NEW_CREDIT)
	//					){
	//						existingOpp.Submit_Issue__c = GlobalConstants.NEW_CREDIT;
	//					}
						
	//					oppProductSet.addAll(oppPlanningProductSet);
	//					existingOpp.Product_List_CBS__c = String.join(new List<String>(oppProductSet), ',');
	//					calculteOpportunityAmount(existingOpp,eachOppPlanning);

	//					if(oppLineItemMapByOppPlanning.containsKey(eachOppPlanning.Id)){
	//						for(Opportunity_Planning_Line_Item__c eachLineItem : oppLineItemMapByOppPlanning.get(eachOppPlanning.Id)) {
	//							if(eachOppPlanning.Add_to_Existing_Opportunity__c != null) {
	//								newOppProductList.add(newOpportunityProductFromExistingOpp(eachOppPlanning, eachLineItem));
	//							}
	//						}
	//					}
	//				}
	//			}

	//			update existingOpportunities;

	//			if(!listOppPlanningReleateOpp.isEmpty()){
	//				TriggerHandler.bypass('OpportunityPlanningTriggerHandler');
	//				update listOppPlanningReleateOpp;
	//				TriggerHandler.clearbypass('OpportunityPlanningTriggerHandler');
	//			}

	
	//			if(!listUpdateRecordTypeAppHis.isEmpty()){
	//				TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
	//				update listUpdateRecordTypeAppHis;
	//				TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
	//			}
	//		}

	//		if(!callReportOppPlanList.isEmpty())
	//			insert callReportOppPlanList;

	//		List<Opportunity_Planning__c> listUpdateOppPlanWithOppty = new List<Opportunity_Planning__c>();
	//		if(!opportunityMap.isEmpty()) {
	//			insert opportunityMap.values();

	//			for(String eachKey : opportunityMap.keySet()) {
	//				Id tempOppId = opportunityMap.get(eachKey).Id;
	//				opportunityIdResults.add(tempOppId);
	//				if(oppProductMap.containsKey(eachKey)){
	//					for(Opportunity_Product_CBS__c eachOppProduct : oppProductMap.get(eachKey)) {
	//						eachOppProduct.Opportunity_CBS__c = tempOppId;
	//						newOppProductList.add(eachOppProduct);
	//					}
	//				}

	//				for(Opportunity_Planning__c eachOppPlanning : listOppPlanningMapByOppTempKey.get(eachKey)){
	//					eachOppPlanning.Opportunity__c = tempOppId;
	//					listUpdateOppPlanWithOppty.add(eachOppPlanning);
	//				}
	//				if(callReportIdMap.containsKey(eachKey) && !callReportOppInsertMap.containsKey(callReportIdMap.get(eachKey) + '-' + tempOppId)) {
	//                	callReportOppInsertMap.put(callReportIdMap.get(eachKey) + '-' + tempOppId, new Call_Report_Opportunity__c(
	//	                    Call_Plan_Call_Report__c = callReportIdMap.get(eachKey),
	//	                    Opportunity_Name__c = tempOppId
	//	                ));
	//                }

	//                if(listCallReportIdMap.containsKey(eachKey)) {
	//                	for(Id eachCallRepId : listCallReportIdMap.get(eachKey)){
	//                		if(!callReportOppInsertMap.containsKey(eachCallRepId + '-' + tempOppId)){
	//                			callReportOppInsertMap.put(eachCallRepId + '-' + tempOppId, new Call_Report_Opportunity__c(
	//			                    Call_Plan_Call_Report__c = eachCallRepId,
	//			                    Opportunity_Name__c = tempOppId
	//			                ));
	//                		}
	//	                }
	//                }
						
	//			}
	//		}
	
	//		if(!newOppProductList.isEmpty())
	//			insert newOppProductList;

	//		TriggerHandler.bypass('OpportunityPlanningTriggerHandler');
	//		if(!listUpdateOppPlanWithOppty.isEmpty()){
	//			update listUpdateOppPlanWithOppty;
	//		}
	//		TriggerHandler.clearBypass('OpportunityPlanningTriggerHandler');

	//		TriggerHandler.bypass('CallReportOpportunityTriggerHandler');
	//		if(!callReportOppInsertMap.isEmpty())
	//			insert callReportOppInsertMap.values();
	//		TriggerHandler.clearBypass('CallReportOpportunityTriggerHandler');
	//	}
	//	catch (Exception e) {
	//	    Database.rollback(dbSavePoint);
 //           throw new OpportunityServiceException(e.getMessage());
	//	}

	//	return opportunityIdResults;
	//}

	//private static Opportunity_Product_CBS__c newOpportunityProductFromExistingOpp(Opportunity_Planning__c eachOppPlanning, Opportunity_Planning_Line_Item__c eachLineItem) {
	//	return new Opportunity_Product_CBS__c(
 //       	Opportunity_CBS__c = eachOppPlanning.Add_to_Existing_Opportunity__c,
 //       	Product_Name__c = eachLineItem.Product_Name__c,
 //       	Product_Type__c = eachOppPlanning.Product_Type__c,
 //       	Fee__c = eachOppPlanning.Fee__c,
 //       	Front_End_Fee__c = eachOppPlanning.Front_End_Fee__c,
 //       	New_Limit__c = eachOppPlanning.New_Limit__c,
 //       	Volume_Outstanding__c = eachOppPlanning.Volume_Outstanding__c
 //       );
	//}

	//private static Opportunity_Product_CBS__c newOpportunityProduct(Opportunity_Planning__c eachOppPlanning, Opportunity_Planning_Line_Item__c eachLineItem) {
	//	return new Opportunity_Product_CBS__c(
 //       	Product_Name__c = eachLineItem.Product_Name__c,
 //       	Product_Type__c = eachOppPlanning.Product_Type__c,
 //       	Fee__c = eachOppPlanning.Fee__c,
 //       	Front_End_Fee__c = eachOppPlanning.Front_End_Fee__c,
 //       	New_Limit__c = eachOppPlanning.New_Limit__c,
 //       	Volume_Outstanding__c = eachOppPlanning.Volume_Outstanding__c
 //       );
	//}

	//private static Call_Report_Opportunity_Planning__c newCallReportOpportunityPlanning(Id callReportId, Opportunity_Planning__c eachOppPlanning) {
	//	return new Call_Report_Opportunity_Planning__c(
	//				Call_Plan_Call_Report_CBS__c = callReportId,
	//				Opportunity_Planning_CBS__c = eachOppPlanning.Id,
	//				Opportunity_Planning_Status_Logged_CBS__c = eachOppPlanning.Status__c,
	//				Project_Size_Logged_CBS__c = eachOppPlanning.Project_Size__c,
	//				Expected_Income_Logged_CBS__c = eachOppPlanning.Expected_Income_to_KBank__c,
	//		        Expected_Limit_Volume_Logged_CBS__c = eachOppPlanning.Expected_LimitVolume_Amount__c,
	//		        Remark_Logged_CBS__c = eachOppPlanning.Remark__c,
	//		        Fee_Logged__c = eachOppPlanning.Fee__c,
	//		        New_Limit_Logged__c = eachOppPlanning.New_Limit__c,
	//		        Frontend_Fee_Logged__c = eachOppPlanning.Front_End_Fee__c,
	//		        Volume_Outstanding_Logged__c = eachOppPlanning.Volume_Outstanding__c
	//			);
	//}

	//private static Opportunity newOpportunity(String accountName, String accountId, Opportunity_Planning__c eachOppPlanning) {

	//	return new Opportunity(
	//	            Name = accountName, 
	//	            AccountId = accountId,
	//	            CloseDate = System.today(),
	//	            Amount = 0,
	//	            Opportunity_Planning_Remark__c = eachOppPlanning.Remark__c,
	//	            Product_List_CBS__c = eachOppPlanning.Product_List_CBS__c
	//	        );
	//}

	//global class OpportunityServiceException extends Exception{}
	//public static List<User_Extension__c> getUserExByTeamStructureId(String teamStructure){
	//	List<User_Extension__c> userExList = [SELECT Name,Segment__c,Position__c,Team_Name__c,Team_Structure__c,Team_Structure__r.AH_Name_Report__c,User__c,User__r.IsActive FROM User_Extension__c WHERE (Segment__c = :GlobalConstants.SEGMENT_CB OR Segment__c = :GlobalConstants.SEGMENT_MB) AND Team_Structure__c =:teamStructure AND User__r.IsActive = true];
	//	return userExList;
	//}

	//public static void calculteOpportunityAmount(Opportunity opportunity, Opportunity_Planning__c eachOppPlanning){
	//	if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType != null){
	//		if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.containsKey(eachOppPlanning.Product_Type__c)) {
	//			Opportunity_Planning_Type__c oppPlaningCS = OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c);
	//			String customFieldOppPlanning = (oppPlaningCS.To_Opportunity_Amount__c).toLowerCase();
	//			if(OpportunityPlanning_Service.oppPlanningFields.contains( customFieldOppPlanning )){
	//				opportunity.Amount = opportunity.Amount+GlobalUtility.toDecimal( GlobalUtility.toValue( eachOppPlanning.get(customFieldOppPlanning)));
	//			}
	//		}
	//	}
	//}

	//public static Boolean isProductTypeCredit(Opportunity_Planning__c eachOppPlanning){

	//	if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType != null){
	//		if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.containsKey(eachOppPlanning.Product_Type__c)  &&
	//			(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c == GlobalConstants.NEW_CREDIT)){
	//				return true;
	//		}
	//	}
	//	return false;
	//}


	//public static Boolean isProductTypeServicing(Opportunity_Planning__c eachOppPlanning){
	//	if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType != null){
	//		if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.containsKey(eachOppPlanning.Product_Type__c)  &&
	//			(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType.get(eachOppPlanning.Product_Type__c).Submit_Issue_in_Opportunity__c == GlobalConstants.SERVICING)){
	//				return true;
	//		}
	//	}
	//	return false;
	//}

	//private static List<Opportunity> getExisitingOpportunity(Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByExistingOppId){
	//	return [SELECT Id, Amount,Submit_Issue__c, Project_Size_CBS__c, Expected_Fee_CBS__c, Product_List_CBS__c,(SELECT Id,RecordTypeId FROM Application_History__r) FROM Opportunity WHERE Id IN :oppPlanningMapByExistingOppId.keySet()];
	//}


	//private static void setUpStaticVariable(){
	//	if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType == null){
	//		OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType = CBS_Utility.getOppPlanningTypeCustomSettingMapByType();
	//	}

	//	if(OpportunityPlanning_Service.oppPlanningFields == null){
	//		OpportunityPlanning_Service.oppPlanningFields = Schema.SObjectType.Opportunity_Planning__c.fields.getMap().keySet();
	//	}
	//}

	//public static Boolean checkIsProductTypeCreditsetOpportunitySubmitIssue(Opportunity opp,Opportunity_Planning__c oppPlanning){
	//	Boolean credit = false;
	//	if(OpportunityPlanning_Service.oppPlanningCSMapByOppPlanType != null){
	//		if(oppPlanningCSMapByOppPlanType.containsKey(oppPlanning.Product_Type__c)){
	//			Opportunity_Planning_Type__c eachoppPlanningTypeCS = oppPlanningCSMapByOppPlanType.get(oppPlanning.Product_Type__c);
				
	//			if(eachoppPlanningTypeCS.Opportunity_Type__c == GlobalConstants.OPP_PLAN_CREDIT) {
	//				opp.StageName = GlobalConstants.STOCK_NEGOTIATION;
	//				credit = true;
	//			}else{
	//			 	opp.StageName = GlobalConstants.NEW_OPPORTUNITY;
	//			 	credit = false;
	//			}
	//			opp.Submit_Issue__c = eachoppPlanningTypeCS.Submit_Issue_in_Opportunity__c;
	//		}

	//	}
	//	return credit;
	//}

}