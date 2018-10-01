trigger CallReportTrigger on Call_Report__c (before insert,before update,after insert,after update) {
	if(!TriggerHandler.isBypassed('CallReportTriggerHandler')){
    	new CallReportTriggerHandler().run(); 
	}
}