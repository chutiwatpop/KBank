public class CalculateOwnershipAssignment_Queue implements Queueable {
	public List<Bulk_Assignment__c> bulkAssignList;
	public boolean needToCreateQueue;

	public CalculateOwnershipAssignment_Queue(List<Bulk_Assignment__c> bulkAssignList) {
		this.bulkAssignList = bulkAssignList;
	}

	public CalculateOwnershipAssignment_Queue(List<Bulk_Assignment__c> bulkAssignList, Boolean needToCreateQueue) {
		this.bulkAssignList = bulkAssignList;
		this.needToCreateQueue = needToCreateQueue;
	}

	public void execute(QueueableContext context) {
		Account_Service.resetAllFlagOwnership();
		Account_Service.isBulk = true;
		//Account_Service.callingFromCalculateBatch = true;
		if(bulkAssignList != null && !bulkAssignList.isEmpty()) {
			if(needToCreateQueue != null && needToCreateQueue) {
				Bulk_Assignment_Queue__c bulkQueue = new Bulk_Assignment_Queue__c();
		        bulkQueue.Status__c = 'Create';
		        bulkQueue.StartTime__c = System.now();
		        insert bulkQueue;

				for(Bulk_Assignment__c eachAssign : bulkAssignList) {
					eachAssign.BulkAssignmentQueue__c = bulkQueue.Id;
					eachAssign.Process__c = true;
					eachAssign.Status__c = GlobalConstants.STATUS_NEW;
				}
				insert bulkAssignList;
			}
			SME_BulkAssignment_Service.bulkAssignment(bulkAssignList);
		}
	}
}