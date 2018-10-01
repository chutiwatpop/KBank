global class SME_TeamStructureInitial_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	Map<String, List<User>> allUsersMapByRCCode;
	Map<String, User> ownerUserMapByRCCode;
	List<Team_Structure__c> updateTeamList;
	
	global SME_TeamStructureInitial_Batch() {
		query = 'SELECT Id, RC_Code__c, AH_Name__c, AH_Name__r.OwnerId, NH_Name__c, NH_Name__r.OwnerId, Province__c FROM Team_Structure__c';
		Set<String> profileSet = new Set<String>{GlobalConstants.SME_NH, GlobalConstants.SME_AH, GlobalConstants.SME_TM};
        profileSet.addAll(GlobalConstants.PROFILE_AN_SET);

		List<User> allUser = [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Province__c, Profile.Name FROM User ORDER BY Isactive DESC, LastModifiedDate DESC];
		allUsersMapByRCCode = new Map<String, List<User>>();
		ownerUserMapByRCCode = new Map<String, User>();

		for(User eachUser : allUser) {
            if(eachUser.RC_Code__c != null) {
                if(!allUsersMapByRCCode.containsKey(eachUser.RC_Code__c)) {
                    allUsersMapByRCCode.put(eachUser.RC_Code__c, new List<User>());
                }
                allUsersMapByRCCode.get(eachUser.RC_Code__c).add(eachUser);

	            if(profileSet.contains(eachUser.Profile.Name)) {
	                if(!ownerUserMapByRCCode.containsKey(eachUser.RC_Code__c) && eachUser.RC_Code__c != null)
	                    ownerUserMapByRCCode.put(eachUser.RC_Code__c, eachUser);
	            }
            }
        }

        updateTeamList = new List<Team_Structure__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Team_Structure__c> scope) {
   		SME_Admin__c smeAdmin = SME_Admin__c.getOrgDefaults();
   		List<User> updateUserList = new List<User>();
   		User eachUser;
		for(Team_Structure__c eachTeam : scope) {
			if(ownerUserMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
				eachUser = ownerUserMapByRCCode.get(eachTeam.RC_Code__c);
				if(eachUser.IsActive)
					eachTeam.OwnerId = eachUser.Id;
				else if(eachUser.Manager != null && eachUser.Manager.IsActive)
		            eachTeam.OwnerId = eachUser.ManagerId;
		        else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive)
		            eachTeam.OwnerId = eachUser.Manager.ManagerId;
			} else if(eachTeam.AH_Name__c != null) {
				eachTeam.OwnerId = eachTeam.AH_Name__r.OwnerId;
			} else if(eachTeam.NH_Name__c != null) {
				eachTeam.OwnerId = eachTeam.NH_Name__r.OwnerId;
			} else {
				eachTeam.OwnerId = smeAdmin.User_Record_ID__c;
			}
			updateTeamList.add(eachTeam);

			if(allUsersMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
				for(User updateUser : allUsersMapByRCCode.get(eachTeam.RC_Code__c)) {
					updateUser.Province__c = eachTeam.Province__c;
					updateUserList.add(updateUser);	
				}
			}
		}
		TriggerHandler.bypass('UserTriggerHandler');
        update updateUserList;
        TriggerHandler.clearBypass('UserTriggerHandler');
        

	}
	
	global void finish(Database.BatchableContext BC) {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		update updateTeamList;
		TriggerHandler.clearBypass('TeamStructureTriggerHandler');
	}
	
}