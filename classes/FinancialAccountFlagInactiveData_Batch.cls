global class FinancialAccountFlagInactiveData_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global FinancialAccountFlagInactiveData_Batch() {
		this.query = 'SELECT IsActive__c,Id FROM FinServ__FinancialAccount__c WHERE IsActive__c = true AND  LastModifiedDate !=TODAY ORDER BY FinServ__PrimaryOwner__r.CIS__c';
	}
	global FinancialAccountFlagInactiveData_Batch(String conditionDate) {
		this.query = 'SELECT IsActive__c,Id FROM FinServ__FinancialAccount__c WHERE IsActive__c = true AND DAY_ONLY(CreatedDate)='+conditionDate +' ORDER BY FinServ__PrimaryOwner__r.CIS__c';
	}	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<FinServ__FinancialAccount__c> financialAccountList) {
		for(FinServ__FinancialAccount__c eachFinAccount : financialAccountList){
			eachFinAccount.IsActive__c = false;
		}
		TriggerHandler.bypass('AccountTriggerHandler');
		Database.update(financialAccountList);
		TriggerHandler.clearBypass('AccountTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}