/**
* @author anan.b@beryl8.com
* @07/02/2017 created new
*/
trigger LPMCustomerTrigger on LPM_Customer__c (before insert,before update,after delete) {
	if(!TriggerHandler.isBypassed('LPMTriggerHandler')){
		new LPMCustomerTriggerHandler().run();
	}
}