trigger CallReportLeadTrigger on Call_Report_Lead__c (after insert, after update, after delete) {
	new CallReportLeadTriggerHandler().run();
}