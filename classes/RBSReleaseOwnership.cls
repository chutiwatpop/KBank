public with sharing class RBSReleaseOwnership implements IReleaseOwnership {
	public static Boolean isExistedRequest(Account accountObj, User currentUser) {
		Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_RELEASE_RBS_DEVNAME);
        List<Customer_Ownership_Request__c> existedRequest = [SELECT Id, CIS_ID__c, RecordType.DeveloperName FROM Customer_Ownership_Request__c 
        	WHERE CIS_ID__c = :accountObj.Id AND OwnerID = :currentUser.Id AND (Approval_Status__c = :GlobalConstants.APPROVAL_IN_PROGRESS OR Approval_Status__c = :GlobalConstants.STATUS_OPEN) LIMIT 1];
        return (existedRequest.size() > 0);
    }

	public void validateCustomer(Account accountObj, User currentUser) {
        if(accountObj.RBS_Branch_Closeness__r.RC_Code__c != currentUser.RC_Code__c) {
            throw new OwnershipException(Label.RBS_CantReleaseOthersClosenessBranch);
        } else if(accountObj.RBS_Previous_Branch_Closeness__c == null) {
        	throw new OwnershipException(Label.RBS_ClosenessBranchCantBeReleasetoEmpty);
        } else if(isExistedRequest(accountObj, currentUser)) {
        	throw new OwnershipException(Label.RBS_Request_Release_already_in_process);
        }
	}

	public Customer_Ownership_Request__c createCustomerOwnershipRequest(Account accountObj, User currentUser) {
		Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_RELEASE_RBS_DEVNAME);
		Customer_Ownership_Request__c ownershipRequest = new Customer_Ownership_Request__c(
			User_Admin__c	= UserManager.getUserAdmin().RBS_User_ID__c,
			Request_Type__c = GlobalConstants.BRANCH_CLOSENESS_RELEASE,
			CIS_ID__c		= accountObj.Id,
			OwnerID 		= currentUser.Id,
			RecordTypeId	= recordTypeId,
			Requestor__c	= currentUser.Id,
			Requestor_TM__c	= currentUser.Id,
			Approver__c 	= accountObj.RBS_Previous_Branch_Closeness__r.OwnerId,
			Approver_Branch__c = accountObj.RBS_Previous_Branch_Closeness__c
		);
		return ownershipRequest;
	}

	public static Account approveRequest(Customer_Ownership_Request__c eachRequest, Account accountObj) {
		Account updatedAccount = new Account(
			Id = accountObj.Id,
			RBS_Branch_Closeness__c = eachRequest.Approver_Branch__c,
			RBS_Previous_Branch_Closeness__c = accountObj.RBS_Branch_Closeness__c
		);
		return updatedAccount;
	}
}