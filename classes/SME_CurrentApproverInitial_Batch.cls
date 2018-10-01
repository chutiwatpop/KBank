global class SME_CurrentApproverInitial_Batch implements Database.Batchable<sObject> {
	
	String query;
	Map<Id,User> userMap;
	
	
	
	global SME_CurrentApproverInitial_Batch() {
		if(Test.isRunningTest()){
			query = 'SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, UserRole.Name, Current_Opportunity_Approval__c, IsActive FROM User WHERE FirstName IN (\''+Mockup_Test.userFirstNameRM+'\',\''+Mockup_Test.userFirstNameTM+'\',\''+Mockup_Test.userFirstNameAH+'\',\''+Mockup_Test.userFirstNameNH+'\')';
		}
		else{
			query = 'SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Profile.Name, UserRole.Name, Current_Opportunity_Approval__c, IsActive FROM User';
		}
		userMap = new Map<Id,User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, UserRole.Name, Profile.Name, Current_Opportunity_Approval__c, IsActive FROM User]);
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> userList) {
		System.debug('User List : '+userList);
		System.debug('User Map : '+userMap);

		for(User eachUser : userList){
			System.debug('each user profile name : '+eachUser.Profile.Name);
			System.debug('each user Manager.ManagerId : '+eachUser.Manager.ManagerId);
			//System.debug('each user get usermap is active: '+userMap.get(eachUser.Manager.ManagerId).IsActive);
			
			if(eachUser.UserRole.Name != GlobalConstants.SME_FRANCHISE){
				if(eachUser.Profile.Name == GlobalConstants.SME_RM && eachUser.Manager.ManagerId != null ){
					if(userMap.get(eachUser.Manager.ManagerId).IsActive){
						eachUser.Current_Opportunity_Approval__c = eachUser.Manager.ManagerId;
					}else if(eachUser.Manager.Manager.ManagerId != null){
						if(userMap.get(eachUser.Manager.Manager.ManagerId).IsActive){
							eachUser.Current_Opportunity_Approval__c = eachUser.Manager.Manager.ManagerId;
						}
					}
				}
				if(eachUser.Profile.Name == GlobalConstants.SME_TM && eachUser.ManagerId != null ){
					if(userMap.get(eachUser.ManagerId).IsActive){
						eachUser.Current_Opportunity_Approval__c = eachUser.ManagerId;
					}else if(eachUser.Manager.ManagerId != null){
						if(userMap.get(eachUser.Manager.ManagerId).IsActive){
							eachUser.Current_Opportunity_Approval__c = eachUser.Manager.Manager.ManagerId;
						}
					}
				}
			}
			
		}
		TriggerHandler.bypass('UserTriggerHandler');
		update userList;
		TriggerHandler.clearBypass('UserTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}