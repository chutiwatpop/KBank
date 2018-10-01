/**
* @author komsan.wi@beryl8.com
* @23/09/2015 createddate
*/
trigger CreditBureauTrigger on Credit_Bureau__c(before insert) {
	new CreditBureauTriggerHandler().run();
}