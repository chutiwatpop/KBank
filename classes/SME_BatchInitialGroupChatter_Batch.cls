global class SME_BatchInitialGroupChatter_Batch implements Database.Batchable<sObject>, Database.Stateful {
	String queryListNhTeamStructure;
	Set<String> setTeamSegment = new Set<String>();
	Map<String,Team_Structure__c> mapTeamStructureMapByNhRcCode = new Map<String,Team_Structure__c>();
	Map<String,List<User>> mapListUserMapByNhRcCode = new Map<String,List<User>>();
	Map<String,CollaborationGroup> collaborationGroupMapByRcCode = new Map<String,CollaborationGroup>();
	Map<String,CollaborationGroup> mapNewGroupMapByName = new Map<String,CollaborationGroup>();
	global SME_BatchInitialGroupChatter_Batch() {
		this.queryListNhTeamStructure = 'SELECT Id,Name,Rc_Code__c,Segment__c FROM Team_Structure__c WHERE Type__c = \'Network\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//if(SME_GroupChatterService.mapCollaborationGroupMapByName == null){
		//	SME_GroupChatterService.mapCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
		//}
		List<String> listProfileNameForGroup = new List<String>{GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM,GlobalConstants.SME_RM};
		List<String> listAdmin = new List<String>{System.Label.Chatter_Group_Owner};
		for(Chatter_Group_Manager__c groupManager : Chatter_Group_Manager__c.getall().values()){
			listAdmin.add(groupManager.Name);
		}

		List<User> listUser = [SELECT Id,Name,Segment__c,NH_RC_Code__c,Profile.Name,RC_Code__c FROM User WHERE Profile.Name IN :listProfileNameForGroup AND Name NOT IN :listAdmin AND isActive = true ORDER BY NH_RC_Code__c,Segment__c];
		for(User eachUser : listUser){
			List<User> listUserGroupByNhRcCode;
			String nhRcCode = eachUser.Profile.Name == GlobalConstants.SME_NH ? eachUser.RC_Code__c : eachUser.NH_RC_Code__c;
			if(nhRcCode != null){
				if(!mapListUserMapByNhRcCode.containsKey(nhRcCode)){
					listUserGroupByNhRcCode = new List<User>();
				}else{
					listUserGroupByNhRcCode = mapListUserMapByNhRcCode.get(nhRcCode);
				}
				listUserGroupByNhRcCode.add(eachUser);
			
				mapListUserMapByNhRcCode.put(nhRcCode, listUserGroupByNhRcCode);
			}
		}

		return Database.getQueryLocator(queryListNhTeamStructure);
	}

   	global void execute(Database.BatchableContext BC, List<Team_Structure__c> listNhTeamStructure) {
   		TriggerHandler.bypass('UserTriggerHandler');
   		User ownerAllGroup = [SELECT Id,DefaultGroupNotificationFrequency FROM User WHERE Name = :System.Label.Chatter_Group_Owner LIMIT 1];
		ownerAllGroup.DefaultGroupNotificationFrequency = Chatter_Group_Email_Noti__c.getValues('Owner').NotificationFrequency__c;
		update ownerAllGroup;
		TriggerHandler.clearBypass('UserTriggerHandler');

		List<CollaborationGroup> listCreateCollaborationGroup = createNhGroupAndAllNhGroup(listNhTeamStructure);
		System.debug('listCreateCollaborationGroup = '+listCreateCollaborationGroup);
		if(!listCreateCollaborationGroup.isEmpty()){
			insert listCreateCollaborationGroup;
		}
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = createGroupMemberAndAdmin(listNhTeamStructure);
		System.debug('listCreateCollaborationGroupMember = '+listCreateCollaborationGroupMember);
		if(!listCreateCollaborationGroupMember.isEmpty()){
			insert listCreateCollaborationGroupMember;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	private List<CollaborationGroupMember> createGroupMemberAndAdmin(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroupMember> listNewCollaborationGroupMember = new List<CollaborationGroupMember>();
		Map<String, CollaborationGroup> mapAllGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
		Map<Id, Map<Id, CollaborationGroupMember>> mapAllGroupMembersByGroupIdAndMemberId = SME_GroupChatterService.getAllGroupMembersByGroupIdAndMemberId();
		for(Team_Structure__c eachTeam : listNhTeamStructure){
			String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
			CollaborationGroup eachGroupNh = mapAllGroupMapByName.get(groupName);
			System.debug('groupName = '+groupName);
			System.debug('eachGroupNh = '+eachGroupNh);
			if(eachGroupNh != null){
				if(mapNewGroupMapByName.containsKey(groupName)){
					listNewCollaborationGroupMember.addAll(SME_GroupChatterService.getListManager(eachGroupNh));
				}

				List<User> listUserGroupMapNhRcCode = mapListUserMapByNhRcCode.get(eachTeam.Rc_Code__c);

				System.debug('eachTeam.Rc_Code__c = '+eachTeam.Rc_Code__c);
				System.debug('listUserGroupMapNhRcCode = '+listUserGroupMapNhRcCode);
				Map<Id, CollaborationGroupMember> mapOldMemberMapById = mapAllGroupMembersByGroupIdAndMemberId.get(eachGroupNh.Id);
				if(listUserGroupMapNhRcCode != null && !listUserGroupMapNhRcCode.isEmpty()){
					for(User eachUser : listUserGroupMapNhRcCode){
						if(!mapOldMemberMapById.containsKey(eachUser.Id)){
							CollaborationGroupMember newMember = SME_GroupChatterService.createMemberGroup(eachUser, eachGroupNh);
							listNewCollaborationGroupMember.add(newMember);
						}
						//if(eachUser.Profile.Name == GlobalConstants.SME_NH){
							CollaborationGroupMember newNhMember = createNhMemberToAllNhGroupBySegment(eachUser,mapAllGroupMapByName,mapAllGroupMembersByGroupIdAndMemberId);
							if(newNhMember != null){
								listNewCollaborationGroupMember.add(newNhMember);
							}
						//}
					}
			}	}
		}

		for(String segment : setTeamSegment){
			CollaborationGroup allNhGroupBySegment = mapAllGroupMapByName.get(segment);
			if(mapNewGroupMapByName.containsKey(segment)){
				listNewCollaborationGroupMember.addAll(SME_GroupChatterService.getListManager(allNhGroupBySegment));
			}
		}
		return listNewCollaborationGroupMember;
	}

	private CollaborationGroupMember createNhMemberToAllNhGroupBySegment(User nhUser,Map<String, CollaborationGroup> mapAllGroupMapByName,Map<Id, Map<Id, CollaborationGroupMember>> mapAllGroupMembersByGroupIdAndMemberId){
		CollaborationGroupMember newNhMember;
		if(nhUser.Segment__c != null){
			CollaborationGroup allNhGroupBySegment = mapAllGroupMapByName.get(nhUser.Segment__c);
			if(allNhGroupBySegment == null){
				allNhGroupBySegment = mapNewGroupMapByName.get(nhUser.Segment__c);
			}
			Map<Id, CollaborationGroupMember> mapOldMemberMapById = mapAllGroupMembersByGroupIdAndMemberId.get(allNhGroupBySegment.Id);
			if(!mapOldMemberMapById.containsKey(nhUser.Id)){
				newNhMember = SME_GroupChatterService.createMemberGroup(nhUser, mapAllGroupMapByName.get(nhUser.Segment__c));
			}
		}
		return newNhMember;
	}

	private List<CollaborationGroup> createNhGroupAndAllNhGroup(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroup> listCreateCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = new List<CollaborationGroupMember>();
		Map<String, CollaborationGroup> allCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();

		for(Team_Structure__c eachTeam : listNhTeamStructure){
			if(!eachTeam.Name.contains('franchise')){
				String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
				if(groupName.length() <= 40){
					System.debug('check groupName = '+groupName + ' : '+ allCollaborationGroupMapByName.containsKey(groupName));
					if(!allCollaborationGroupMapByName.containsKey(groupName)){
						CollaborationGroup newGroup = SME_GroupChatterService.createGroupChatter(groupName);
						listCreateCollaborationGroup.add(newGroup);
						allCollaborationGroupMapByName.put(groupName,newGroup);
						mapNewGroupMapByName.put(groupName, newGroup);
					}

					String convertSement = eachTeam.Segment__c == 'Small' ? GlobalConstants.SEGMENT_SE : eachTeam.Segment__c == 'Medium' ? GlobalConstants.SEGMENT_ME : eachTeam.Segment__c; 
					System.debug('convertSement = '+convertSement);
					if(convertSement != null && !allCollaborationGroupMapByName.containsKey(convertSement)){
						setTeamSegment.add(convertSement);
						CollaborationGroup newAllGroup = SME_GroupChatterService.createGroupChatter(convertSement);
						listCreateCollaborationGroup.add(newAllGroup);
						allCollaborationGroupMapByName.put(convertSement,newAllGroup);
						mapNewGroupMapByName.put(convertSement, newAllGroup);
					}
				}
			}
		}

		System.debug('listCreateCollaborationGroup = '+listCreateCollaborationGroup);
		return listCreateCollaborationGroup;
	}
}