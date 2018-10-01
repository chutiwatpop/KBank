trigger BusinessCodeTrigger on Business_Code__c (after update) {
	if(!TriggerHandler.isBypassed('BusinessCodeTriggerHandler')){
    	new BusinessCodeTriggerHandler().run();
	}
}