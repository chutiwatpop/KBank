public with sharing class CBS_CallPlanCallReport_Service {

	public static RecordType getRecordTypeById(Id recordTypeId){
		String getRecordTypeQuery = 'SELECT Id,'+
									'DeveloperName,'+
									'Name'+
									' FROM RecordType';
		String getRecordTypeCondition = ' WHERE SobjectType = \'Call_Report__c\''+
											' AND IsActive = true'+
											' AND Id =: recordTypeId'+
											' LIMIT 1';
		RecordType recordType = Database.query(getRecordTypeQuery + getRecordTypeCondition);
		System.debug('recordType >> ' + recordType);
		return recordType;				
	}
	public static GlobalUtility.databaseSaveResults insertNewCallReportOrUpdateCallPlanToCallReport(Call_Report__c callReport){
		GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database insertNewCallReportOrUpdateCallPlanToCallReport');

		Id callReportRecordTypeId = callReport.RecordTypeId;
		RecordType callReportRecordType = getRecordTypeById(callReportRecordTypeId);
		String callReportRecordTypeDevName = callReportRecordType.DeveloperName;
		boolean isClosedContactedCallReportEditableRecordType = callReportRecordTypeDevName.equalsIgnoreCase('CBS_Closed_Contacted_Call_Report_Editable');
		boolean isClosedContactedCallReportNoPlanEditableRecordType = callReportRecordTypeDevName.equalsIgnoreCase('CBS_Closed_Contacted_Call_Report_No_Plan_Editable');
		if(isClosedContactedCallReportEditableRecordType){
			//from callplan update callplan into callreport
			System.debug('insertNewCallReportOrUpdateCallPlanToCallReport update >>');
			Database.SaveResult updateCallReportSaveResults = Database.update(callReport,false);
			System.debug('updateCallReportSaveResults >> ' + updateCallReportSaveResults);
			if(updateCallReportSaveResults.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(updateCallReportSaveResults.getId(),updateCallReportSaveResults.isSuccess()));
			}else{
				for(Database.Error databaseError:updateCallReportSaveResults.getErrors()){
				saveResults.add(new GlobalUtility.databaseSaveResult(updateCallReportSaveResults.getId(),
					updateCallReportSaveResults.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));	
				}
			}
		}else if(isClosedContactedCallReportNoPlanEditableRecordType){
			//noplan insert new callreport
			Call_Report__c cloneWithOutIDCallReport = callReport.clone(false,true);
			System.debug('cloneWithOutIDCallReport >>' + cloneWithOutIDCallReport);
			System.debug('insertNewCallReportOrUpdateCallPlanToCallReport insert >>');
			Database.SaveResult insertCallReportSaveResults = Database.insert(cloneWithOutIDCallReport,false);
			System.debug('insertCallReportSaveResults >> ' + insertCallReportSaveResults);
			if(insertCallReportSaveResults.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(insertCallReportSaveResults.getId(),insertCallReportSaveResults.isSuccess()));
			}else{
				for(Database.Error databaseError:insertCallReportSaveResults.getErrors()){
					saveResults.add(new GlobalUtility.databaseSaveResult(insertCallReportSaveResults.getId(),
					insertCallReportSaveResults.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));	
				}
			}
		}
		return saveResults;
	}
	
	public static GlobalUtility.databaseSaveResults updateTargetList(List<Target_List__c>targetLists){
		GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database updateTargetList');
		List<Database.SaveResult> updateTargetListSaveResults = Database.update(targetLists,false);
		for(Database.SaveResult saveResult:updateTargetListSaveResults){
			if(saveResult.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),saveResult.isSuccess()));
			}else{
				for(Database.Error databaseError:saveResult.getErrors()){
					saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),
					saveResult.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));	
				}
			}
		}
		return saveResults;
	}
	public static GlobalUtility.databaseSaveResults updateCalLreportLead(List<Call_Report_Lead__c> callReportLeads){
		GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database updateCallReportLeads');
		List<Database.SaveResult> updateCallReportLeadsSaveResults = Database.update(callReportLeads,false);
		for(Database.SaveResult saveResult:updateCallReportLeadsSaveResults){
			if(saveResult.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),saveResult.isSuccess()));
			}else{
				for(Database.Error databaseError:saveResult.getErrors()){
					saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),
					saveResult.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));
				}
			}
		}
		return saveResults;
	}
	public static GlobalUtility.databaseSaveResults insertNewContacts(List<Contact> newContacts){
		GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database insertNewContacts');
		List<Database.SaveResult> insertNewContactsSaveResults = Database.insert(newContacts,false);
		for(Database.SaveResult saveResult:insertNewContactsSaveResults){
			if(saveResult.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),saveResult.isSuccess()));
			}else{
				for(Database.Error databaseError:saveResult.getErrors()){
					saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),
					saveResult.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));
				}
			}
		}
		return saveResults;
	}
	//public static GlobalUtility.databaseSaveResults updateExistingContacts(List<Contact> existingContacts){
	//	GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database insertNewContacts');
	//	List<Database.SaveResult> updateNewContactsSaveResults = Database.update(existingContacts,false);
	//	for(Database.SaveResult saveResult:updateNewContactsSaveResults){
	//		if(saveResult.isSuccess()){
	//			saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),saveResult.isSuccess()));
	//		}else{
	//			for(Database.Error databaseError:saveResult.getErrors()){
	//				saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),
	//				saveResult.isSuccess(),
	//				databaseError.getStatusCode(),
	//				databaseError.getMessage()
	//				));
	//			}
	//		}
	//	}
	//	return saveResults;
	//}
	public static GlobalUtility.databaseSaveResults insertCallReportContacts(List<Call_Report_Contact__c> allContacts){
		GlobalUtility.databaseSaveResults saveResults = new GlobalUtility.databaseSaveResults('Database insertCallReportContacts');
		List<Database.SaveResult> insertCallReportContactsSaveResults = Database.insert(allContacts,false);
		for(Database.SaveResult saveResult:insertCallReportContactsSaveResults){
			if(saveResult.isSuccess()){
				saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),saveResult.isSuccess()));
			}else{
				for(Database.Error databaseError:saveResult.getErrors()){
					saveResults.add(new GlobalUtility.databaseSaveResult(saveResult.getId(),
					saveResult.isSuccess(),
					databaseError.getStatusCode(),
					databaseError.getMessage()
					));
				}
			}
		}
		return saveResults;
	}
	public static List<RecordType> getCallplanCallReportRecordTypes(){
		Set<String> callPlancallReportDevNames = new Set<String>{'CBS_Call_Plan',
                                                                'CBS_Call_Report',
                                                                'CBS_Call_Report_No_Plan',
                                                                'CBS_Closed_Contacted_Call_Report_No_Plan_Editable',
                                                                'CBS_Closed_Contacted_Call_Report_Editable'};
        String recordTypeQuery = 'SELECT Id,'+
                                'DeveloperName,'+
                                'Name,'+
                                'SobjectType'+
                                ' FROM RecordType';
        String recordTypeCondition = ' WHERE SobjectType = \'Call_Report__c\' AND DeveloperName IN: callPlancallReportDevNames';
        List<RecordType> recTypes = Database.query(recordTypeQuery + recordTypeCondition);
        if(recTypes.isEmpty()){
			return new List<RecordType>();
		}else{
			return recTypes;
		}
	}
	public static List<Call_Report__c> fetchCallPlan(String myCallReportId,String callPlanRecordTypeId){
		String fetchCallPlanQuery = 'SELECT Id,'+
                                        'CIS_ID__c,'+
                                        'RecordTypeId,'+
                                        'Status__c,'+
                                        'CIS_ID__r.Name,'+
                                        'Customer_Important_Note_CBS__c,'+
                                        'Plan_Date__c,'+
                                        'Visit_Objective_CBS__c,'+
                                        'Product_Service__c,'+
                                        'Note_CBS__c,'+
                                        'Actual_Visit_Date__c,'+
                                        'Contact_Channel__c,'+
                                        'Planned_Product_CBS__c,'+
                                        'Planned_Visit_Objective_CBS__c,'+
                                        'Next_Step_CBS__c,'+
                                        'Next_Follow_up_Date_CBS__c'+
                                        ' FROM Call_Report__c';
        String fetchCallPlanCondition = ' WHERE Id = \'' + myCallReportId +'\''+
                                        ' AND RecordTypeId =: callPlanRecordTypeId'+
                                        ' LIMIT 1';
        List<Call_Report__c> callPlans = Database.query(fetchCallPlanQuery + fetchCallPlanCondition);
        if(callPlans.isEmpty()){
        	return new List<Call_Report__c>();
    	}else{	
    		return callPlans;
    	}
	}
	public static Contact getContact(String contactId){
		String fetchContactQuery = 'SELECT Id,'+
                                            'Name,'+
                                            'Contact_Position__c,'+
                                            'Contact_Representative_Type__c,'+
                                            'Phone_Number__c,'+
                                            'Ext_CBS__c,'+
                                            'Title,'+
                                            'Business_Email__c '+
                                            'FROM Contact ';
    	String fetchContactCondition = ' WHERE ID = \''+ contactId + '\'';
    	List<Contact> fetchContact = Database.query(fetchContactQuery+fetchContactCondition);
    	if(fetchContact.isEmpty()){
    		return new Contact(id = contactId);
		}else{
			return fetchContact[0];
		}
	}
	public static List<Campaign> getCampaigns(Set<String> leadCampaignIDs){
		String fetchLeadCampaignsQuery = 'SELECT Id,'+
                                            'Name,'+
                                            'Type,'+
                                            'Product_List_CBS__c,'+
                                            'Sub_Type_CBS__c'+
                                            ' FROM Campaign';
        String fetchLeadCampaignsCondition = ' WHERE Id IN: leadCampaignIDs';
        List<Campaign> fetchLeadCampaigns = Database.query(fetchLeadCampaignsQuery+fetchLeadCampaignsCondition);
        if(fetchLeadCampaigns.isEmpty()){
        	return new List<Campaign>();
    	}else{
    		return fetchLeadCampaigns;
    	}	
	}
	public static List<Lead_To_Do_Response__c> getLeadToDoResponses(Set<string> leadSubtypes){
		String fetchLeadToResponseQuery = 'SELECT Id,'+
                                            'Response_Level_1__c,'+
                                            'Response_Level_2__c,'+
                                            'Required_Level_2__c,'+
                                            'Required_Memo__c,'+
                                            'Required_Product_c__c,'+
                                            'Type__c'+
                                            ' FROM Lead_To_Do_Response__c';
        String fetchLeadToResponseCondition = ' WHERE Type__c IN: leadSubtypes AND Team__c = '+'\'CBS\'';
        List<Lead_To_Do_Response__c> fetchLeadToResponses = Database.query(fetchLeadToResponseQuery + fetchLeadToResponseCondition);
        if(fetchLeadToResponses.isEmpty()){
        	return new List<Lead_To_Do_Response__c>();
    	}else{
    		return fetchLeadToResponses;
    	}
	}
	public static Map<Id,Contact> getSavedContactMap(Set<Id> contactIdsToInsertCallReportContacts){
		String query = 'SELECT Id,Phone_Number__c,Business_Email__c FROM Contact';
		String condition = ' WHERE Id IN: contactIdsToInsertCallReportContacts';
		List<Contact> savedContacts = Database.query(query + condition);
		if(savedContacts.isEmpty()){
			return new Map<Id,Contact>();
		}else{
			Map<Id,Contact> savedContactsMap = new Map<Id,Contact>();
	        for(Contact savedContact:savedContacts){
	            savedContactsMap.put(savedContact.Id,savedContact);
	        }
	        return savedContactsMap;
		}	
	}
	public static List<Call_Report_Lead__c> getCallReportLeads(String myCallReportId){
		String query = 'SELECT Id,Target_List__c FROM Call_Report_Lead__c';
		String condition = ' WHERE Call_Plan_Call_Report__c =: myCallReportId';
		List<Call_Report_Lead__c> queryCallReportLeads = Database.query(query + condition);
		if(queryCallReportLeads.isEmpty()){
			return new List<Call_Report_Lead__c>();
		}else{
			return queryCallReportLeads;
		}	
	}
}