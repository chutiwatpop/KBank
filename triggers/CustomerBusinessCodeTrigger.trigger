trigger CustomerBusinessCodeTrigger on Customer_Business_Code__c (before insert,before update) {
	if(!TriggerHandler.isBypassed('CustomerBusinessCodeTriggerHandler')){
    	new CustomerBusinessCodeTriggerHandler().run();
	}
}