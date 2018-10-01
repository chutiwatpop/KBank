global class FlagInactiveAccount_Batch implements Database.Batchable<sObject> {
	
	String query;
	
    global FlagInactiveAccount_Batch() {
		Datetime expiredDate = Date.today();
		expiredDate = expiredDate.addDays(-7);
		this.query = 'SELECT Id, IsActive__c, LastModifiedDate FROM Account WHERE LastModifiedDate < LAST_N_DAYS:7 AND IsActive__c = TRUE';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		List<Account> inactivedAccountLists = new List<Account>();

		for(Account eachAccount : scope) {
			eachAccount.IsActive__c = false;
			inactivedAccountLists.add(eachAccount);
		}
		TriggerHandler.bypass('AccountTriggerHandler');
			Database.update(inactivedAccountLists);
		TriggerHandler.clearBypass('AccountTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}