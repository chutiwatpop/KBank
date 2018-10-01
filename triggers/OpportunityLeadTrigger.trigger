/**
* @author chutiwat.s@beryl8.com
* @30/09/2015 createddate
*/
trigger OpportunityLeadTrigger on Opportunity_Lead__c (before insert, before update) {
	new OpportunityLeadTriggerHandler().run();
}