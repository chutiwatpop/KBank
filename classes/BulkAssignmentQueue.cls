public with sharing class BulkAssignmentQueue {
	Bulk_Assignment_Queue__c bulkAssignmentQueue;
	public BulkAssignmentQueue() {}

	public void newBulkAssignmentQueue(){
		this.bulkAssignmentQueue = new Bulk_Assignment_Queue__c();
		bulkAssignmentQueue.Status__c = 'Create';
		bulkAssignmentQueue.StartTime__c = System.now();
		insert bulkAssignmentQueue;

	}
	public void setBulkAssignmentQueueStatus(Bulk_Assignment_Queue__c bulkAssignmentQueue, String status){
		bulkAssignmentQueue.Status__c = status;
	}

	public void updateBulkAssignmentQueue(){
		update this.bulkAssignmentQueue;
	}
}