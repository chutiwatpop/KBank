global class CustomerSatisfactionFlagClear implements Database.Batchable<sObject> {
	
	String query;
	List<Database.SaveResult> results = null;
	
	global CustomerSatisfactionFlagClear() {
		query = 'SELECT Id, CIS__c, Temporary_Customer__c, Incorrect_Phone_Number__c, Incorrect_Contact_Name__pc  FROM Account WHERE  CreatedDate = LAST_YEAR ';
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		List<Account> accountToClear = New List<Account>();
		for (Account account : scope) {
            if (account.Incorrect_Phone_Number__c.toUpperCase() == 'DONE' || account.Incorrect_Contact_Name__pc.toUpperCase() == 'DONE') {
            	account.Incorrect_Phone_Number__c = '';
            	account.Incorrect_Contact_Name__pc = '';
                accountToClear.add(account);
            }
        }
        results = Database.update(accountToClear, false);
	}
	global void finish(Database.BatchableContext BC) {
		if(results != null && results.size() > 0){
			System.debug('CustomerSatisfaction flag has been cleared for {'+results.size()+'} records.');
		} else {
			System.debug('CustomerSatisfaction flag has not been cleared.');
		}
	}
}