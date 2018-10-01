/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
trigger BulkAssignmentQueueTrigger on Bulk_Assignment_Queue__c (before update,before insert,after insert,after update) {
	new BulkAssignmentQueueTriggerHandler().run();
}