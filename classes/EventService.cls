public without sharing class EventService {
	private static Map<Id, Id> closeEventMapByEditableRecordType;
    public static Set<Id> getRecordTypeRBS(){
		Set<Id> setRecordTypeRBS = new Set<Id>();
		Schema.SObjectType sObjType = Schema.getGlobalDescribe().get('Event');
		for(RecordTypeInfo info : sObjType.getDescribe().getRecordTypeInfos()) {
			if(GlobalConstants.CALL_PLAN_CALL_REPORT_RBS_DEVNAME_SET.contains(info.getDeveloperName())){
				setRecordTypeRBS.add(info.getRecordTypeId());
			}
		}
		return setRecordTypeRBS;
	}
    
	public static Id getCloseEventRecordType(Id editableRecordTypeId){
		Id SME_CALL_PLAN_READ_ONLY_DEVNAME 					= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_READ_ONLY_DEVNAME);
		Id SME_CALL_REPORT_READ_ONLY_DEVNAME 				= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_READ_ONLY_DEVNAME);
		Id SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME 	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME);
		Id RBS_CALL_PLAN_READ_ONLY_DEVNAME 					= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_READ_ONLY_DEVNAME);
		Id RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME 		= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME);
		Id CBS_CALL_PLAN_READ_ONLY_DEVNAME 					= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_READ_ONLY_DEVNAME);
		Id CBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME 		= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME);
		Id CBS_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME 	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME);
		if(closeEventMapByEditableRecordType == null) {
			closeEventMapByEditableRecordType = new Map<Id, Id>();

			Schema.SObjectType sObjType = Schema.getGlobalDescribe().get('Event');
			for(RecordTypeInfo info : sObjType.getDescribe().getRecordTypeInfos()) {
				if(info.getDeveloperName() == GlobalConstants.SME_CALL_PLAN_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), SME_CALL_PLAN_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME || info.getDeveloperName() == GlobalConstants.SME_CALL_REPORT_SECONDARY_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), SME_CALL_REPORT_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.RBS_CALL_PLAN_DEVNAME || info.getDeveloperName() == GlobalConstants.RBS_CALL_PLAN_FOR_APPROVE_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), RBS_CALL_PLAN_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), RBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.CBS_CALL_PLAN_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), CBS_CALL_PLAN_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), CBS_CALL_PLAN_CALL_REPORT_READ_ONLY_DEVNAME);
				} else if(info.getDeveloperName() == GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME) {
					closeEventMapByEditableRecordType.put(info.getRecordTypeId(), CBS_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME);
				}
			}
		}
		return closeEventMapByEditableRecordType.get(editableRecordTypeId);
	}

	public static void updateEventTeamHierachy(List<Event> eventList)  {
		getUserManager().updateEventTeamHierachy(eventList);
	}

	public static void validateEditPermission(List<Event> eventList) {
		getUserManager().validateEditPermission(eventList);
	}

	public static void stampUserExtension(List<Event> eventList) {
		User_Extension__c currentUserExt = UserExtension_Service.getUserExtensionFromCurrentUserInfo();
		if(currentUserExt != null){
          for(Event eachEvent : eventList){
				eachEvent.Created_By_User_Extension__c = currentUserExt.Id;
			}  
        }
	}

	public static void autoGenerateSubject(List<Event> eventList) {
		Map<String, Id> recordTypeSMEMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event');
		Id individualCustomer =  GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account','Individual_Customer');
		Id individualProspect =  GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account','Individual_Prospect');
		Id organizeCustomer =  GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account','Organization_Customer');
		Id organizeProspect =  GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account','Organization_Prospect');

		Set<Id> recordTypeIdSMESet = new Set<Id>();
		Set<Id> jobRelatedIdSet = new Set<Id>();
		Map<Id,Opportunity> jobRelatedByIdMap = new Map<Id,Opportunity>();

		for(String eachDevname : recordTypeSMEMap.keySet()){
			if(eachDevname == GlobalConstants.SME_CALL_REPORT_SECONDARY_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_REPORT_READ_ONLY_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_READ_ONLY_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_PLAN_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_PLAN_READ_ONLY_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME){
				recordTypeIdSMESet.add(recordTypeSMEMap.get(eachDevname));
			}
		}

		for(Event eachEvent : eventList){
			if(eachEvent.WhatId !=NULL && String.isEmpty(eachEvent.Subject) && recordTypeIdSMESet.contains(eachEvent.RecordTypeId)){
				jobRelatedIdSet.add(eachEvent.WhatId);
			}
		}

		if(!jobRelatedIdSet.isEmpty()){
			List<Opportunity> relatedJobList = [SELECT Id,AccountId,Account.FirstName,Account.LastName,Account.Name,Account.RecordTypeId FROM Opportunity WHERE Id=:jobRelatedIdSet];
			for(Opportunity eachOpp : relatedJobList){
				jobRelatedByIdMap.put(eachOpp.Id,eachOpp);
			}

			for(Event eachEvent : eventList){
				if(jobRelatedByIdMap.containsKey(eachEvent.WhatId)){
					Id accountRecordTypeId = jobRelatedByIdMap.get(eachEvent.WhatId).Account.RecordTypeId;
					if(accountRecordTypeId == individualCustomer || accountRecordTypeId == individualProspect){
						eachEvent.Subject = jobRelatedByIdMap.get(eachEvent.WhatId).Account.FirstName + ' '+ jobRelatedByIdMap.get(eachEvent.WhatId).Account.FirstName;
					}else if(accountRecordTypeId == organizeCustomer || accountRecordTypeId == organizeProspect){
						eachEvent.Subject = jobRelatedByIdMap.get(eachEvent.WhatId).Account.Name;
					}
				}
			}
		}
	}

	public static void validateSecondaryCallreport(List<Event> eventList) {
		Set<Id> primaryIds = new Set<Id>();
		for(Event eachEvent : eventList){
			if(eachEvent.Primary_Call_Report_Id__c != null) {
				primaryIds.add(eachEvent.Primary_Call_Report_Id__c);
			}
		}
		if(!primaryIds.isEmpty()) {
			Map<Id, Event> primaryEventMap = new Map<Id, Event>(
				[SELECT Id, Secondary_Call_Report_ID1__c, Secondary_Call_Report_ID2__c FROM Event 
				WHERE Id IN :primaryIds]);
			for(Event eachEvent : eventList) {
				if(eachEvent.Primary_Call_Report_Id__c != null) {
					Event mainEvent = primaryEventMap.get(eachEvent.Primary_Call_Report_Id__c);
					if(mainEvent.Secondary_Call_Report_ID1__c != null && mainEvent.Secondary_Call_Report_ID2__c != null) {
						eachEvent.addError(Label.Call_ReachMaxAsso);
					}
				}
			}
		}
	}

	public static void stampCBSSecondarycallReport(List<Event> eventList) {
		Set<Id> jobSetId = new Set<Id>();
		Set<Id> recordTypeIdCBSSet = new Set<Id>();
		Map<String, Id> recordTypeCBSMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event');
		Set<Id> callReportIdInChunkSet = new Set<Id>();
		for(String eachDevname : recordTypeCBSMap.keySet()){
			if(eachDevname == GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME){
				recordTypeIdCBSSet.add(recordTypeCBSMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME){
				recordTypeIdCBSSet.add(recordTypeCBSMap.get(eachDevname));
			}
		}
		for(Event eachEvent : eventList){
			if(recordTypeIdCBSSet.contains(eachEvent.RecordTypeId) && eachEvent.Id !=NULL){
				callReportIdInChunkSet.add(eachEvent.Id);
			}
		}
		List<Event> eventTodayList = [SELECT ID,WhatId FROM Event WHERE OwnerId =:UserInfo.getUserId() AND RecordTypeId=:recordTypeIdCBSSet AND CreatedDate = TODAY AND ID !=:callReportIdInChunkSet];
		if(!eventTodayList.isEmpty()){
			Set<Id> jobTodaySet = new Set<Id>();
			for(Event eachEventToday : eventTodayList){
				jobTodaySet.add(eachEventToday.WhatId);
			}

			for(Event eachEvent : eventList){
				if(recordTypeIdCBSSet.contains(eachEvent.RecordTypeId) && jobTodaySet.contains(eachEvent.WhatId)){
					eachEvent.Secondary_Call_Report__c = true;
				}
			}
		}
		
	}

	public static void updatePrimaryCallreport(List<Event> eventList) {
		Set<Id> primaryIds = new Set<Id>();
		for(Event eachEvent : eventList){
			if(eachEvent.Primary_Call_Report_Id__c != null) {
				primaryIds.add(eachEvent.Primary_Call_Report_Id__c);
			}
		}
		if(!primaryIds.isEmpty()) {
			Map<Id, Event> primaryEventMap = new Map<Id, Event>(
				[SELECT Id, Secondary_Call_Report_ID1__c, Secondary_Call_Report_ID2__c, Secondary_Call_Report_Name1__c, Secondary_Call_Report_Name2__c FROM Event 
				WHERE Id IN :primaryIds]);
			Map<String,Event> primaryEventUpdateMap = new Map<String,Event>();
			for(Event eachEvent : eventList){
				if(eachEvent.Primary_Call_Report_Id__c != null) {
					Event mainEvent = primaryEventMap.get(eachEvent.Primary_Call_Report_Id__c);
					if(mainEvent.Secondary_Call_Report_ID1__c == null) {
						mainEvent.Secondary_Call_Report_ID1__c = eachEvent.Id;
						mainEvent.Secondary_Call_Report_Name1__c = eachEvent.Subject;
						primaryEventUpdateMap.put(eachEvent.Primary_Call_Report_Id__c,mainEvent);
					} else if(mainEvent.Secondary_Call_Report_ID2__c == null) {
						mainEvent.Secondary_Call_Report_ID2__c = eachEvent.Id;
						mainEvent.Secondary_Call_Report_Name2__c = eachEvent.Subject;
						primaryEventUpdateMap.put(eachEvent.Primary_Call_Report_Id__c,mainEvent);
					} else {
						System.debug(Label.Call_ReachMaxAsso);
					}
				}
			}
			TriggerHandler.bypass('EventTriggerHandler');
			update primaryEventUpdateMap.values();
			TriggerHandler.clearBypass('EventTriggerHandler');
		}
	}

	public static void updateAccountInfo(Map<Id,Event> oldEventMap,List<Event> newEventList) {
		Id CBS_CALL_PLAN 							= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_DEVNAME);
		Id CBS_CALL_PLAN_CALL_REPORT_EDITABLE		= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME);
		Id CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME);

		Set<Id> accountIDSet = new Set<Id>();
		Map<Id,Account> accountMap = new Map<Id,Account>();
		for(Event eachEvent : newEventList){
			accountIDSet.add(eachEvent.AccountId);
		}
		if(!accountIDSet.isEmpty()){
			List<Account> relatedAccList = [SELECT Id, Current_Activity_By__c, Current_Activity__c,Last_Visited_DateTime__c,Customer_Importance_Note__c FROM Account WHERE ID =:accountIDSet];
			if(relatedAccList!=NULL && !relatedAccList.isEmpty()){
				for(Account eachAccount : relatedAccList){
					accountMap.put(eachAccount.Id,eachAccount);
				}
			}
		}

		for(Event eachEvent : newEventList){
			Boolean hasUpdateActivity = true;
			if(accountMap.containsKey(eachEvent.AccountId)){
				if(eachEvent.status__c == GlobalConstants.PLAN){
					if(oldEventMap != NULL && oldEventMap.containsKey(eachEvent.Id) && oldEventMap.get(eachEvent.Id).status__c == GlobalConstants.PLAN){
						hasUpdateActivity = false;
					}

					if(hasUpdateActivity){
						accountMap.get(eachEvent.AccountId).Current_Activity_By__c = eachEvent.OwnerId;
						accountMap.get(eachEvent.AccountId).Current_Activity__c = GlobalConstants.CALL_PLAN;
					}

					if(!String.isEmpty(eachEvent.Description) && eachEvent.RecordTypeId != CBS_CALL_PLAN){
						accountMap.get(eachEvent.AccountId).Customer_Importance_Note__c =  eachEvent.Description;
					}
				}else if(eachEvent.status__c == GlobalConstants.CONTACTED){
					if(oldEventMap != NULL && oldEventMap.containsKey(eachEvent.Id) && oldEventMap.get(eachEvent.Id).status__c == GlobalConstants.CONTACTED){
						hasUpdateActivity = false;
					}
					if(hasUpdateActivity){
						accountMap.get(eachEvent.AccountId).Last_Visited_DateTime__c = eachEvent.StartDateTime;
						accountMap.get(eachEvent.AccountId).Current_Activity_By__c = eachEvent.OwnerId;
						accountMap.get(eachEvent.AccountId).Current_Activity__c = GlobalConstants.CALL_REPORT;
					}
					if(!String.isEmpty(eachEvent.Description) && eachEvent.RecordTypeId != CBS_CALL_PLAN_CALL_REPORT_EDITABLE && eachEvent.RecordTypeId != CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE){
						accountMap.get(eachEvent.AccountId).Customer_Importance_Note__c =  eachEvent.Description;
					}
				}
			}
		}

		if(!accountMap.isEmpty()){
			TriggerHandler.bypass('AccountTriggerHandler');
				update accountMap.values();
			TriggerHandler.clearBypass('AccountTriggerHandler');
		}
	}

	public static void updateJobInfo(Map<Id,Event> oldEventMap,List<Event> newEventList) {
		Set<Id> oppIDSet = new Set<Id>();
		Set<Id> recordTypeIdCBSSet = new Set<Id>();
        Id recordTypeIdTeleSales;
		Map<Id,Opportunity> oppRelatedMap = new Map<Id,Opportunity>();
		Map<String, Id> recordTypeCBSMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event');
		
		for(String eachDevname : recordTypeCBSMap.keySet()){
			if(eachDevname == GlobalConstants.CBS_CALL_PLAN_DEVNAME){
				recordTypeIdCBSSet.add(recordTypeCBSMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME){
				recordTypeIdCBSSet.add(recordTypeCBSMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME){
				recordTypeIdCBSSet.add(recordTypeCBSMap.get(eachDevname));
			}else if(eachDevname == GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME){
				recordTypeIdTeleSales = recordTypeCBSMap.get(eachDevname);
			}
		}
		for(Event eachEvent : newEventList){
			if(eachEvent.WhatId != NULL){
				oppIDSet.add(eachEvent.WhatId);
			}
		}
		if(!oppIDSet.isEmpty()){
			List<Opportunity> relatedOppList = [SELECT Id, StageName,Jobstage__c,First_Contacted_Date__c, Latest_Contacted_Date__c, Call_Report_Face_to_Face__c,Actual_Visit_Date__c,Actual_Visit_Date_CBS__c FROM Opportunity WHERE ID =:oppIDSet ];
			if(relatedOppList!=NULL && !relatedOppList.isEmpty()){
				for(Opportunity eachOpp : relatedOppList){
					oppRelatedMap.put(eachOpp.Id,eachOpp);
				}
			}
		}

		for(Event eachEvent : newEventList){
			Boolean hasUpdateActivity = true;
			if(oppRelatedMap.containsKey(eachEvent.WhatId)){
				Opportunity jobRelatedRecord = oppRelatedMap.get(eachEvent.WhatId);
				if(recordTypeIdTeleSales != eachEvent.RecordTypeId){
                    if(eachEvent.status__c == GlobalConstants.PLAN){
                        if(jobRelatedRecord.StageName == GlobalConstants.STATUS_OPEN){
                            jobRelatedRecord.StageName = GlobalConstants.PLAN;
                            jobRelatedRecord.Jobstage__c = GlobalConstants.PLAN;
                        }
                    }else if(eachEvent.status__c == GlobalConstants.CONTACTED){
                        if(jobRelatedRecord.StageName == GlobalConstants.STATUS_OPEN || jobRelatedRecord.StageName == GlobalConstants.PLAN){
                            jobRelatedRecord.StageName = GlobalConstants.CONTACTED;
                            jobRelatedRecord.Jobstage__c = GlobalConstants.CONTACTED;
                        }
                        if(jobRelatedRecord.First_Contacted_Date__c == NULL){
                            jobRelatedRecord.First_Contacted_Date__c = eachEvent.StartDateTime;
                        }
                        if(eachEvent.Contact_Channel__c == GlobalConstants.FACE_TO_FACE){
                            jobRelatedRecord.Call_Report_Face_to_Face__c = true;
                        }
                        if(recordTypeIdCBSSet.contains(eachEvent.RecordTypeId) && (eachEvent.Product__c == GlobalConstants.OPP_PLAN_CREDIT ||  eachEvent.Product__c == GlobalConstants.OPP_PLAN_CREDITANDNONCREDIT) && jobRelatedRecord.Actual_Visit_Date_CBS__c == NULL){
                            jobRelatedRecord.Actual_Visit_Date_CBS__c = date.newinstance(eachEvent.StartDateTime.year(), eachEvent.StartDateTime.month(), eachEvent.StartDateTime.day());
                        }
                        jobRelatedRecord.Latest_Contacted_Date__c = eachEvent.StartDateTime;
                    }
                }
			}
		}

		if(!oppRelatedMap.isEmpty()){
			TriggerHandler.bypass('OpportunityTriggerHandler');
				update oppRelatedMap.values();
			TriggerHandler.clearBypass('OpportunityTriggerHandler');
		}
	}

	public static void updateTelesalesLeadStatus(List<Event> listEvent) {
		List<Event> teleSaleEventList = new List<Event>();
		Id telesalesRecordType = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME);

		for(Event eachEvent : listEvent){
			if(eachEvent.RecordTypeId == telesalesRecordType && eachEvent.WhoId !=null && eachEvent.WhoId.getSObjectType() == Schema.Lead.SObjectType){
				teleSaleEventList.add(eachEvent);
			}
		}
		if(!teleSaleEventList.isEmpty()){
			Map<Id,Lead> mapUpdateRelatedLead = new Map<Id,Lead>();
			Map<String,Telesales_Product_Name_to_Field_Mapping__c> mapProductNameFieldByDisplayName = new Map<String,Telesales_Product_Name_to_Field_Mapping__c>();
			List<Telesales_Call_Results_Mapping__mdt> telesalesCallResultsList = new List<Telesales_Call_Results_Mapping__mdt>();
			Map<String,Telesales_Call_Results_Mapping__mdt> telesalesCallResultsByCallResultMap = new Map<String,Telesales_Call_Results_Mapping__mdt>();
			Map<String,Telesales_Call_Results_Mapping__mdt> telesalesCallResultsByAnswerLV2Map = new Map<String,Telesales_Call_Results_Mapping__mdt>();
			Map<String,Telesales_Call_Results_Mapping__mdt> telesalesCallResultsByAnswerLV3Map = new Map<String,Telesales_Call_Results_Mapping__mdt>();
			telesalesCallResultsList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Call_Result__c, Answer_LV2__c, Answer_LV3__c, Lead_Status__c, Update_First_Contacted_Date__c FROM Telesales_Call_Results_Mapping__mdt];

			for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
				mapProductNameFieldByDisplayName.put(eachMapping.Display_Product_Name_As__c, eachMapping);
	       	}

	       	for(Telesales_Call_Results_Mapping__mdt eachCallResultMapping : telesalesCallResultsList){
	       		if(eachCallResultMapping.Answer_LV3__c !=null){
	       			telesalesCallResultsByAnswerLV3Map.put(eachCallResultMapping.Answer_LV3__c,eachCallResultMapping);
       			}else if(eachCallResultMapping.Answer_LV2__c !=null){
       				telesalesCallResultsByAnswerLV2Map.put(eachCallResultMapping.Answer_LV2__c,eachCallResultMapping);
       			}else if(eachCallResultMapping.Call_Result__c !=null){
       				telesalesCallResultsByCallResultMap.put(eachCallResultMapping.Call_Result__c,eachCallResultMapping);
       			}
	       	}

			for(Event eachEvent : teleSaleEventList){
				Lead updateLeadProduct = new Lead(Id = eachEvent.WhoId);
				if(!String.isBlank(eachEvent.Product_Interest__c)){
					List<String> listInterestProduct = eachEvent.Product_Interest__c.split(';');
					for(String eachInterestProduct : listInterestProduct){
						Telesales_Product_Name_to_Field_Mapping__c mappingField = mapProductNameFieldByDisplayName.get(eachInterestProduct);
						if(mappingField == null) continue;
						updateLeadProduct.put(mappingField.Field_API_Name__c,true);
					}
				}
				if(eachEvent.Answer_LV3__c !=NULL && !telesalesCallResultsByAnswerLV3Map.isEmpty() && telesalesCallResultsByAnswerLV3Map.containsKey(eachEvent.Answer_LV3__c)){
					updateLeadProduct.Status = telesalesCallResultsByAnswerLV3Map.get(eachEvent.Answer_LV3__c).Lead_Status__c;
					if(telesalesCallResultsByAnswerLV3Map.get(eachEvent.Answer_LV3__c).Update_First_Contacted_Date__c !=null && telesalesCallResultsByAnswerLV3Map.get(eachEvent.Answer_LV3__c).Update_First_Contacted_Date__c == true){
						updateLeadProduct.First_Contacted_Date__c = eachEvent.StartDateTime;
					}
				}else if(eachEvent.Answer_LV2__c !=NULL && !telesalesCallResultsByAnswerLV2Map.isEmpty() && telesalesCallResultsByAnswerLV2Map.containsKey(eachEvent.Answer_LV2__c)){
					updateLeadProduct.Status = telesalesCallResultsByAnswerLV2Map.get(eachEvent.Answer_LV2__c).Lead_Status__c;
					if(telesalesCallResultsByAnswerLV2Map.get(eachEvent.Answer_LV2__c).Update_First_Contacted_Date__c !=null && telesalesCallResultsByAnswerLV2Map.get(eachEvent.Answer_LV2__c).Update_First_Contacted_Date__c == true){
						updateLeadProduct.First_Contacted_Date__c = eachEvent.StartDateTime;
					}
				}else if(eachEvent.Call_Result__c !=NULL && !telesalesCallResultsByCallResultMap.isEmpty() && telesalesCallResultsByCallResultMap.containsKey(eachEvent.Call_Result__c)){
					updateLeadProduct.Status = telesalesCallResultsByCallResultMap.get(eachEvent.Call_Result__c).Lead_Status__c;
					if(telesalesCallResultsByCallResultMap.get(eachEvent.Call_Result__c).Update_First_Contacted_Date__c !=null && telesalesCallResultsByCallResultMap.get(eachEvent.Call_Result__c).Update_First_Contacted_Date__c == true){
						updateLeadProduct.First_Contacted_Date__c = eachEvent.StartDateTime;
					}
				}
				updateLeadProduct.Answer_LV3__c = eachEvent.Answer_LV3__c;
				updateLeadProduct.Answer_LV2__c = eachEvent.Answer_LV2__c;
				updateLeadProduct.Call_Result__c = eachEvent.Call_Result__c;
				updateLeadProduct.Description = eachEvent.Description;
				mapUpdateRelatedLead.put(updateLeadProduct.Id, updateLeadProduct);

			}

			if(!mapUpdateRelatedLead.values().isEmpty()) update mapUpdateRelatedLead.values();
		}
	}

	public static void validateCreateEventTelesalesPermission(List<Event> listEvent) {
		Id telesalesRecordType = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.EVENT_RECORDTYPE_TELESALES_DEVNAME);
		List<Id> listLeadId = new List<Id>();
		for(Event eachEvent : listEvent){
			Id leadId = eachEvent.WhoId;
			if(eachEvent.RecordTypeId == telesalesRecordType && leadId != null && leadId.getSObjectType() == Schema.Lead.SObjectType){
				listLeadId.add(eachEvent.WhoId);
			} 
		}
		if(listLeadId.size() > 0){
			Map<Id,Lead> mapRelatedLeadById = new Map<Id,Lead>([SELECT Id,Assigned_Owner__c,Assigned_Owner__r.ManagerId,Assigned_Owner__r.Manager.ManagerId,Assigned_Owner__r.Manager.Manager.ManagerId FROM LEAD WHERE Id IN :listLeadId]);
			for(Event eachEvent : listEvent){
				if(mapRelatedLeadById.containsKey(eachEvent.WhoId)){
					Lead relatedLead = mapRelatedLeadById.get(eachEvent.WhoId);
					if(isRecordOwnerOrOwnerManager(relatedLead)){
						eachEvent.addError(Label.NotAllowAnswerOthersLead);
					}
				} 
			}
		}
	}

	private static Boolean isRecordOwnerOrOwnerManager(Lead relatedLead){
		if(relatedLead.Assigned_Owner__c != null && relatedLead.Assigned_Owner__c != UserInfo.getUserId()
			&& relatedLead.Assigned_Owner__r.ManagerId != null && relatedLead.Assigned_Owner__r.ManagerId != UserInfo.getUserId()
			&& relatedLead.Assigned_Owner__r.Manager.ManagerId != null && relatedLead.Assigned_Owner__r.Manager.ManagerId != UserInfo.getUserId()
			&& relatedLead.Assigned_Owner__r.Manager.Manager.ManagerId != null && relatedLead.Assigned_Owner__r.Manager.Manager.ManagerId != UserInfo.getUserId()){
			return true;
		}
		return false;
	}

	public static void validateContactThatUpsertCallReport(Map<Id, Event> mapEvent) {
		//This code use for validate the event account and account that relate to contact when create "call report"
		//Select the eventRelation that realte to created event.;
		Set<Id> SME_CBS_CallReport_Set = new Set<Id>();
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'SME_Call_Plan_Call_Report_Editable'));
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'SME_Call_Report_without_Plan'));
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'SME_Call_Report_Secondary'));
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'CBS_Call_Plan'));
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'CBS_Call_Plan_Call_Report_Editable'));
		SME_CBS_CallReport_Set.add(GlobalUtility.getRecordTypeId('Event', 'CBS_Call_Report_without_Plan_Editable'));
		
		List<EventRelation> callReportEventRelation = [
			SELECT EventId, RelationId, Relation.RecordTypeId, Account.personContactId
			FROM EventRelation 
			WHERE EventId IN :mapEvent.keySet() AND Event.RecordTypeId IN :SME_CBS_CallReport_Set
		];
		
		Set<Id> contactInCallReportIdSet = new set<Id>();
		for(EventRelation eachEventRela : callReportEventRelation){
			if(eachEventRela.RelationId.getsObjectType() == Contact.sObjectType){
				contactInCallReportIdSet.add(eachEventRela.RelationId);
			}
		}
		Map<Id, Contact> contactInCallReportMapById = new Map<Id, Contact>([
			SELECT Id, AccountId, CIS__c
			FROM Contact
			WHERE Id IN :contactInCallReportIdSet
		]);
		
		for(EventRelation eachEventRela : callReportEventRelation){
			Event eachEvent  = mapEvent.get(eachEventRela.EventId);
			//Check that event is SEM call report.
			if(eachEventRela.Relation.recordTypeId == GlobalUtility.getRecordTypeId('Contact', 'Individual_Contact')){
				Contact eachContact = contactInCallReportMapById.get(eachEventRela.RelationId);
				if(eachEvent.AccountId != eachContact.CIS__c) eachEvent.addError(Label.Event_Validate_Contact);
			}else if(eachEventRela.Relation.recordTypeId == GlobalUtility.getRecordTypeId('Contact', 'SME_Contact')
				   ||eachEventRela.Relation.recordTypeId == GlobalUtility.getRecordTypeId('Contact', 'CBS_Contact')){
				Contact eachContact = contactInCallReportMapById.get(eachEventRela.RelationId);
				if(eachEvent.AccountId != eachContact.AccountId) eachEvent.addError(Label.Event_Validate_Contact);
			}else if(eachEventRela.Account.personContactId == eachEventRela.RelationId) eachEvent.addError(Label.Event_Validate_Contact);
		}
	}
	
	public static void notifyCreateCBSEvent(List<Event> insertedEvent) {
		Set<Id> newCSBEvent = new Set<Id>();
		newCSBEvent.add(GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_DEVNAME));
		newCSBEvent.add(GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME));
		
		Set<Id> ownerIdSet = new Set<Id>();
		for(Event eachEvent : insertedEvent){
			if(newCSBEvent.contains(eachEvent.RecordTypeId)){
				ownerIdSet.add(eachEvent.OwnerId);
			}
		}

		Map<Id, User> eventOwnerMapById = new Map<Id, User>([
			SELECT Id, FirstName, LastName, Team_Name__c, ManagerId
			FROM User
			WHERE Id IN :ownerIdSet
		]);

		for(Event eachEvent : insertedEvent){
			if(newCSBEvent.contains(eachEvent.RecordTypeId)){
				User owner = eventOwnerMapById.get(eachEvent.OwnerId);
				String comment;
				if(owner != null){
					if(owner.FirstName != null){
						comment = ' คุณ ' + owner.FirstName + ' ' + owner.LastName + ' ' + owner.Team_Name__c + ' ได้สร้าง Call Plan/ Call Report';
					}else {
						comment = ' คุณ ' + owner.LastName + ' ' + owner.Team_Name__c + ' ได้สร้าง Call Plan/ Call Report';
					}
					if(!Test.isRunningTest()){
						GlobalUtility.createBellNotification(owner.ManagerId, eachEvent.Id, comment);
					}
				}
			}
		}
	}

	public static void stampJobAndPlanDate(List<Event> afterEditEvent, Map<Id, Event> beforeEditEventMapById){
		for(Event eachEvent : afterEditEvent){
			Event beforeEdit;
			if(beforeeditEventMapbyId != null) 
				beforeEdit = beforeEditEventMapbyId.get(eachEvent.Id);

			if((beforeEdit == null || eachEvent.ActivityDateTime != beforeEdit.ActivityDateTime)
			&& (eachEvent.status__c == GlobalConstants.PLAN
			 || eachEvent.status__c == GlobalConstants.WAITING_FOR_APPROVAL 
			 || eachevent.status__c == GlobalConstants.APPROVED 
			 || (beforeeditEventMapbyId == null && eachEvent.status__c == GlobalConstants.PLAN)
			)
			){
				eachEvent.Plan_Date__c = eachevent.ActivityDateTime;
			}

			if(eachEvent.WhatId != null && eachEvent.WhatId.getSObjectType() == Opportunity.SObjectType){
				eachEvent.Job__c = eachEvent.WhatId;
			}
		}
	}

	public static void updateRecordTypeAndConvertDate(List<Event> afterUpdateEventList, Map<Id, Event> beforeUpdateEventMapById){
		String APPROVED 			= GlobalConstants.APPROVED;
		String CANCELLED 			= GlobalConstants.CANCELLED;
		String CONTACTED 			= GlobalConstants.CONTACTED;
		String PLAN 				= GlobalConstants.PLAN;
		String REJECTED				= GlobalConstants.REJECTED;
		String STATUS_CLOSED 		= GlobalConstants.STATUS_CLOSED;
		String WAITING_FOR_APPROVAL = GlobalConstants.WAITING_FOR_APPROVAL;

		Id SME_CALL_PLAN 						= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_DEVNAME);
		Id CBS_CALL_PLAN 						= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_DEVNAME);
		Id RBS_CALL_PLAN						= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_DEVNAME);
		Id SME_CALL_PLAN_CALL_REPORT_EDITABLE 	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME);
		Id CBS_CALL_PLAN_CALL_REPORT_EDITABLE	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME);
		Id RBS_CALL_PLAN_CALL_REPORT_EDITABLE	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_CALL_REPORT_EDITABLE_DEVNAME);
		Id SME_CALL_PLAN_READ_ONLY 				= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_READ_ONLY_DEVNAME);
		Id CBS_CALL_PLAN_READ_ONLY 				= GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_PLAN_READ_ONLY_DEVNAME);
		Id RBS_CALL_PLAN_READ_ONLY 				= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_READ_ONLY_DEVNAME);
		Id RBS_CALL_PLAN_FOR_APPROVE 			= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_FOR_APPROVE_DEVNAME);
		
		Set<Id> updatedEventOwnerIdSet = new Set<Id>();

		for(Event afterUpdateEvent : afterUpdateEventList){
			Event beforeUpdateEvent = beforeUpdateEventMapById.get(afterUpdateEvent.Id);
			if(
				(
					afterUpdateEvent.status__c != beforeUpdateEvent.status__c
					&& ( afterUpdateEvent.status__c == WAITING_FOR_APPROVAL 
						|| ( beforeUpdateEvent.status__c == WAITING_FOR_APPROVAL && afterUpdateEvent.status__c == PLAN)
					)
				)
				|| (beforeUpdateEvent.status__c == APPROVED && afterUpdateEvent.status__c == CANCELLED )
				|| (beforeUpdateEvent.ActivityDateTime != afterUpdateEvent.ActivityDateTime && afterUpdateEvent.status__c == APPROVED)
			){
				updatedEventOwnerIdSet.add(afterUpdateEvent.OwnerId);
			}
		}

		Map<Id, User> updatedEventOwnerMapById = new Map<Id, User>([
			SELECT Id, ManagerId, FirstName, LastName
			FROM User
			WHERE Id IN :updatedEventOwnerIdSet
		]);

		for(Event afterUpdateEvent : afterUpdateEventList){
			Event beforeUpdateEvent = beforeUpdateEventMapById.get(afterUpdateEvent.Id);
			if(afterUpdateEvent.status__c == CONTACTED){
				if(afterUpdateEvent.RecordTypeId == SME_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = SME_CALL_PLAN_CALL_REPORT_EDITABLE;
				}else if(afterUpdateEvent.RecordTypeId == CBS_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = CBS_CALL_PLAN_CALL_REPORT_EDITABLE;
				}else if(afterUpdateEvent.RecordTypeId == RBS_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN_CALL_REPORT_EDITABLE;
				}
				if(afterUpdateEvent.Converted_Date__c == NULL){
					afterUpdateEvent.Converted_Date__c = System.TODAY();
				}
			}else if(afterUpdateEvent.status__c == CANCELLED || afterUpdateEvent.status__c == STATUS_CLOSED){
				System.debug('it is cancel');
				System.debug(afterUpdateEvent.status__c);
				if(beforeUpdateEvent.status__c == APPROVED){
					User owner = updatedEventOwnerMapById.get(afterUpdateEvent.OwnerId);
					String comment = ' มีการยกเลิกหรือเปลี่ยนแปลงวันที่วางแผนเยี่ยมในแผนการเยี่ยมที่คุณอนุมัติแล้ว';
					if(!Test.isRunningTest() && owner != null){
						GlobalUtility.createBellNotification(owner.ManagerId, afterUpdateEvent.Id, comment);
					}
				}else if(afterUpdateEvent.RecordTypeId == SME_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = SME_CALL_PLAN_READ_ONLY;
				}else if(afterUpdateEvent.RecordTypeId == CBS_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = CBS_CALL_PLAN_READ_ONLY;
				}else if(afterUpdateEvent.RecordTypeId == RBS_CALL_PLAN){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN_READ_ONLY;
				}
			}else if(beforeUpdateEvent.ActivityDateTime != afterUpdateEvent.ActivityDateTime && afterUpdateEvent.status__c == APPROVED){
				User owner = updatedEventOwnerMapById.get(afterUpdateEvent.OwnerId);
				String comment = ' มีการยกเลิกหรือเปลี่ยนแปลงวันที่วางแผนเยี่ยมในแผนการเยี่ยมที่คุณอนุมัติแล้ว';
				if(!Test.isRunningTest() && owner != null){
					GlobalUtility.createBellNotification(owner.ManagerId, afterUpdateEvent.Id, comment);
				}
			}else if(beforeUpdateEvent.status__c != afterUpdateEvent.status__c){
				if(afterUpdateEvent.status__c == WAITING_FOR_APPROVAL){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN_FOR_APPROVE;
					User owner = updatedEventOwnerMapById.get(afterUpdateEvent.OwnerId);
					String comment;
					if(owner != null){
						if(owner.FirstName != null){
							comment = ' คุณ ' + owner.FirstName + ' ' + owner.LastName + ' ได้ขออนุมัติแผนการเยี่ยม';
						}else {
							comment = ' คุณ ' + owner.LastName + ' ได้ขออนุมัติแผนการเยี่ยม';
						}
						if(!Test.isRunningTest()){
							GlobalUtility.createBellNotification(owner.ManagerId, afterUpdateEvent.Id, comment);
						}
					}
				}else if(afterUpdateEvent.status__c == APPROVED){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN;
					String comment = ' แผนการเยี่ยมของคุณได้รับการอนุมัติแล้ว';
					if(!Test.isRunningTest()){
						GlobalUtility.createBellNotification(afterUpdateEvent.OwnerId, afterUpdateEvent.Id, comment);
					}
				}else if(beforeUpdateEvent.status__c == WAITING_FOR_APPROVAL && afterUpdateEvent.status__c == PLAN){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN;
					User owner = updatedEventOwnerMapById.get(afterUpdateEvent.OwnerId);
					String comment;
					if(owner != null){
						if(owner.FirstName != null){
							comment = ' คุณ ' + owner.FirstName + ' ' + owner.LastName + ' ได้เรียกคืนคำขออนุมัติแผนการเยี่ยม';
						}else {
							comment = ' คุณ ' + owner.LastName + ' ได้เรียกคืนคำขออนุมัติแผนการเยี่ยม';
						}
						if(!Test.isRunningTest()){
							GlobalUtility.createBellNotification(owner.ManagerId, afterUpdateEvent.Id, comment);
						}
					}
				}else if(afterUpdateEvent.status__c == REJECTED){
					afterUpdateEvent.RecordTypeId = RBS_CALL_PLAN_READ_ONLY;
					String comment = ' แผนการเยี่ยมของคุณถูกปฎิเสธ';
					if(!Test.isRunningTest()){
						GlobalUtility.createBellNotification(afterUpdateEvent.OwnerId, afterUpdateEvent.Id, comment);
					}
				}
			}
		}
	}

	public static void stampRecordTypeAndConvertDate(List<Event> afterInsertEventList){
		String CONTACTED 				= GlobalConstants.CONTACTED;
		Id SME_CALL_REPORT_SECONDARY 	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_SECONDARY_DEVNAME);
		Id SME_CALL_REPORT_WITHOUT_PLAN = GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME);
		Id CBS_CALL_REPORT_WITHOUT_PLAN = GlobalUtility.getRecordTypeId('Event', GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME);
		
		for(Event afterInsertEvent : afterInsertEventList){
			if(afterInsertEvent.status__c == CONTACTED ){
				if(afterInsertEvent.RecordTypeId == SME_CALL_REPORT_SECONDARY){
					afterInsertEvent.RecordTypeId = SME_CALL_REPORT_WITHOUT_PLAN;
				}
				if(afterInsertEvent.RecordTypeId == SME_CALL_REPORT_WITHOUT_PLAN || afterInsertEvent.RecordTypeId == CBS_CALL_REPORT_WITHOUT_PLAN){
					afterInsertEvent.Converted_Date__c = System.TODAY();
				}
			}
		}
	}

	public static void validateCreateEventPermission(List<Event> inputEventInfoList) {
		Id SME_CALL_PLAN 					= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_PLAN_DEVNAME);
		Id RBS_CALL_PLAN					= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_DEVNAME);
		Id SME_CALL_REPORT_WITHOUT_PLAN		= GlobalUtility.getRecordTypeId('Event', GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME);

		Set<Id> jobIdSet = new Set<Id>();

		for(Event inputEventInfo : inputEventInfoList) {
			jobIdSet.add(inputEventInfo.Job__c);
		}

		List<UserRecordAccess> userRecordAccessList = [SELECT RecordId, HasEditAccess
			FROM  UserRecordAccess
			WHERE UserId = :UserInfo.getUserId() AND RecordId IN :jobIdSet];
		System.debug(userRecordAccessList);

		Map<Id, UserRecordAccess> userRecordAccessMapByJobId = new Map<Id, UserRecordAccess>();
		for(UserRecordAccess eachRecordAccess : userRecordAccessList){
			userRecordAccessMapByJobId.put(eachRecordAccess.RecordId, eachRecordAccess);
		}

		for(Event inputEventInfo : inputEventInfoList) {
			if(userRecordAccessMapByJobId.containsKey(inputEventInfo.Job__c) && !userRecordAccessMapByJobId.get(inputEventInfo.Job__c).HasEditAccess
			&&( inputEventInfo.RecordTypeId == SME_CALL_PLAN
			|| inputEventInfo.RecordTypeId == RBS_CALL_PLAN
			|| inputEventInfo.RecordTypeId == SME_CALL_REPORT_WITHOUT_PLAN
			)){
				inputEventInfo.addError(Label.SMERBS_NotAllowCreateJobOnOthersEvent);
			}
		}

	}



	private static IEventService getUserManager(){
		return UserManager.getInstance();
	}
}