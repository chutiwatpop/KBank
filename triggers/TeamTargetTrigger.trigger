/**
* @author Panachai Reinthavorn
*/
trigger TeamTargetTrigger on Team_Target__c (after update) {
    new TeamTriggerHandler().run(); 
}