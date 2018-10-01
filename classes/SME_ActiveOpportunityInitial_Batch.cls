/**
*@author pasakorn.p@beryl8.com
*@06/07/2016 created batch to set the Active_Opportunity__c field to have value
**/
global class SME_ActiveOpportunityInitial_Batch implements Database.Batchable<sObject>{
	String query;
	global SME_ActiveOpportunityInitial_Batch() {
		query = 'SELECT Id, AccountId, Active_Opportunity__c,StageName FROM Opportunity WHERE StageName != \''+GlobalConstants.DELETED_OPPORTUNITY+'\'';
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
		for(Opportunity eachOpportunity : opportunityList){
			eachOpportunity.Active_Opportunity__c = eachOpportunity.AccountId;
		}
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update opportunityList;
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
	}

	global void finish(Database.BatchableContext BC){

	}
}