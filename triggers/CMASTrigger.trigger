/**
* @author chansak.s@beryl8.com
* @16/10/2017 createddate
*/
trigger CMASTrigger on CMAS__c (before insert,before update,after insert,after update, before delete) {
	if(!system.isBatch() && !system.isFuture())
		new CMASTriggerHandler().run();
}