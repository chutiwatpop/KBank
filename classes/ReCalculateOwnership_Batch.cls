global class ReCalculateOwnership_Batch implements Database.Batchable<sObject> {
	String query;

	global ReCalculateOwnership_Batch() {
		this.query = 'SELECT Id, OwnerId, Previous_Owner__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Previous_Owner__r.RC_Code__c, Previous_Owner__r.AH_RC_Code__c, Previous_Owner__r.NH_RC_Code__c, Previous_Owner__r.Employee_ID__c FROM Account';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		AccountChangeOwner accountService = new AccountChangeOwner();
   		User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();

   		// Prepare Team Structure and User Extension
   		ReCalculateOwnership_Service.UserExtensionAndTeam relatedUserExtensionAndTeam = ReCalculateOwnership_Service.getRelatedUserExtensionAndTeam(scope);
   		Map<String, Id> teamMapByRc = relatedUserExtensionAndTeam.teamMapByRc;
		Map<Id, User_Extension__c> userExtMapByUserId = relatedUserExtensionAndTeam.userExtMapByUserId;

   		for(Account eachAccount : scope) {
   			// Set Current Field Set by OwnerId
   			accountService.setCurrentOwnerFieldsSet(eachAccount, teamMapByRc, userExtMapByUserId.get(eachAccount.OwnerId));

   			// Set Permanent Field Set by OwnerId // If admin User clear Permanent Field Set
   			if(eachAccount.OwnerId == userAdmin.SME_User_ID__c) {
   				eachAccount.Ownership_Text__c 	= '';
                eachAccount.Port_Pool__c 		= '';
                accountService.clearPermanentOwnerFieldsSet(eachAccount);
   			} else if(eachAccount.OwnerId == userAdmin.CBS_User_ID__c) {
   				eachAccount.Ownership_Text__c 	= GlobalConstants.OWNERSHIP_PERMANENT;
                eachAccount.Port_Pool__c 		= GlobalConstants.PORT;
                accountService.clearPermanentOwnerFieldsSet(eachAccount);
			} else {
				accountService.setPermanentOwnerFieldsSet(eachAccount, teamMapByRc, userExtMapByUserId.get(eachAccount.OwnerId));
			}
			
			// Set Previous Field Set by Previous Owner
			if(userExtMapByUserId.containsKey(eachAccount.Previous_Owner__c)) {
				eachAccount.Previous_Owner_Extension__c  = userExtMapByUserId.get(eachAccount.Previous_Owner__c).Id;
		        eachAccount.Previous_AH_Name__c          = teamMapByRc.get(eachAccount.Previous_Owner__r.AH_RC_Code__c);
		        eachAccount.Previous_NH_Name__c          = teamMapByRc.get(eachAccount.Previous_Owner__r.NH_RC_Code__c);
		        eachAccount.Previous_Team_Name__c        = teamMapByRc.get(eachAccount.Previous_Owner__r.RC_Code__c);
			}
   		}
   		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {}
}