//use for auto run script after refresh
global class ScriptAfterRefresh implements SandboxPostCopy{
	global void runApexClass(SandboxContext context) {
	    // Clear Phone Number
		List<User> userList = [SELECT Id, MobilePhone, Phone FROM User WHERE MobilePhone != null OR Phone != null];
		for(User eachUser : userList) {
		    eachUser.MobilePhone = null;
		    eachUser.Phone = null;
		}
		TriggerHandler.bypass('UserTriggerHandler');
		update userList;

		// Edit User Structure User Name
		String postFix = '.ppe';
		List<User_Structure__c> userStructureList = [SELECT Id, Username__c,Email__c FROM User_Structure__c WHERE Username__c != null];
		for(User_Structure__c eachUser : userStructureList) {
		   if(!eachUser.Username__c.contains(postFix)){
		      eachUser.Username__c = eachUser.Username__c + postFix;
		   }
		   
		   if(eachUser.Email__c != null){
		   		eachUser.Email__c = eachUser.Email__c + postFix;
		   }
		}
		update userStructureList;

		// Delete Event External User
		delete [SELECT Id FROM Event_External_User__c];

		GlobalUtility.autoGenerateScheduleJob();
	}
}