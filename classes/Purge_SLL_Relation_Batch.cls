global class Purge_SLL_Relation_Batch implements Database.Batchable<sObject>, Database.Stateful{

	String query;
	Boolean isOneTime = false;

	global Purge_SLL_Relation_Batch(Boolean isOneTime){
		this.isOneTime = isOneTime;
	}

	global Purge_SLL_Relation_Batch(){
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id FROM SLL_Relation__c ';
		if(!isOneTime){
			query = query + 'WHERE Subject_Relation_Code__c NOT IN (\'302\', \'305\', \'C05\', \'C01\', \'301\', \'306\', \'303\') AND Object_Relation_Code__c NOT IN (\'302\', \'305\', \'C05\', \'C01\', \'301\', \'306\', \'303\')';
		}

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SLL_Relation__c> listTempSLL) {
		delete listTempSLL;
	}

	global void finish(Database.BatchableContext BC) {}
}