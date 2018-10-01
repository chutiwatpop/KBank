global class FlagInactiveUser_Batch implements Database.Batchable<sObject> {
	
	String query;
	Boolean executeNextBatch = true;
	global FlagInactiveUser_Batch() {
		List<String> listProfileRbs = new List<String>{GlobalConstants.RBS_RM_ABM,GlobalConstants.RBS_RM_BAR,GlobalConstants.RBS_TM,GlobalConstants.RBS_AH,GlobalConstants.RBS_NH,GlobalConstants.AF_NH,GlobalConstants.AF_AH,GlobalConstants.AF_TM,GlobalConstants.AF_RM};
		query = 'SELECT Id,Employee_ID__c,TempInactive__c FROM User WHERE IsActive = True AND Profile.Name IN (\'' + String.join(listProfileRbs,'\',\'') + '\') ';
	}

	global FlagInactiveUser_Batch(String whereCondition,Boolean executeNextBatch) {
		executeNextBatch = executeNextBatch;
		query = 'SELECT Id,Employee_ID__c,TempInactive__c FROM User WHERE '+whereCondition;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> listActiveUser) {
   		List<User> listFlagInactiveUser = new List<User>();
		Map<String,User> mapUserByEmpId = new Map<String,User>();
		for(User eachUser : listActiveUser){
			mapUserByEmpId.put(eachUser.Employee_ID__c,eachUser);
		}

		List<User_Structure__c> listUserStructure = [SELECT Id,Name FROM User_Structure__c WHERE Name IN :mapUserByEmpId.keySet()];
		Map<String,User_Structure__c> mapUserStructureByEmpId = new Map<String,User_Structure__c>();
		for(User_Structure__c eachUserStructure : listUserStructure){
			mapUserStructureByEmpId.put(eachUserStructure.Name, eachUserStructure);
		}

		for(String eachEmpId : mapUserByEmpId.keySet()){
			User flagInactiveUser = mapUserByEmpId.get(eachEmpId);
			if(!mapUserStructureByEmpId.containsKey(eachEmpId)){
				flagInactiveUser.TempInactive__c = true;
			}else{
				flagInactiveUser.TempInactive__c = false;
			}
			listFlagInactiveUser.add(flagInactiveUser);
		}

		TriggerHandler.bypass('UserTriggerHandler');
		Database.update(listFlagInactiveUser,false);
	}
	
	global void finish(Database.BatchableContext BC) {
		if(executeNextBatch && !Test.isRunningTest()){
			//GenerateUserStructureSchedule genUserFromUserStructure = new GenerateUserStructureSchedule();
			//genUserFromUserStructure.execute(null);
		}
	}
	
}