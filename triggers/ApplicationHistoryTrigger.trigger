trigger ApplicationHistoryTrigger on Application_History__c (before insert, before update, after insert, after update) {
	if(!TriggerHandler.isBypassed('ApplicationHistoryTriggerHandler')){
    	new ApplicationHistoryTriggerHandler().run();
	}
}