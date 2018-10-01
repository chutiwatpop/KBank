global class Purge_Household_Batch implements Database.Batchable<sObject>, Database.Stateful {
	String query;
	global Purge_Household_Batch(){}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id FROM Account WHERE RecordType.DeveloperName = \''+GlobalConstants.INDUSTRIESHOUSEHOLD_DEVNAME+'\'';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> listAccHousehold) {
		delete listAccHousehold;
	}

	global void finish(Database.BatchableContext BC) {}
}