trigger TargetListTrigger on Target_List__c (before insert, before update, after insert, after update, before delete) {
	if(!TriggerHandler.isBypassed('TargetListTriggerHandler')){
    	new TargetListTriggerHandler().run();
	}
}