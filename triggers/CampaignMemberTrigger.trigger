trigger CampaignMemberTrigger on CampaignMember (before insert) {
	new CampaignMemberTriggerHandler().run();
}