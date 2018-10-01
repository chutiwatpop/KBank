trigger LeadTrigger on Lead (before insert,before update,after insert,after update) {
	if(!TriggerHandler.isBypassed('LeadTriggerHandler')){
		new LeadTriggerHandler().run(); 
	}
}