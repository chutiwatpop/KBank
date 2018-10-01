global class CustomerSatisfactionFlagClear_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global CustomerSatisfactionFlagClear_Batch() {
		query = 'SELECT Id, CIS__c, Temporary_Customer__c, Incorrect_Phone_Number__c, Incorrect_name__c  FROM Account WHERE Incorrect_Phone_Number__c != \'\' or Incorrect_name__c != \'\' ';
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		List<Account> accountToClear = New List<Account>();
		for (Account account : scope) {
			if(account != null){
	            if (account.Incorrect_Phone_Number__c != null){
	            	account.Incorrect_Phone_Number__c = null;
	            }
	            if(account.Incorrect_name__c != null) {
	            	account.Incorrect_name__c = null;
	            }
	            accountToClear.add(account);
	        }
        }
        	List<Database.SaveResult> results = Database.update(accountToClear, false);
       if(results != null && results.size() > 0){
			System.debug('CustomerSatisfaction flag has been cleared for {'+results.size()+'} records.');
		} else {
			System.debug('CustomerSatisfaction flag has not been cleared.');
		}
	}
	global void finish(Database.BatchableContext BC) {
		
	}
}