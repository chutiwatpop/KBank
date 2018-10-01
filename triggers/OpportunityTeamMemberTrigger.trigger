trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (after Delete,after insert) {
	if(!TriggerHandler.isBypassed('OpportunityTeamMemberTriggerHandler')){
        new OpportunityTeamMemberTriggerHandler().run();
    }
}