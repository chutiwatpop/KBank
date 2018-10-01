trigger BulkAssignmentTrigger on Bulk_Assignment__c (before insert,after insert,before update,after update){
	new BulkAssignmentTriggerHandler().run();
}