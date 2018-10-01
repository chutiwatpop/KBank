trigger IssueLogTrigger on Issue_Log__c (before insert, before update, after insert, after update) {
	new IssueLogTriggerHandler().run();
}