global class PurgeTempLeadMlp_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global PurgeTempLeadMlp_Batch() {
		query = 'SELECT Id FROM Lead_MLP__c WHERE LastModifiedDate < LAST_N_DAYS:'+Label.Purge_Lead_MLP;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Lead_MLP__c> listLeadMLP) {
		delete listLeadMLP;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}