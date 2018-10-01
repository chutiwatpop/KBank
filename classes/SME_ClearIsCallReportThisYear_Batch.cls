global class SME_ClearIsCallReportThisYear_Batch implements Database.Batchable<sObject> {

	String query;

	global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Is_Call_Report_This_Year__c, Actual_Visit_Date__c FROM Call_Report__c WHERE Is_Call_Report_This_Year__c = true AND Actual_Visit_Date__c != THIS_YEAR AND Actual_Visit_Date__c != null';
        return Database.getQueryLocator(query);
    }

	global void execute(Database.BatchableContext BC, List<Call_Report__c> callReportList) {
		System.debug('callRepList : '+callReportList);
        List<Call_Report__c> callReportToUpdate = new List<Call_Report__c>();
        for(Call_Report__c eachCallReport : callReportList){
			eachCallReport.Is_Call_Report_This_Year__c = false;
			callReportToUpdate.add(eachCallReport);
		}
		TriggerHandler.bypass('CallReportTriggerHandler');
			update callReportToUpdate;
		TriggerHandler.clearBypass('CallReportTriggerHandler');
	}

	global void finish(Database.BatchableContext BC){

    }
}