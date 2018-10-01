public with sharing class BulkAssignmentWrapper {
	
	public Bulk_Assignment__c bulkAssignment;
	public Boolean setShouldAssignedBulk;

	public BulkAssignmentWrapper(Bulk_Assignment__c bulkAssignment){
		this.setShouldAssignedBulk = false;
		this.bulkAssignment = bulkAssignment;
	}

	public void setShouldAssignedBulk(Boolean flag){
		this.setShouldAssignedBulk = flag;
	}
}