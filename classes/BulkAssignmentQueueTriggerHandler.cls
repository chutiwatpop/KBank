public class BulkAssignmentQueueTriggerHandler extends TriggerHandler {
	
	public override void afterUpdate(){
		List<Bulk_Assignment_Queue__c> tempBulkAssignmentQueueList = Trigger.new;
		if(tempBulkAssignmentQueueList.get(0).Status__c == 'Execute'){
			System.enqueueJob(new OwnershipAssignment_Queue((List<Bulk_Assignment_Queue__c>)Trigger.new ));
		}
	}
}