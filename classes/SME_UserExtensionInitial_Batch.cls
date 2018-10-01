global class SME_UserExtensionInitial_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	private String query;
	private Map<String, Team_Structure__c> teamMapByRc;
	private List<User_Extension__c> userExtList;

	global SME_UserExtensionInitial_Batch() {
		// Delete old extension
		if(userExtList == null) {
			userExtList = new List<User_Extension__c>();
			userExtList = [SELECT Id FROM User_Extension__c];
		}
		
		this.query = 'SELECT Id, Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive FROM User';
 		if(Test.isRunningTest()) this.query += ' LIMIT 100';

		teamMapByRc = new Map<String, Team_Structure__c>();
		List<Team_Structure__c> teamList = [SELECT Id, External_ID__c FROM Team_Structure__c];
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRc.put(eachTeam.External_ID__c, eachTeam);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> userList) {
   		SME_Admin__c smeAdmin = SME_Admin__c.getOrgDefaults();

   		if(userExtList != null && !userExtList.isEmpty()) {
   			delete userExtList;
   			userExtList.clear();
   		}

   		List<User_Extension__c> userExtInitialList = new List<User_Extension__c>();

   		User_Extension__c eachUserExt;
		for(User eachUser : userList) {
			if(eachUser.Employee_ID__c != null) {
				eachUserExt = new User_Extension__c();
				
				if(eachUser.IsActive)
					eachUserExt.OwnerId = eachUser.Id;
				else if(eachUser.Manager != null && eachUser.Manager.IsActive)
		            eachUserExt.OwnerId = eachUser.ManagerId;
		        else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive)
		            eachUserExt.OwnerId = eachUser.Manager.ManagerId;
		        else if(eachUser.Manager.Manager.Manager != null && eachUser.Manager.Manager.Manager.IsActive)
		            eachUserExt.OwnerId = eachUser.Manager.Manager.ManagerId;
		        else
		        	eachUserExt.OwnerId = smeAdmin.User_Record_ID__c;

				eachUserExt.Name = eachUser.Name;
				eachUserExt.User__c = eachUser.Id;
				eachUserExt.External_ID__c = eachUser.Employee_ID__c;
				if(eachUser.RC_Code__c != null && teamMapByRc.containsKey(eachUser.RC_Code__c)) {
					eachUserExt.Team_Structure__c = teamMapByRc.get(eachUser.RC_Code__c).Id;
				}
				userExtInitialList.add(eachUserExt);
			}
		}

		if(!userExtInitialList.isEmpty()) {
			insert userExtInitialList;
		}
	}
	
	global void finish(Database.BatchableContext BC) {}
	
}