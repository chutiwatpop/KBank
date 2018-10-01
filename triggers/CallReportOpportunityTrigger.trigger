/**
* @author komsan.wi@beryl8.com
* @30/09/2015 created new
*/
trigger CallReportOpportunityTrigger on Call_Report_Opportunity__c(after insert, after delete) {
	new CallReportOpportunityTriggerHandler().run(); 
}