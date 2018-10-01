public without sharing class SME_GroupChatterService {
	public static Map<String, CollaborationGroup> mapCollaborationGroupMapByName;
	public static Map<Id, Map<Id, CollaborationGroupMember>> mapAllGroupMembersByGroupIdAndMemberId;
	public static User groupOwner;
	public static List<User> listUserManager = new List<User>();
	public static Map<Id, User> allUserMap;
	public static Map<Id, User> allOldUserMap;
	public static Map<String, Team_Structure__c> teamMapByRC;
	public static List<Chatter_Group_Name__c> listChatterGroupName;
	public static List<Chatter_Group_Manager__c> listChatterGroupManager;
	public static Boolean isByPassGroupChatterService = false;

	public static Map<String, CollaborationGroup> getAllCollaborationGroupMapByName(){
		Map<String, CollaborationGroup>  groupMapByName = new Map<String, CollaborationGroup> ();
		//List<CollaborationGroup> listCollaborationGroup = [SELECT Id,Name FROM CollaborationGroup];
		for(CollaborationGroup colGroup : [SELECT Id,Name FROM CollaborationGroup]){
			groupMapByName.put(colGroup.Name, colGroup);
		}
		return groupMapByName;
	}

	public static Map<Id, Map<Id, CollaborationGroupMember>> getAllGroupMembersByGroupIdAndMemberId(){
		Map<Id, Map<Id, CollaborationGroupMember>> memberMapByGroupIdAndMemberId = new Map<Id, Map<Id, CollaborationGroupMember>>();
		//List<CollaborationGroupMember> listMembers = [SELECT Id,CollaborationGroupId,MemberId,CollaborationGroup.Name,Member.Name FROM CollaborationGroupMember ORDER BY CollaborationGroupId];
		Id previousGroupId;
		Map<Id, CollaborationGroupMember> mapCollaborationGroupMemberById = new Map<Id, CollaborationGroupMember>();
		for(CollaborationGroupMember member : [SELECT Id,CollaborationGroupId,MemberId,CollaborationGroup.Name,Member.Name FROM CollaborationGroupMember ORDER BY CollaborationGroupId]){
			if(previousGroupId == null){
				previousGroupId = member.CollaborationGroupId;
			}
			
			if(previousGroupId != member.CollaborationGroupId){
				memberMapByGroupIdAndMemberId.put(previousGroupId, mapCollaborationGroupMemberById);
				mapCollaborationGroupMemberById = new Map<Id, CollaborationGroupMember>();
				previousGroupId = member.CollaborationGroupId;
			}
			
			mapCollaborationGroupMemberById.put(member.MemberId, member);
			
		}
		if(previousGroupId != null){
			memberMapByGroupIdAndMemberId.put(previousGroupId, mapCollaborationGroupMemberById);
		}
		return memberMapByGroupIdAndMemberId;
	}

	public static void addUserToList(User user,List<CollaborationGroupMember> insertCollaborationGroupMemberList){
		manageChatter(user,insertCollaborationGroupMemberList,true);
	}

	@future
	//public static void addMemberFutureMethod(String stringListUser,String stringMapOldUser,String stringAllUserMap,String stringallOldUserMap,String stringMapTeamMapByRC){
	public static void addMemberFutureMethod(List<Id> updateUserList ,String stringMapOldUser,String stringallOldUserMap){
		// List<User> listUser = (List<User>) JSON.deserialize(stringListUser, List<User>.class);
		List<User> listUser = [SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User WHERE Id IN :updateUserList];
		List<CollaborationGroupMember> listInsertMemberToGroup = new List<CollaborationGroupMember>();
		allUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User WHERE Segment__c IN ('SE', 'ME')]);
		allOldUserMap = (Map<Id, User>) JSON.deserialize(stringallOldUserMap, Map<Id, User>.class);
		teamMapByRC = TeamStructure_Service.getTeamStructureMapByRCCode();

		mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
		mapAllGroupMembersByGroupIdAndMemberId = getAllGroupMembersByGroupIdAndMemberId();

		for(User eachUser : listUser){
			if(eachUser.Employee_ID__c != null && eachUser.IsActive) {
				addUserToList(eachUser,listInsertMemberToGroup);
			}
		}
		if(!listInsertMemberToGroup.isEmpty()){
            insert listInsertMemberToGroup;
        }
	}

	@future
	//public static void manageGroupChatter(String stringListUser,String stringMapOldUser,String stringAllUserMap,String stringallOldUserMap,String stringMapTeamMapByRC){
	public static void manageGroupChatter(List<Id> updateUserList,String stringMapOldUser,String stringallOldUserMap){
		List<CollaborationGroupMember> listInsertMemberToGroup = new List<CollaborationGroupMember>();
		List<CollaborationGroupMember> listDeleteMemberFromGroup = new List<CollaborationGroupMember>();
		// List<User> listUser = (List<User>) JSON.deserialize(stringListUser, List<User>.class);
		List<User> listUser = [SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User WHERE Id IN :updateUserList];
		// Map<Id,User> mapOldUser = (Map<Id,User>) JSON.deserialize(stringMapOldUser, Map<Id,User>.class);
		allUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User WHERE Segment__c IN ('SE', 'ME')]);
		allOldUserMap = (Map<Id, User>) JSON.deserialize(stringallOldUserMap, Map<Id, User>.class);	
		teamMapByRC = TeamStructure_Service.getTeamStructureMapByRCCode();

		mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
		mapAllGroupMembersByGroupIdAndMemberId = getAllGroupMembersByGroupIdAndMemberId();

		for(User eachUser : listUser){
			User oldUser = allOldUserMap.get(eachUser.Id);
			if(!eachUser.IsActive){
	            addDeleteUserToList(eachUser, listDeleteMemberFromGroup);
	        }else if(oldUser != null && eachUser.IsActive && !oldUser.IsActive){
	        	addUserToList(eachUser, listInsertMemberToGroup);
	        }else if(oldUser != null && isUserChangeNhRcCode(allUserMap.get(eachUser.Id),allOldUserMap.get(oldUser.Id))){
	            addDeleteUserToList(oldUser, listDeleteMemberFromGroup);
	            addUserToList(eachUser, listInsertMemberToGroup);
	        }
	    }
	    if(!listDeleteMemberFromGroup.isEmpty()){
            delete listDeleteMemberFromGroup;
        }
        if(!listInsertMemberToGroup.isEmpty()){
            insert listInsertMemberToGroup;
        }
	}

	public static void addDeleteUserToList(User oldUser,List<CollaborationGroupMember> deleteCollaborationGroupMemberList){
		manageChatter(oldUser,deleteCollaborationGroupMemberList,false);
	}

	private static void manageChatter(User user,List<CollaborationGroupMember> collaborationGroupMemberList,Boolean isAddMember){
		String rcCode;
        String groupName;

        User userWithProfile;

        if(isAddMember){
        	userWithProfile = allUserMap.get(user.Id);
    	}else{
			userWithProfile = allOldUserMap.get(user.Id);
    	}
	    if(userWithProfile != null && (userWithProfile.Profile.Name == GlobalConstants.SME_NH || userWithProfile.Profile.Name == GlobalConstants.SME_AH || userWithProfile.Profile.Name == GlobalConstants.SME_TM || userWithProfile.Profile.Name == GlobalConstants.SME_RM)){
	        Team_Structure__c teamStructure = getNhTeamStructure(userWithProfile);
	        if(teamStructure != null && teamStructure.Type__c == 'Network' && !teamStructure.Name.contains('franchise')){
	            groupName = createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);

	            if(mapCollaborationGroupMapByName == null){
					mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
				}
				if(mapAllGroupMembersByGroupIdAndMemberId == null){
					mapAllGroupMembersByGroupIdAndMemberId = getAllGroupMembersByGroupIdAndMemberId();
				}
	            CollaborationGroup collaborationGroup = mapCollaborationGroupMapByName.get(groupName);
	            CollaborationGroupMember member;
	            CollaborationGroupMember nhMember;
	            if(isAddMember){
	            	if(collaborationGroup == null){
		            	collaborationGroup = createGroupChatter(groupName);
		            	insert collaborationGroup;
		            	mapCollaborationGroupMapByName.put(collaborationGroup.Name, collaborationGroup);
		            	collaborationGroupMemberList.addAll(getListManager(collaborationGroup));
		            }
					member = createMemberGroup(user,collaborationGroup);
					nhMember = createMemberToAllNhGroup(userWithProfile,null,collaborationGroupMemberList);
					Map<Id,CollaborationGroupMember> oldMapCollaborationGroupMember = mapAllGroupMembersByGroupIdAndMemberId.get(collaborationGroup.Id);
					if(oldMapCollaborationGroupMember == null){
						oldMapCollaborationGroupMember = new Map<Id,CollaborationGroupMember>();
		            }
		            oldMapCollaborationGroupMember.put(member.MemberId, member);
		            mapAllGroupMembersByGroupIdAndMemberId.put(collaborationGroup.Id,oldMapCollaborationGroupMember);
	        	}else{
	        		if(collaborationGroup != null){
		        		member = mapAllGroupMembersByGroupIdAndMemberId.get(collaborationGroup.Id).get(user.Id);
		        		nhMember = deleteMemberFromAllNhGroup(userWithProfile,null,userWithProfile.Segment__c);
		        	}
	        	}
	            
	            if(member != null){
	            	collaborationGroupMemberList.add(member);	
	            }

	            if(nhMember != null){
	            	collaborationGroupMemberList.add(nhMember);
	            }
	        }
		}
	}

	public static String createGroupNameFromTeamNameAndSegment(String teamName,String segment){
		String groupName = teamName;
		if(!teamName.contains('franchise')){
			if(listChatterGroupName == null){
				listChatterGroupName = Chatter_Group_Name__c.getall().values();
			}
			for(Chatter_Group_Name__c replaceGroupName : listChatterGroupName){
				if(teamName.contains(replaceGroupName.replace_from__c + ' ')){
					groupName = teamName.replace(replaceGroupName.replace_from__c + ' ',replaceGroupName.Name + ' ');
					groupName = groupName.replace('(','');
	        		groupName = groupName.replace(')','');
					break;
				}
			}
		}
		if(groupName.length() > 40){
			return groupName.substring(0, 40);
		}
		return groupName;
	}

	private static Team_Structure__c getNhTeamStructure(User userWithProfile){
		String nhRcCode = getNhRcCodeFromUser(userWithProfile);
		if(teamMapByRC == null){
			teamMapByRC = TeamStructure_Service.getTeamStructureMapByRCCode();
		}
		Team_Structure__c ts = teamMapByRC.get(nhRcCode);
		return ts;
	}

	private static String getNhRcCodeFromUser(User userWithProfile){
		String nhRcCode = '';
		if(userWithProfile != null){
	        if(userWithProfile.Profile.Name != GlobalConstants.SME_NH){
	            nhRcCode = userWithProfile.NH_RC_Code__c;
	        }else {
	            nhRcCode = userWithProfile.RC_Code__c;
	        }
	    }
	    return nhRcCode;
	}

	public static CollaborationGroup createGroupChatter(String groupName){
		if(groupOwner == null){
			groupOwner = [SELECT Id FROM User WHERE Name = :System.Label.Chatter_Group_Owner LIMIT 1];
		}
		CollaborationGroup collaborationGroup = new CollaborationGroup();

    	collaborationGroup.OwnerId = groupOwner.Id;
    	collaborationGroup.Name = groupName;
    	collaborationGroup.CollaborationType = 'Private';
    	return collaborationGroup;
	}

	public static CollaborationGroup deleteGroupChatter(String groupName){
		if(mapCollaborationGroupMapByName == null){
			mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
		}
		CollaborationGroup collaborationGroup = mapCollaborationGroupMapByName.get(groupName);
    	return collaborationGroup;
	}

	public static CollaborationGroupMember createMemberGroup(User user,CollaborationGroup collaborationGroup){
		CollaborationGroupMember collaborationGroupMember = new CollaborationGroupMember();
		collaborationGroupMember.CollaborationGroupId = collaborationGroup.Id;
        collaborationGroupMember.CollaborationRole = 'Standard';
        collaborationGroupMember.MemberId = user.Id;
        collaborationGroupMember.NotificationFrequency = Chatter_Group_Email_Noti__c.getValues('Member').NotificationFrequency__c;
    	return collaborationGroupMember;
	}

	public static CollaborationGroupMember deleteMemberGroup(User user,CollaborationGroup collaborationGroup){
		CollaborationGroupMember deleteMember;
		if (user.Profile.Name == GlobalConstants.SME_NH || user.Profile.Name == GlobalConstants.SME_AH || User.Profile.Name == GlobalConstants.SME_TM || User.Profile.Name == GlobalConstants.SME_RM){
    		if(mapAllGroupMembersByGroupIdAndMemberId == null){
				mapAllGroupMembersByGroupIdAndMemberId = getAllGroupMembersByGroupIdAndMemberId();
			}			
			if(mapAllGroupMembersByGroupIdAndMemberId != null && collaborationGroup != null && mapAllGroupMembersByGroupIdAndMemberId.get(collaborationGroup.Id) != null){
				deleteMember = mapAllGroupMembersByGroupIdAndMemberId.get(collaborationGroup.Id).get(user.Id);
			}
        }

        return deleteMember;
	}

	public static CollaborationGroupMember createAdminGroup(User user,CollaborationGroup collaborationGroup){
		CollaborationGroupMember collaborationGroupMember = new CollaborationGroupMember();
		collaborationGroupMember.CollaborationGroupId = collaborationGroup.Id;
        collaborationGroupMember.CollaborationRole = 'Admin';
        collaborationGroupMember.MemberId = user.Id;
        collaborationGroupMember.NotificationFrequency = Chatter_Group_Email_Noti__c.getValues('Manager').NotificationFrequency__c;
    	return collaborationGroupMember;
	}

	public static Boolean isUserChangeNhRcCode(User newUser , User oldUser){
		if(newUser.Profile.Name == GlobalConstants.SME_NH){
			if(newUser.RC_Code__c != oldUser.RC_Code__c){
				return true;
			}
		}else if(newUser.Profile.Name == GlobalConstants.SME_AH || newUser.Profile.Name == GlobalConstants.SME_TM || newUser.Profile.Name == GlobalConstants.SME_RM){
			if(newUser.NH_RC_Code__c != oldUser.NH_RC_Code__c){
				return true;
			}
		}
		return false;
	}

	public static Boolean isUserNhChangeSegment(User newUser , User oldUser){
		if(newUser.Profile.Name == GlobalConstants.SME_NH){
			if(newUser.Segment__c != null && oldUser.Segment__c != null && newUser.Segment__c != oldUser.Segment__c){
				return true;
			}
		}
		return false;
	}

	public static CollaborationGroupMember createMemberToAllNhGroup(User user,String profileName ,List<CollaborationGroupMember> collaborationGroupMemberList){
		CollaborationGroupMember member;
		if (profileName == GlobalConstants.SME_NH || profileName == GlobalConstants.SME_AH || profileName == GlobalConstants.SME_TM || profileName == GlobalConstants.SME_RM 
			|| user.Profile.Name == GlobalConstants.SME_NH || user.Profile.Name == GlobalConstants.SME_AH || user.Profile.Name == GlobalConstants.SME_TM || user.Profile.Name == GlobalConstants.SME_RM){
        	CollaborationGroup groupAllNh;
        	if(mapCollaborationGroupMapByName == null){
				mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
			}
        	groupAllNh = mapCollaborationGroupMapByName.get(user.Segment__c);
        	if(groupAllNh == null && user.Segment__c != null && !user.Segment__c.contains('Franchise')){
            	groupAllNh = createGroupChatter(user.Segment__c);
            	insert groupAllNh;
            	mapCollaborationGroupMapByName.put(groupAllNh.Name, groupAllNh);
            	collaborationGroupMemberList.addAll(getListManager(groupAllNh));
            }
            if(groupAllNh != null){
            	Map<Id,CollaborationGroupMember> oldMapCollaborationGroupMember = mapAllGroupMembersByGroupIdAndMemberId.get(groupAllNh.Id);
				
				member = createMemberGroup(user,groupAllNh);
				if(oldMapCollaborationGroupMember == null){
					oldMapCollaborationGroupMember = new Map<Id,CollaborationGroupMember>();
				}
				oldMapCollaborationGroupMember.put(member.MemberId, member);
				mapAllGroupMembersByGroupIdAndMemberId.put(groupAllNh.Id,oldMapCollaborationGroupMember);
	        }
        }

        return member;
	}

	public static List<CollaborationGroupMember> getListManager(CollaborationGroup collaborationGroup){
		List<CollaborationGroupMember> returnList = new List<CollaborationGroupMember>();
		if(listUserManager.isEmpty()){
			Set<String> listManagerName = new Set<String>();
			if(listChatterGroupManager == null){
				listChatterGroupManager = Chatter_Group_Manager__c.getall().values();
			}
			for(Chatter_Group_Manager__c groupManager : listChatterGroupManager){
				listManagerName.add(groupManager.Name);
			}
			listUserManager = [SELECT Id,Name, Profile.Name FROM User WHERE Name in :listManagerName AND IsActive = true AND Name != :System.Label.Chatter_Group_Owner];
		}
		for(User eachUser : listUserManager){
			CollaborationGroupMember cbgMember = createAdminGroup(eachUser,collaborationGroup);
			returnList.add(cbgMember);
		}
		return returnList;
	}

	public static CollaborationGroupMember deleteMemberFromAllNhGroup(User user,String userProfileName,String oldSegment){
		CollaborationGroupMember member;
		if (userProfileName == GlobalConstants.SME_NH || userProfileName == GlobalConstants.SME_AH || userProfileName == GlobalConstants.SME_TM || userProfileName == GlobalConstants.SME_RM
			|| user.Profile.Name == GlobalConstants.SME_NH || user.Profile.Name == GlobalConstants.SME_AH || user.Profile.Name == GlobalConstants.SME_TM || user.Profile.Name == GlobalConstants.SME_RM){
        	CollaborationGroup groupAllNh;
        	if(mapCollaborationGroupMapByName == null){
				mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
			}

        	groupAllNh = mapCollaborationGroupMapByName.get(oldSegment);
        	if(groupAllNh != null){
        		if(mapAllGroupMembersByGroupIdAndMemberId == null){
					mapAllGroupMembersByGroupIdAndMemberId = getAllGroupMembersByGroupIdAndMemberId();
				}
				member = mapAllGroupMembersByGroupIdAndMemberId.get(groupAllNh.Id).get(user.Id);
        	}
        }

        return member;
	}

	public static CollaborationGroup getUpdatedGroupName(Team_Structure__c newTeam,Team_Structure__c oldTeam){
		if(mapCollaborationGroupMapByName == null){
			mapCollaborationGroupMapByName = getAllCollaborationGroupMapByName();
		}
		String oldName = createGroupNameFromTeamNameAndSegment(oldTeam.Name,oldTeam.Segment__c);
		String newName = createGroupNameFromTeamNameAndSegment(newTeam.Name,newTeam.Segment__c);
		CollaborationGroup collaborationGroup = mapCollaborationGroupMapByName.get(oldName);
		if(collaborationGroup != null){
			collaborationGroup.Name = newName;
		}
		return collaborationGroup;
	}
}