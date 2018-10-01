trigger TransactTrigger on TransactBP__c (before insert, before update, after insert, after update) {
	if(!TriggerHandler.isBypassed('TransactTriggerHandler')){
    	new TransactTriggerHandler().run();
	}
}