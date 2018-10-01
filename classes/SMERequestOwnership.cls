public without sharing class SMERequestOwnership implements IRequestOwnership {
	public void validateCustomer(Account accountObj, User currentUser) {
		Boolean isSuccess = true;
		if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME) {
            if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(accountObj.OwnerId != UserManager.getUserAdmin().SME_User_ID__c &&
                	accountObj.SME_Temporary_Customer__c == null &&
                	(!GlobalConstants.PROFILE_SME_SET.contains(accountObj.Owner.Profile.Name))) {
                    isSuccess = false;
                }
            } else if(!GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
				if(accountObj.SME_Temporary_Customer__c == null) {
                    isSuccess = false;
                }
            }
        } else if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            if(accountObj.SME_Temporary_Customer__c == null) {
                isSuccess = false;
            }
        } else {
            // No permission to request
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
		Id poolRecordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_POOL_DEVNAME);
        Id portRecordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_PORT_DEVNAME);
        String requestRecordType;

        if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME) {
            if(GlobalConstants.SME_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                if(accountObj.Port_Pool__c == GlobalConstants.PORT) {
                    requestRecordType = portRecordTypeId;
                } else if(accountObj.Port_Pool__c == GlobalConstants.POOL) {
                    requestRecordType = portRecordTypeId;
                } else {
                    if(accountObj.OwnerId == UserManager.getUserAdmin().SME_User_ID__c) {
                        requestRecordType = portRecordTypeId;
                    } else {
                        requestRecordType = poolRecordTypeId;
                    }
                }
            } else if(GlobalConstants.CBS_PRIMARY_SEGMENT_CODE_SET.contains(accountObj.Primary_Segment_Code__c)) {
                requestRecordType = portRecordTypeId;
            } else {
				requestRecordType = poolRecordTypeId;
            }
        } else if(accountObj.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME || 
            accountObj.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            if(accountObj.SME_Temporary_Customer__c != null) {
                requestRecordType = poolRecordTypeId;
            }
        }

        Customer_Ownership_Request__c requestObj = new Customer_Ownership_Request__c(
        	Request_Ownership_Type__c = GlobalConstants.PORT,
        	Request_Type__c  = GlobalConstants.REQUEST_OWNERSHIP,
            CIS_ID__c        = accountObj.Id,
            OwnerID          = currentUser.Id,
            RecordTypeId     = requestRecordType,
            User_Admin__c    = UserManager.getUserAdmin().User_Record_ID__c
        );
        if(requestRecordType == poolRecordTypeId && accountObj.SME_Temporary_Customer__c != null) {
        	// Need to change query
            User_Extension__c userExtension = [SELECT Id, User__c FROM User_Extension__c WHERE Id = :accountObj.SME_Temporary_Customer__c];
            requestObj.Current_Owner__c = userExtension.User__c;
            requestObj.SME_Temporary_Customer__c = accountObj.SME_Temporary_Customer__c;
        } else {
            requestObj.Current_Owner__c = accountObj.OwnerId;
        }
        System.debug('createCustomerOwnershipRequest:' + requestObj);
        return requestObj;
	}
	
}