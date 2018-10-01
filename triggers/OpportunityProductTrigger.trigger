trigger OpportunityProductTrigger on OpportunityLineItem (before update,before insert,after insert,after update) {
	if(!TriggerHandler.isBypassed('OpportunityProductTriggerHandler')){
		new OpportunityProductTriggerHandler().run();
	}
}