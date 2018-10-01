public without sharing class GroupChatter_Queue implements Queueable {
	
	private Map<String,CollaborationGroup> mapInsertCollaborationGroupMapByGroupName;
	private Map<String, List<CollaborationGroupMember>> mapListMemberMapByGroupName;
	private List<CollaborationGroupMember> listDeleteMember;

	public GroupChatter_Queue(Map<String,CollaborationGroup> mapInsertCollaborationGroupMapByGroupName,Map<String, List<CollaborationGroupMember>> mapListMemberMapByGroupName,List<CollaborationGroupMember> listDeleteMember) {
		this.mapInsertCollaborationGroupMapByGroupName = mapInsertCollaborationGroupMapByGroupName;
		this.mapListMemberMapByGroupName = mapListMemberMapByGroupName;
		this.listDeleteMember = listDeleteMember;
	}

	public void execute(QueueableContext context) {
		Set<String> setAllCurrentGroupMember = getAllMember();
   		List<CollaborationGroupMember> listAllMember = new List<CollaborationGroupMember>();
   		if(mapInsertCollaborationGroupMapByGroupName.values() != null && !mapInsertCollaborationGroupMapByGroupName.values().isEmpty()){
			upsert mapInsertCollaborationGroupMapByGroupName.values();
		}
		if(listDeleteMember != null && !listDeleteMember.isEmpty()){
            System.debug('listDeleteMember == '+listDeleteMember);
			delete listDeleteMember;
		}
		
        System.debug('before loop mapInsertCollaborationGroupMapByGroupName');
		for(String groupName : mapInsertCollaborationGroupMapByGroupName.keySet()){
            System.debug('groupName == '+groupName);
			Id groupId = mapInsertCollaborationGroupMapByGroupName.get(groupName).Id;
			if(mapListMemberMapByGroupName != null){
				List<CollaborationGroupMember> listMemberEachGroup = mapListMemberMapByGroupName.get(groupName);
                System.debug('listMemberEachGroup == '+listMemberEachGroup);
				if(listMemberEachGroup != null){
					for(CollaborationGroupMember eachMember : listMemberEachGroup){
                        System.debug('set key = '+groupId+'-'+eachMember.MemberId);
                        System.debug('setAllCurrentGroupMember.contains = '+(setAllCurrentGroupMember.contains(groupId+'-'+eachMember.MemberId)));
						if(setAllCurrentGroupMember != null && !setAllCurrentGroupMember.contains(groupId+'-'+eachMember.MemberId)){
							eachMember.CollaborationGroupId = groupId;
                            listAllMember.add(eachMember);
						}
					}
				}
			}
		}
		if(listAllMember != null && !listAllMember.isEmpty()){
			TriggerHandler.bypass('CollaborationGroupMemberTriggerHandler');
            System.debug('listAllMember == '+listAllMember);
			insert listAllMember;
		}
	}
    
    private Set<String> getAllMember(){
		Set<String> setAllCurrentGroupMember = new Set<String>();
		List<CollaborationGroupMember> listAllMember = [SELECT Id,CollaborationGroupId,MemberId FROM CollaborationGroupMember];
		for(CollaborationGroupMember eachMember : listAllMember){
			setAllCurrentGroupMember.add(eachMember.CollaborationGroupId+'-'+eachMember.MemberId);
		}
		return setAllCurrentGroupMember;
	}
}