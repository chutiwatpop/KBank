public interface IRequestOwnership {
	void validateCustomer(Account accountObj, User currentUser);
	void validateExistingRequest(Account accountObj, User currentUser);
	Customer_Ownership_Request__c createCustomerOwnershipRequest(Account accountObj, User currentUser);
}