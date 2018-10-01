/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
* @08/02/2017 Refactor code
*/
trigger AccountTrigger on Account(before insert,before update,after insert,after update) {
	Boolean isBypassed = false;
	for(Account eachAccount : (List<Account>)Trigger.new){
		if(eachAccount.Manual_Check_Flag__c){
			isBypassed = true;
			eachAccount.Manual_Check_Flag__c = false;
		}
	}
    if(Account_Service.accountTriggerMap == null && !TriggerHandler.isBypassed('AccountTriggerHandler') && !isBypassed){
        new AccountTriggerHandler().run();
    }
}