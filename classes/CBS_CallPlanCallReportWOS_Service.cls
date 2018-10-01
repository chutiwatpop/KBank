public without sharing class CBS_CallPlanCallReportWOS_Service {

	private static Set<String> targetListsLeadTypes = new Set<String>{'Lead for Sales','Lead for Action with customer','Lead for Feedback'};

	public static List<Opportunity_Planning__c> getOpportunityPlannings(Id myCallReportCISID){
		Set<String> invalidStatuses = new Set<String>{'Win/Mandate','Lost','Cancelled by Customer','Rejected by KBank','Not Interested'};
		String fetchOppPlanningsQuery = 'SELECT Id,'+
										'Expected_LimitVolume_Amount__c,'+
										'Expected_Income_to_KBank__c,'+
										'Project_Size__c,'+
										'Product_Type__c,'+
										'Add_to_Existing_Opportunity__c,'+
										'Add_to_Existing_Opportunity_CallReport__c,'+
										'Add_to_Existing_Opportunity_CallReport__r.Name,'+
										'Status__c,'+
										'Remark__c,'+
										'CIS_ID__c,'+
										'Customer_Interested__c,'+
										'Original_Call_Report__c,'+
										'Call_Report_CBS__c,'+
										'New_Limit__c, '+
										'Volume_Outstanding__c, '+
										'Front_End_Fee__c, '+
										'Fee__c, '+
										'(SELECT Product_Name__c,Call_Report_Product_List_Master__r.Product_Group__c,Call_Report_Product_List_Master__r.Name From Opportunity_Planning_Line_Items__r) '+
										'FROM Opportunity_Planning__c ';
		String fetchOppPlanningsCondition = ' WHERE CIS_ID__c = \''+ myCallReportCISID + '\'' +
		' AND Status__c NOT IN: invalidStatuses';
		List<Opportunity_Planning__c> fetchOppPlannings = Database.query(fetchOppPlanningsQuery+fetchOppPlanningsCondition);
		return fetchOppPlannings;
	}

	public static List<Target_List__c> fetchTargetLists(String accountId){
		Recordtype CBSLeadRecordType = [SELECT DeveloperName,Id,Name FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'CBS_Lead'];
		String fetchTargetListsQuery = 'SELECT Id,'+
										'Name,'+
										'Lead_Campaign__r.Sub_Type_CBS__c,'+
										'Lead_Campaign__r.Name,'+
										'Priority__c,'+
										'Status__c,'+
										'Personalised_Message__c,'+
										'Lead_Subtype_CBS__c,'+
										'Start_Date__c,'+
										'End_Date__c,'+
										'Response_Level_1__c,'+
										'Response_Level_2__c,'+
										'Memo__c,'+
										'Lead_Campaign__c,'+
										'Lead_Type__c'+
										' FROM Target_List__c';
		String fetchTargetListsCondition = ' WHERE CIS_ID_Prospect_Name__c = \''+ accountId +'\''+
		' AND Lead_Campaign__r.IsActive = true'+
		' AND Lead_Campaign__r.recordTypeId = \'' + CBSLeadRecordType.Id +'\''+
		' AND Active_Target_List__c != null'+
		' AND Lead_Type__c IN: targetListsLeadTypes';
		List<Target_List__c> fetchTargetLists = Database.query(fetchTargetListsQuery+fetchTargetListsCondition);
		return fetchTargetLists;
	}
}