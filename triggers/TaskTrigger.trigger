/**
* @author pasakorn.p@beryl8.com
* @14/09/2016 createddate
*/
trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update) {
	if(!TriggerHandler.isBypassed('TaskTriggerHandler')){
		new TaskTriggerHandler().run();
	}
}