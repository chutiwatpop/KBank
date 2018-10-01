global class Purge_Account_Contact_Rel_Batch implements Database.Batchable<sObject>, Database.Stateful {
	String query;
	String overrideQuery;
	Boolean isOneTime = false;
	global Purge_Account_Contact_Rel_Batch(){
	}

	global Purge_Account_Contact_Rel_Batch(Boolean isOneTime){
		this.isOneTime = isOneTime;
	}

	global Purge_Account_Contact_Rel_Batch(String overrideQuery){
		this.overrideQuery = overrideQuery;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id FROM AccountContactRelation WHERE IsDirect = false AND Account.RecordType.DeveloperName != \''+GlobalConstants.INDUSTRIESHOUSEHOLD_DEVNAME+'\'';
		if(!isOneTime){
			query = query + ' And Is_Createby_Integration__c = true';
		}

		if(!String.isBlank(overrideQuery)) query = overrideQuery;
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<AccountContactRelation > listAccConRel) {
		delete listAccConRel;
	}

	global void finish(Database.BatchableContext BC) {
		if(isOneTime){
			Database.executeBatch(new Purge_Household_Batch());
		}
	}
}