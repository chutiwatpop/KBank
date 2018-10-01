public without sharing abstract class OwnershipAssignmentManager {
	public abstract List<SObject> getObjectList();

	public Set<String> getReAssignUserRCCode(List<User_MaskModel> userMaskList) {
		Set<String> rcCodes = new Set<String>();
		for(User_MaskModel userMask : userMaskList){
			if(userMask.isChangeToActive || userMask.isChangeRCCode || userMask.isReCalculateOwnership) {
				rcCodes.add(userMask.newRCCode);
			}
		}
		return rcCodes;
	}

	public Set<Id> getTeamOwnerIds(List<Team_Structure__c> teamList) {
		Set<Id> userIds = new Set<Id>();
		for(Team_Structure__c eachTeam : teamList){
			userIds.add(eachTeam.OwnerId);
		}
		return userIds;
	}

	public Map<String, User> getUserMapByNewRoleRC(Map<id,User_MaskModel> userMaskMapByUserId){
	 	Map<String, User> userMapByNewRoleRC = new Map<String, User>();
	    for(User_MaskModel userMask : userMaskMapByUserId.values()){
	        User eachUser = userMask.newUserObj;
	        userMapByNewRoleRC.put(eachUser.Job_Code__c + '-' + eachUser.RC_Code__c, eachUser);
	    }
	    return userMapByNewRoleRC;
	}

	public Map<String, Team_Structure__c> getTeamStructureMapByRCCode() {
		Map<String,Team_Structure__c> teamMapByRc = new Map<String, Team_Structure__c>();
		for(Team_Structure__c eachTeam : [SELECT Id, RC_Code__c, OwnerId, Owner.IsActive, External_ID__c, Type__c, Name, Segment__c, AH_RC_Code__c, NH_RC_Code__c, AH_Name__c, NH_Name__c, Branch_Code__c, Branch_Name__c, RC_Short_Name__c, AH_Short_Name__c, NH_Short_Name__c FROM Team_Structure__c]) {
			if(eachTeam.RC_Code__c != null) {
                teamMapByRc.put(eachTeam.RC_Code__c, eachTeam);
            }
		}
		return teamMapByRc;
	}

	public Map<Id,User> getUsersMap(Set<Id> userIds) {
		return new Map<Id,User>([
			SELECT Id,RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, IsActive, Profile.Name,SME_User__c,CBS_User__c,Is_RBS_User__c,Current_Opportunity_Approval__c,
			(Select Id from User_Extension__r Limit 1) 
			From User 
			WHERE Id IN :userIds]);
	}

	public Database.SaveResult[] executeUpdate(List<SObject> sObjectList, Boolean allOrNone) {
		/*Database.SaveResult[] saveResults = Database.update(sObjectList, allOrNone);
		List<Application_Log__c> applicationLogs = GlobalUtility.generateLogResults(saveResults, 'AssignmentQueue');
		if(!applicationLogs.isEmpty()) {
			System.debug('applicationLogs:' + applicationLogs);
			insert applicationLogs;
		}
		return saveResults;*/
		update sObjectList;
		
		return null;
	}

	public Set<Id> getAdminIds(User_Admin__c userAdmin) {
		Set<Id> adminIds = new Set<Id>();
		if(userAdmin.SME_User_ID__c != null)
		adminIds.add(userAdmin.SME_User_ID__c);
		if(userAdmin.CBS_User_ID__c != null)
		adminIds.add(userAdmin.CBS_User_ID__c);
		if(userAdmin.RBS_User_ID__c != null)
		adminIds.add(userAdmin.RBS_User_ID__c);
		return adminIds;
	}

	public void generateLog(List<User_MaskModel> userMaskList, String sourceClass, String errorMsg) {
		List<Application_Log__c> applicationLogs = new List<Application_Log__c>();
		Datetime dt = Datetime.now();
        String formattedDt 	= dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
		applicationLogs.add(new Application_Log__c(
			Name 			= 'ERR-'+formattedDt,
			Debug_Level__c 	= 'Error',
			Message__c 		= errorMsg,
			Source__c 		= sourceClass
		));
		for (User_MaskModel userMask : userMaskList) {
            Application_Log__c aLog = new Application_Log__c();
			dt = Datetime.now();
            formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            aLog.Name 			= 'ERR-'+formattedDt;
            aLog.Debug_Level__c = 'Error';
            aLog.Message__c 	= 'UserId:' + userMask.userId +' isChangeRCCode:'+ userMask.isChangeRCCode +' isChangeToInactive:' + userMask.isChangeToInactive;
            aLog.Source__c 		= sourceClass;
            applicationLogs.add(aLog);
        }
        if(!applicationLogs.isEmpty()) insert applicationLogs;
	}

	/*public static User getAdminFromUser(User user, User_Admin__c userAdmin, Map<Id,User> userMap){
		User assignedAdmin;
		if(user.SME_User__c && userMap.containsKey(userAdmin.SME_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.SME_User_ID__c);
		}
		else if(user.CBS_User__c && userMap.containsKey(userAdmin.CBS_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.CBS_User_ID__c);
		}
		else if(user.Is_RBS_User__c && userMap.containsKey(userAdmin.RBS_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.RBS_User_ID__c);
		}
		return assignedAdmin;
	}*/

	public static User getAdminFromUserMask(User_MaskModel userMask, User_Admin__c userAdmin, Map<Id,User> userMap){
		User assignedAdmin;
		String profileName = userMask.getProfileName();
		if(GlobalConstants.PROFILE_SME_SET.contains(profileName) && userMap.containsKey(userAdmin.SME_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.SME_User_ID__c);
		}
		else if(GlobalConstants.PROFILE_CBS_SET.contains(profileName) && userMap.containsKey(userAdmin.CBS_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.CBS_User_ID__c);
		}
		else if((GlobalConstants.PROFILE_RBS_SET.contains(profileName) || GlobalConstants.PROFILE_AF_SET.contains(profileName)) && userMap.containsKey(userAdmin.RBS_User_ID__c)){
			assignedAdmin = userMap.get(userAdmin.RBS_User_ID__c);
		}
		return assignedAdmin;
	}

	public static User getAssignedUserWhenOneLevelUp(Map<String,Team_Structure__c> teamMapByRc, Map<Id,User> userMap, User user){
		User assignedUser;
		List<String> rcCodeSet = new List<String>{user.RC_Code__c, user.AH_RC_Code__c, user.NH_RC_Code__c};
		System.debug('rcCodeSet:' + rcCodeSet);
		for(String rcCode : rcCodeSet){
			User tempUser = getTeamManagerFromRC(teamMapByRc, userMap, rcCode);
			if(tempUser != null && tempUser.IsActive){
				assignedUser = tempUser;
				break;
			}
		}
		return assignedUser;
	}

	public static User getTeamManagerFromRC(Map<String,Team_Structure__c> teamMapByRc, Map<Id,User> userMap, String rcCode){
		User teamManager;
		if(!String.isBlank(rcCode) && teamMapByRc.containsKey(rcCode)){
			Id tempId = teamMapByRc.get(rcCode).OwnerId;
			if(userMap.containsKey(tempId) ){
				teamManager = userMap.get(tempId);
			}
		}
		return teamManager;
	}

	public static User getUserForReplacement(User_MaskModel userMask,Map<String,User> userMapByNewRoleRC){
	    User replaceUser;
	    if(userMapByNewRoleRC.containsKey(userMask.previousJobCode + '-' + userMask.previousRCCode)){
	      User tempUser = userMapByNewRoleRC.get(userMask.previousJobCode + '-' + userMask.previousRCCode);
	      if(tempUser.IsActive){
	        replaceUser = tempUser;
	      }
	    }
	    return replaceUser;
  	}
}