global class SME_InitailAccountOwnerProfileTextBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global SME_InitailAccountOwnerProfileTextBatch() {
		query = 'SELECT Id,Owner_Profile__c,Owner.Profile.Name FROM Account';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> listAccount) {
		for(Account eachAccount : listAccount){
			eachAccount.Owner_Profile__c = eachAccount.Owner.Profile.Name;
		}

		TriggerHandler.bypass('AccountTriggerHandler');
		update listAccount;
		TriggerHandler.clearbypass('AccountTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}