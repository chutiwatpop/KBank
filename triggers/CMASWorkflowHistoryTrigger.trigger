/**
* @author chansak.s@beryl8.com
*/
trigger CMASWorkflowHistoryTrigger on CMAS_Workflow_History__c (before update,before insert,after insert,after update) {
	if(!TriggerHandler.isBypassed('CMASWorkflowHistoryTriggerHandler')){
		new CMASWorkflowHistoryTriggerHandler().run();
	}
}