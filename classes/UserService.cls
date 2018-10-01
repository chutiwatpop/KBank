public without sharing class UserService {
	private static User currentUserInfo;
	private static final Set<String> managerProfile = new Set<String>{
        	GlobalConstants.AF_NH, GlobalConstants.AF_AH, GlobalConstants.AF_TM,
        	GlobalConstants.CBS_TL, GlobalConstants.CBS_TM,
        	GlobalConstants.RBS_NH, GlobalConstants.RBS_AH, GlobalConstants.RBS_TM,
        	GlobalConstants.SME_NH, GlobalConstants.SME_AH, GlobalConstants.SME_TM, GlobalConstants.AN_NH, GlobalConstants.AN_AH, GlobalConstants.AN_TM
        };

	public static User getCurrentUserInfo() {
		if(currentUserInfo == null) {
			currentUserInfo = (new UserSelector()).selectById(UserInfo.getUserId(), new Set<String>{'Id','Name','IsActive','RC_Code__c','Profile.Name','UserRole.Name','Employee_ID__c','Segment__c'});
		}
		return currentUserInfo;
	}

	@future
	public static void createUpdateUserReleatedObject(List<String> userIds) {
		List<User> userList = [SELECT Id, RC_Code__c, FirstName, LastName, IsActive, Employee_ID__c, Segment__c, Profile.Name FROM User WHERE Id IN :userIds];
		Set<String> rcCodes = new Set<String>();
		for(User eachUser : userList) {
			if(eachUser.RC_Code__c != null) {
				rcCodes.add(eachUser.RC_Code__c);
			}
		}

		Map<String, Team_Structure__c> teamMapByRCCode = new Map<String, Team_Structure__c>();
		List<Team_Structure__c> teamStructures = [SELECT Id, RC_Code__c, OwnerId, Province__c, Segment__c, AH_Name__c, AH_Name__r.OwnerId, NH_Name__c, NH_Name__r.OwnerId FROM Team_Structure__c WHERE RC_Code__c IN :rcCodes];
		for(Team_Structure__c eachTeam : teamStructures) {
			teamMapByRCCode.put(eachTeam.RC_Code__c, eachTeam);
		}
		List<Team_Structure__c> updateTeamList		 = new List<Team_Structure__c>();
		List<User_Extension__c> newUserExtensionList = new List<User_Extension__c>();
		for(User eachUser : userList) {
			newUserExtensionList.add(createUserExtension(eachUser, teamMapByRCCode));
			if(needToUpdateTeamOwner(eachUser)) {
				if(teamMapByRCCode.get(eachUser.RC_Code__c) != null){
					updateTeamList.add(teamMapByRCCode.get(eachUser.RC_Code__c));
				}
			}
		}
		insert newUserExtensionList;
		calculateTeamOwner(updateTeamList);
	}

	private static Boolean needToUpdateTeamOwner(User eachUser) {
        if(eachUser.IsActive && managerProfile.contains(eachUser.Profile.Name)) {
            return true;
        }
        return false;
	}

	@TestVisible
	private static User_Extension__c createUserExtension(User eachUser, Map<String, Team_Structure__c> teamMapByRCCode) {
        List<Team_Structure__c> teamStructureUpdateList = new List<Team_Structure__c>();
        User_Extension__c userExt = new User_Extension__c();
        if(teamMapByRCCode.containsKey(eachUser.RC_Code__c)) {
        	userExt.Team_Structure__c = teamMapByRcCode.get(eachUser.RC_Code__c).Id;
        	userExt.OwnerId 		  = teamMapByRcCode.get(eachUser.RC_Code__c).OwnerId;
        	/*if(!profileRMName.contains(eachUser.Profile.Name)) {
        		eachTeam = teamMapByRCCode.get(eachUser.RC_Code__c);
            	eachTeam.OwnerId = eachUser.Id;
            	teamStructureUpdateList.add(eachTeam);
        	}*/
        }
        if(eachUser.IsActive) {
            userExt.OwnerId = eachUser.Id;
        }
        userExt.User__c = eachUser.Id;
        userExt.Name    = (eachUser.FirstName != null) ? (eachUser.FirstName + ' ' + eachUser.LastName) : eachUser.LastName;
        userExt.External_ID__c  = eachUser.Employee_ID__c;
        userExt.Segment_Text__c = eachUser.Segment__c;

        return userExt;
    }

    public static void calculateTeamOwner(List<Team_Structure__c> updateTeamList) {
		List<Team_Structure__c> smeTeamStructures = new List<Team_Structure__c>();
		List<Team_Structure__c> cbsTeamStructures = new List<Team_Structure__c>();
		List<Team_Structure__c> rbsTeamStructures = new List<Team_Structure__c>();
		List<Team_Structure__c> afTeamStructures  = new List<Team_Structure__c>();

		for(Team_Structure__c eachTeam : updateTeamList) {
			if(SMEInitialTeamStructure.segmentList.contains(eachTeam.Segment__c)) {
				smeTeamStructures.add(eachTeam);
			} else if(CBSInitialTeamStructure.segmentList.contains(eachTeam.Segment__c)) {
				cbsTeamStructures.add(eachTeam);
			} else if(RBSInitialTeamStructure.segmentList.contains(eachTeam.Segment__c)) {
				rbsTeamStructures.add(eachTeam);
			} else if(AFInitialTeamStructure.segmentList.contains(eachTeam.Segment__c)) {
				afTeamStructures.add(eachTeam);
			}
		}

		if(!smeTeamStructures.isEmpty()) {
			(new SMEInitialTeamStructure()).calculateTeamOwner(smeTeamStructures);
		}
		if(!cbsTeamStructures.isEmpty()) {
			(new CBSInitialTeamStructure()).calculateTeamOwner(cbsTeamStructures);
		}
		if(!rbsTeamStructures.isEmpty()) {
			(new RBSInitialTeamStructure()).calculateTeamOwner(rbsTeamStructures);
		}
		if(!afTeamStructures.isEmpty()) {
			(new AFInitialTeamStructure()).calculateTeamOwner(afTeamStructures);
		}
	}
}