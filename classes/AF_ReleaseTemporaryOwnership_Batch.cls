global class AF_ReleaseTemporaryOwnership_Batch implements Database.Batchable<sObject> {
    String query = 'SELECT Name,AF_Temporary_Customer__c, Customer_Owner_Release_Flag__c, AF_Last_CallReprt_Opty_Updated_Date__c FROM Account WHERE AF_Temporary_Customer__c != null AND AF_Last_CallReprt_Opty_Updated_Date__c != null';
	String limitOfReleaseOwnership = Label.AF_Release_Temporary_Customer;

	global AF_ReleaseTemporaryOwnership_Batch() {
		
	}
	
	global AF_ReleaseTemporaryOwnership_Batch(List<Id> accountId){
        String queryJoinSet = String.join(accountId,'\',\'');
        this.query =    query   + ' AND Id IN (\''+queryJoinSet+'\')';
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accountList) {
		Map<Id, Account> accountToUpdate = new Map<Id, Account>();
		Date accountLastCallOpptyDate;
        Date today = System.today();
        Integer dateDifference = 0;
        for(Account account: accountList){
            	accountLastCallOpptyDate = Date.newInstance(account.AF_Last_CallReprt_Opty_Updated_Date__c.year(), account.AF_Last_CallReprt_Opty_Updated_Date__c.month(), account.AF_Last_CallReprt_Opty_Updated_Date__c.day());
                dateDifference = accountLastCallOpptyDate.daysBetween(today);
            	if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership)){
            		Account eachAccountToUpdate = new Account();
            		eachAccountToUpdate.Id = account.Id;
            		eachAccountToUpdate.AF_Temporary_Customer__c = null;
            		eachAccountToUpdate.Customer_Owner_Release_Flag__c = true;
                    accountToUpdate.put(eachAccountToUpdate.Id, eachAccountToUpdate);
                }
            
        }

        System.debug('accountToUpdate = '+accountToUpdate);
        update accountToUpdate.values();
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}