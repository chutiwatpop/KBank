global class SME_UserExtensionOwnerInitial_Batch implements Database.Batchable<sObject> {
	
	private String query;

	global SME_UserExtensionOwnerInitial_Batch() {
		this.query = 'SELECT Id, User__c, User__r.IsActive, User__r.ManagerId, User__r.Manager.ManagerId, User__r.Manager.Manager.ManagerId, User__r.Manager.IsActive, User__r.Manager.Manager.IsActive, User__r.Manager.Manager.Manager.IsActive FROM User_Extension__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User_Extension__c> userExtList) {
   		SME_Admin__c smeAdmin = SME_Admin__c.getOrgDefaults();

   		List<User_Extension__c> userExtInitialList = new List<User_Extension__c>();

		for(User_Extension__c eachUserExt : userExtList) {
			if(eachUserExt.User__c != null) {
				if(eachUserExt.User__r.IsActive)
					eachUserExt.OwnerId = eachUserExt.User__c;
				else if(eachUserExt.User__r.Manager != null && eachUserExt.User__r.Manager.IsActive)
		            eachUserExt.OwnerId = eachUserExt.User__r.ManagerId;
		        else if(eachUserExt.User__r.Manager.Manager != null && eachUserExt.User__r.Manager.Manager.IsActive)
		            eachUserExt.OwnerId = eachUserExt.User__r.Manager.ManagerId;
		        else if(eachUserExt.User__r.Manager.Manager.Manager != null && eachUserExt.User__r.Manager.Manager.Manager.IsActive)
		            eachUserExt.OwnerId = eachUserExt.User__r.Manager.Manager.ManagerId;
		        else
		        	eachUserExt.OwnerId = smeAdmin.User_Record_ID__c;
				userExtInitialList.add(eachUserExt);
			}
		}

		if(!userExtInitialList.isEmpty()) {
			TriggerHandler.bypass('UserExtensionTriggerHandler');
			update userExtInitialList;
		}
	}
	
	global void finish(Database.BatchableContext BC) {}
	
}