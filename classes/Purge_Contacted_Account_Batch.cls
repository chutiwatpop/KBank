global class Purge_Contacted_Account_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global Purge_Contacted_Account_Batch() {
		query = 'SELECT Id FROM Contacted_Account__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contacted_Account__c> listContactedAccount) {
		delete listContactedAccount;
	}
	
	global void finish(Database.BatchableContext BC) {
		if(!Test.isRunningTest()){
			Database.executeBatch(new SME_Initial_ContactedAccount_Batch());
		}
	}
	
}