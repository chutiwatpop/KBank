public without sharing class RBSRequestOwnership implements IRequestOwnership {
	public void validateCustomer(Account accountObj, User currentUser) {
		if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
			throw new OwnershipException('ไม่สามารถขอสาขาคนสนิทได้ เนื่องจากเป็นลูกค้า  Prospect');
		} else if(accountObj.RBS_Branch_Closeness__r.RC_Code__c == currentUser.RC_Code__c) {
            throw new OwnershipException(Label.RBS_YourBranchisAlreadytheClosenessBranch);
        }
	}

	public void validateExistingRequest(Account accountObj, User currentUser) {
        List<Customer_Ownership_Request__c> ownershipRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountObj.Id AND OwnerID=:currentUser.Id AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') LIMIT 1];
        Boolean isExisted = (ownershipRequest == null || ownershipRequest.size() == 0) ? false : true;
        if(isExisted) {
            throw new OwnershipException(Label.RBS_Request_Release_already_in_process);
        }
    }

	public Customer_Ownership_Request__c createCustomerOwnershipRequest(Account accountObj, User currentUser) {
		Customer_Ownership_Request__c requestObj;
		if(accountObj.RBS_Branch_Closeness__c == null) {
			updateClosenessBranch(accountObj, currentUser);
		} else {
	        UserApproverModel currentUserWrapper = UserApproverModel.getUserApproverHierachy(currentUser);

			Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_RBS_DEVNAME);
	        requestObj = new Customer_Ownership_Request__c(
	        	User_Admin__c    = UserManager.getUserAdmin().RBS_User_ID__c,
	        	Request_Type__c  = GlobalConstants.BRANCH_CLOSENESS_REQUEST,
	            CIS_ID__c        = accountObj.Id,
	            OwnerID          = currentUser.Id,
	            Requestor__c	 = currentUser.Id,
	            Requestor_TM__c  = currentUserWrapper.getApproverIdFromProfile( new Set<String>{GlobalConstants.RBS_TM}),
	            RecordTypeId     = recordTypeId,
	            Approver__c      = accountObj.RBS_Branch_Closeness__r.OwnerId,
	            Approver_Branch__c = accountObj.RBS_Branch_Closeness__c
	    	);
		}
			
		return requestObj;
	}

	public void updateClosenessBranch(Account accountObj, User currentUser){
		Team_Structure__c currentUserBranch = (new TeamStructureSelector()).selectByRCCode(currentUser.RC_Code__c);
		accountObj.RBS_Branch_Closeness__c 			= currentUserBranch != null ? currentUserBranch.Id : null;
		accountObj.RBS_Previous_Branch_Closeness__c = null;
        TriggerHandler.bypass('AccountTriggerHandler');
        update accountObj;
        TriggerHandler.clearBypass('AccountTriggerHandler');
	}

	public static Account approveRequest(Customer_Ownership_Request__c eachRequest, Account accountObj, Team_Structure__c currentUserTeam) {
		Account updatedAccount = new Account(
			Id = accountObj.Id,
			RBS_Branch_Closeness__c = currentUserTeam.Id,
			RBS_Previous_Branch_Closeness__c = eachRequest.Approver_Branch__c
		);
		return updatedAccount;
	}
}