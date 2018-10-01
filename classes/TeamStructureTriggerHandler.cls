public class TeamStructureTriggerHandler extends TriggerHandler{

	private static Map<String, CollaborationGroup>  mapCollaborationGroupMapByName;
	public override void allAfter() {
        //for test class
        if(TestUtils.isRunningTest()){
            User_Service.allUserMap = null;
            SME_GroupChatterService.mapCollaborationGroupMapByName = null;
        }

        if(User_Service.allUserMap == null){
            User_Service.allUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User]);
        }

        if(SME_GroupChatterService.mapCollaborationGroupMapByName == null){
            SME_GroupChatterService.mapCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
        }

        if(SME_GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId == null){
            SME_GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId = SME_GroupChatterService.getAllGroupMembersByGroupIdAndMemberId();
        }
    }

    public override void allBefore() {
		checkNhGroupNameCondition();
	}

	public override void afterUpdate() {
		updateGroupChatter();
	}

	public override void afterInsert() {
		createGroupChatter();
	}

	public override void afterDelete() {
		deleteGroupChatter();
	}

	private void deleteGroupChatter(){
		List<CollaborationGroup> listDeleteCollaborationGroup = new List<CollaborationGroup>();
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.old){
			if(eachTeam.Type__c == 'Network' && !eachTeam.Name.contains('franchise')){
				String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				CollaborationGroup deleteCollaborationGroup = SME_GroupChatterService.deleteGroupChatter(groupName);
				if(deleteCollaborationGroup != null){
					listDeleteCollaborationGroup.add(deleteCollaborationGroup);
				}
			}
		}

		if(!listDeleteCollaborationGroup.isEmpty()){
			delete listDeleteCollaborationGroup;
		}
	}

	private Boolean isNetworkChangeTeamName(Team_Structure__c newTeam , Team_Structure__c oldTeam){
		if(newTeam.Type__c == 'Network' && oldTeam.Name != newTeam.Name){
			return true;
		}
		return false;
	}

	private Boolean isChangeTypeToNetwork(Team_Structure__c newTeam , Team_Structure__c oldTeam){
		if(newTeam.Type__c == 'Network' && newTeam.Type__c != oldTeam.Type__c){
			return true;
		}
		return false;
	}

	private void checkNhGroupNameCondition(){
		if(mapCollaborationGroupMapByName == null){
			mapCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
		}
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.new){
			if(eachTeam.Type__c == 'Network'){
				String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				
				//if(Trigger.isInsert || Trigger.isUpdate){
					//if(isGroupNameLengthMoreThan40(groupName)){
					//	eachTeam.addError(System.Label.TeamStructure_Name_Error);
					//}
				//}

				if(Trigger.isInsert){
					if(mapCollaborationGroupMapByName.containsKey(groupName)){
						eachTeam.addError(System.Label.TeamStructure_Dup_Name_Error);
					}
				}
			}
		}
	}

	//private Boolean isGroupNameLengthMoreThan40(String groupName){
	//	Boolean result = false;
	//	if(groupName.length() > 40){
	//		return true;
	//	}
	//	return false;
	//}

	private void updateGroupChatter(){
		String groupName;
		CollaborationGroup collaborationGroup;
		List<CollaborationGroupMember> listInsertCollaborationGroupManager = new List<CollaborationGroupMember>();
		List<CollaborationGroup> listInsertCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroup> listUpdateCollaborationGroup = new List<CollaborationGroup>();
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.new){

			Team_Structure__c oldTeam = (Team_Structure__c) Trigger.oldMap.get(eachTeam.Id);

			if(isNetworkChangeTeamName(eachTeam,oldTeam)){
				collaborationGroup = SME_GroupChatterService.getUpdatedGroupName(eachTeam,oldTeam);
				if(collaborationGroup != null){
					listUpdateCollaborationGroup.add(collaborationGroup);
				}
			}else if(isChangeTypeToNetwork(eachTeam,oldTeam)){
				groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				collaborationGroup = SME_GroupChatterService.createGroupChatter(groupName);
				if(collaborationGroup != null){
					listInsertCollaborationGroup.add(collaborationGroup);
				}
			}
		}

		if(!listUpdateCollaborationGroup.isEmpty()){
			update listUpdateCollaborationGroup;
		}
		if(!listInsertCollaborationGroup.isEmpty()){
			insert listInsertCollaborationGroup;
			for(CollaborationGroup eachGroup : listInsertCollaborationGroup){
				listInsertCollaborationGroupManager.addAll(SME_GroupChatterService.getListManager(eachGroup));
			}
		}

		if(!listInsertCollaborationGroupManager.isEmpty()){
			insert listInsertCollaborationGroupManager;
		}
	}

	private void createGroupChatter(){
		String groupName;
		List<CollaborationGroupMember> listInsertCollaborationGroupManager = new List<CollaborationGroupMember>();
		List<CollaborationGroup> listCollaborationGroup = new List<CollaborationGroup>();
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.new){
			if(eachTeam.Type__c == 'Network' && !eachTeam.Name.contains('franchise')){
				groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				CollaborationGroup collaborationGroup = SME_GroupChatterService.createGroupChatter(groupName);
				listCollaborationGroup.add(collaborationGroup);
			}
		}

		if(!listCollaborationGroup.isEmpty()){
			insert listCollaborationGroup;
		}
		for(CollaborationGroup eachGroup : listCollaborationGroup){
			listInsertCollaborationGroupManager.addAll(SME_GroupChatterService.getListManager(eachGroup));
		}
		if(!listInsertCollaborationGroupManager.isEmpty()){
			insert listInsertCollaborationGroupManager;
		}
	}
}