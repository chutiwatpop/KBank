/**
* @author komsan.wi@beryl8.com
* @12/07/2015 createddate
*/
trigger CustomerOwnershipRequestTrigger on Customer_Ownership_Request__c(before insert,after insert,before update,after update) {
	if(!TriggerHandler.isBypassed('CustomerOwnershipRequestTriggerHandler')){
    	new CustomerOwnershipRequestTriggerHandler().run();
	}
}