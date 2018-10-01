global class CMAS_DIHData_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	String query;
	
	global CMAS_DIHData_Batch() {
		query = 'SELECT Id,CMAS_Status__c,App_Num_CMAS__c,CWU_Number__c  FROM Application_History__c WHERE OppName__r.RecordType.DeveloperName = \'Job\' AND CMAS_Status__c !=\'Completed\' AND RMSubmitChannel__c =\'CMAS\' AND IS_Create_By_Integration__c = false AND CWU_Number__c != NULL';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Application_History__c> appList) {
		for(Application_History__c eachApp : appList){
			if(eachApp.CWU_Number__c  !=NULL){
				String requestStr = eachApp.CWU_Number__c;
				HTTPResponse resp = SME_HTTPCallUtil.sendHttpCallout(SME_CIRestWebservice.CALLOUT_URL+'UpsertCMASById',requestStr);
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}