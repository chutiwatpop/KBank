global class SME_TrashPoolInitial_Batch implements Database.Batchable<sObject> {
	
	String query;
	Map<Id,User> userMap;
	Map<String,Id> userExtMap;
	Map<Id,User> userMapByExt;
	SME_Admin__c smeAdmin;
	Map<String,Team_Structure__c> teamStructureMap;
	
	global SME_TrashPoolInitial_Batch() {
		query = 'SELECT Id, OwnerId, RecordType.DeveloperName, Ownership_Text__c, Port_Pool__c, Permanent_Owner_Extension__c, Permanent_Team_Name__c, Permanent_AH_Name__c, Permanent_NH_Name__c FROM Account WHERE Port_Pool__c = null AND Ownership_Text__c = \''+GlobalConstants.OWNERSHIP_TEMPORARY+'\' '+'AND RecordType.DeveloperName = \''+GlobalConstants.SME_CUSTOMER_DEVNAME+'\' AND Primary_Segment_Code__c IN (\'LM\',\'SM\',\'UM\')';
		userMap = User_Service.getAllUserMap();
		userExtMap = UserExtension_Service.getUserExtensionMapByUser();
		userMapByExt = UserExtension_Service.getAllUserMapByUserExt();
		teamStructureMap = TeamStructure_Service.getTeamStructureMapByRCCode();
		smeAdmin = SME_Admin__c.getOrgDefaults();
		System.debug('SME-Admin ID : '+smeAdmin.User_Record_ID__c);
		System.debug('SME-Admin userextId : '+userExtMap.get(smeAdmin.User_Record_ID__c));
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accountList) {
   		System.debug('Executing Batch');
   		/*
   		if(Test.isRunningTest()){
   			List<User_Extension__c> SMEadmin = [SELECT Id, User__c FROM User_Extension__c WHERE User__c =: smeAdmin.User_Record_ID__c];
   			for(User_Extension__c eachUserExt : SMEadmin){
   				System.debug('each user extension : '+eachUserExt);
   			}
   		}
   		*/
		for(Account eachAccount : accountList){
			User ownerOfAccount = userMap.get(eachAccount.OwnerId);
			if(ownerOfAccount.Profile.Name == GlobalConstants.SME_RM){
				if(ownerOfAccount.IsActive){
					eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
					eachAccount.Port_Pool__c = GlobalConstants.POOL;

					System.debug('TM active : '+userMap.get(ownerOfAccount.ManagerId).IsActive);

					if(userMap.get(ownerOfAccount.ManagerId).IsActive){
						eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.ManagerId);
						System.debug('userExtMap : '+userExtMap.get(ownerOfAccount.ManagerId));
					
					}else if(userMap.get(ownerOfAccount.Manager.ManagerId).IsActive){
						eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Manager.ManagerId);
					
					}else if(userMap.get(ownerOfAccount.Manager.Manager.ManagerId).IsActive){
						eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Manager.Manager.ManagerId);
					
					}else{
						eachAccount.Permanent_Owner_Extension__c = userExtMap.get(smeAdmin.User_Record_ID__c);
					}

					if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c != null){
						if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c)){
							eachAccount.Permanent_Team_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c).Id;
						}else{
							eachAccount.Permanent_Team_Name__c = null;
						}
					}else{
						eachAccount.Permanent_Team_Name__c = null;
					}
					if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c != null){
						if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c)){
							eachAccount.Permanent_AH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c).Id;
						}else{
							eachAccount.Permanent_AH_Name__c = null;
						}
					}else{
						eachAccount.Permanent_AH_Name__c = null;
					}
					if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c != null){
						if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c)){
							eachAccount.Permanent_NH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c).Id;
						}else{
							eachAccount.Permanent_NH_Name__c = null;
						}
					}else{
						eachAccount.Permanent_NH_Name__c = null;
					}
				}
			}
			if(ownerOfAccount.Profile.Name == GlobalConstants.SME_TM){
				
				eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
				eachAccount.Port_Pool__c = GlobalConstants.POOL;
				if(ownerOfAccount.IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Id);
					
				}else if(userMap.get(ownerOfAccount.ManagerId).IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.ManagerId);
					
				}else if(userMap.get(ownerOfAccount.Manager.ManagerId).IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Manager.ManagerId);
					
				}else{
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(smeAdmin.User_Record_ID__c);
				}
				
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c)){
						eachAccount.Permanent_Team_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c).Id;
					}else{
						eachAccount.Permanent_Team_Name__c = null;
					}
				}else{
					eachAccount.Permanent_Team_Name__c = null;
				}
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c)){
						eachAccount.Permanent_AH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c).Id;
					}else{
						eachAccount.Permanent_AH_Name__c = null;
					}
				}else{
					eachAccount.Permanent_AH_Name__c = null;
				}
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c)){
						eachAccount.Permanent_NH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c).Id;
					}else{
						eachAccount.Permanent_NH_Name__c = null;
					}
				}else{
					eachAccount.Permanent_NH_Name__c = null;
				}
			}
			if(ownerOfAccount.Profile.Name == GlobalConstants.SME_AH){
				
				eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
				eachAccount.Port_Pool__c = GlobalConstants.POOL;
				if(ownerOfAccount.IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Id);
					
				}else if(userMap.get(ownerOfAccount.ManagerId).IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.ManagerId);
					
				}else{
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(smeAdmin.User_Record_ID__c);
					
				}

				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c)){
						eachAccount.Permanent_Team_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c).Id;
					}else{
						eachAccount.Permanent_Team_Name__c = null;
					}
				}else{
					eachAccount.Permanent_Team_Name__c = null;
				}
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c)){
						eachAccount.Permanent_AH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).AH_RC_Code__c).Id;
					}else{
						eachAccount.Permanent_AH_Name__c = null;
					}
				}else{
					eachAccount.Permanent_AH_Name__c = null;
				}
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c)){
						eachAccount.Permanent_NH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c).Id;
					}else{
						eachAccount.Permanent_NH_Name__c = null;
					}
				}else{
					eachAccount.Permanent_NH_Name__c = null;
				}
			}
			if(ownerOfAccount.Profile.Name == GlobalConstants.SME_NH){
				System.debug('Id of NH : '+ownerOfAccount.Id);
				System.debug('owner of account IsActive : '+ownerOfAccount.IsActive);
				eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
				eachAccount.Port_Pool__c = GlobalConstants.POOL;
				if(ownerOfAccount.IsActive){
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(ownerOfAccount.Id);
					
				}else{
					eachAccount.Permanent_Owner_Extension__c = userExtMap.get(smeAdmin.User_Record_ID__c);
					System.debug('Non Active : '+eachAccount.Permanent_Owner_Extension__c);
				}
				//System.debug('Permanent_Owner_Extension__c contains key : '+userExtMap.containsKey(eachAccount.Permanent_Owner_Extension__c));
				
				//System.debug('user ex map rc code : '+userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c);
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c)){
						eachAccount.Permanent_Team_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).RC_Code__c).Id;
					}else{
						eachAccount.Permanent_Team_Name__c = null;
					}
				}else{
					eachAccount.Permanent_Team_Name__c = null;
				}
				
				eachAccount.Permanent_AH_Name__c = null;
				
				if(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c != null){
					if(teamStructureMap.containsKey(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c)){
						eachAccount.Permanent_NH_Name__c = teamStructureMap.get(userMapByExt.get(eachAccount.Permanent_Owner_Extension__c).NH_RC_Code__c).Id;
					}else{
						eachAccount.Permanent_NH_Name__c = null;
					}
				}else{
					eachAccount.Permanent_NH_Name__c = null;
				}
			}
		}
		TriggerHandler.bypass('AccountTriggerHandler');
		update accountList;
		TriggerHandler.clearBypass('AccountTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

}