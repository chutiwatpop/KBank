/**
* @author komsan.wi@beryl8.com
* @11/04/2015 created new
*/
trigger MonthlyPerformanceTrigger on Monthly_Performance__c(before update) {
	new MonthlyPerformanceTriggerHandler().run();
}