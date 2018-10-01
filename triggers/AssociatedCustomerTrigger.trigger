/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
trigger AssociatedCustomerTrigger on Associated_Customer__c (after insert) {
	new AssociatedCustomerTriggerHandler().run();
}