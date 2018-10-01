trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (before insert) {
	new CollaborationGroupMemberTriggerHandler().run(); 
}