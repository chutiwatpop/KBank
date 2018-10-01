/**
* @author anan.b@beryl8.com
* @07/02/2017 created new
*/
trigger LPMTrigger on LPM__c (before insert,before update,after update,before delete) {
	if(!TriggerHandler.isBypassed('LPMTriggerHandler')){
		new LPMTriggerHandler().run();
	}
}