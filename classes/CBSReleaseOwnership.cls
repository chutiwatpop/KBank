public with sharing class CBSReleaseOwnership implements IReleaseOwnership {
	public void validateCustomer(Account accountObj, User currentUser) {
		if(currentUser.Id != accountObj.OwnerId) {
			throw new OwnershipException(ExceptionMessage.CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP);
		}

		/* CBS bulk assignment is canceled
		Integer countBulkAssignment = [SELECT Count() FROM Bulk_Assignment__c WHERE CIS_ID__c = :accountObj.Id AND Status__c IN ('Waiting for Approval','New','Processing') LIMIT 1];
        if(countBulkAssignment > 0) {
            throw new ReleaseOwnershipService.OwnershipException('This Customer already submitted for Bulk Assignment, cannot release');
        }*/
	}
}