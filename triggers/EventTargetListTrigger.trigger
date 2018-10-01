trigger EventTargetListTrigger on Event_Target_List__c (before insert, before update, before delete) {
	new EventTargetListTriggerHandler().run();
}