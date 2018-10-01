public with sharing class SMEReleaseOwnership implements IReleaseOwnership {
	public void validateCustomer(Account accountObj, User currentUser) {
		Boolean isValid = true;
		if(currentUser.Id != accountObj.OwnerId || accountObj.Port_Pool__c == '') {
			isValid = false;
		} else if(currentUser.Profile.Name != GlobalConstants.SME_TM && 
			currentUser.Profile.Name != GlobalConstants.SME_RM) {
			isValid = false;
		}
		if(!isValid) {
			throw new OwnershipException(ExceptionMessage.CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP);
		}
	}
}