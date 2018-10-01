/**
 * @author chutiwat.s@beryl8.com
 * @15/09/2015 created date
 */
trigger YearEndAssignmentTrigger on Year_End_Assignment__c (before insert) {
	new YearEndAssignmentTriggerHandler().run();
}