public with sharing class CBSRequestOwnership implements IRequestOwnership {
	public void validateCustomer(Account accountObj, User currentUser) {
        Boolean isSuccess = true;
        if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME) {
            if((!GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) &&
            	(!GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c))) {
            	isSuccess = false;
            }
        } else {
            isSuccess = false;
        }

        if(!isSuccess) {
        	throw new OwnershipException(Label.Request_Ownership_Error_Customer);
        }
	}

    public void validateExistingOpportunityRequest(Account accountObj) {
        List<Opportunity_Request_for_Approval__c> existingOpportunityApproval = [SELECT Id, Opportunity__r.AccountId, Approval_Status__c FROM Opportunity_Request_for_Approval__c WHERE Opportunity__r.AccountId = :accountObj.Id AND (Approval_Status__c=:GlobalConstants.APPROVAL_IN_PROGRESS OR Approval_Status__c=:GlobalConstants.STATUS_OPEN)];
        Boolean isExisted = existingOpportunityApproval == null || existingOpportunityApproval.size() == 0 ? false : true;
        if(isExisted) {
            throw new OwnershipException(Label.Request_Ownership_Error_Opp_Pending);
        }
    }

    public void validateExistingRequest(Account accountObj, User currentUser) {
        List<Customer_Ownership_Request__c> ownershipRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountObj.Id AND OwnerId = :currentUser.Id AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') LIMIT 1];
        Boolean isExisted = ownershipRequest == null || ownershipRequest.size() == 0 ? false : true;
        if(isExisted) {
            throw new OwnershipException('This customer already submitted for ownership request, cannot re-submit.');
        }
        // Validate Opp Pending
        validateExistingOpportunityRequest(accountObj);
    }

	public Customer_Ownership_Request__c createCustomerOwnershipRequest(Account accountObj, User currentUser) {
		Id portRecordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_PORT_DEVNAME);
		Customer_Ownership_Request__c requestObj = new Customer_Ownership_Request__c(
        	Request_Ownership_Type__c = GlobalConstants.PORT,
        	Request_Type__c  = GlobalConstants.REQUEST_OWNERSHIP,
            CIS_ID__c        = accountObj.Id,
            OwnerID          = currentUser.Id,
            RecordTypeId     = portRecordTypeId,
            User_Admin__c    = UserManager.getUserAdmin().User_Record_ID__c,
            Current_Owner__c = accountObj.OwnerId
        );

        return requestObj;
	}
}