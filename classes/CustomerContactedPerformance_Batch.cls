global class CustomerContactedPerformance_Batch implements Database.Batchable<SObject>, Database.Stateful {
	Map<String, User_Extension__c> userExtMapByUserId;
	Map<Id, User_Extension__c> userExtMap;
	String query;
	
	global CustomerContactedPerformance_Batch() {
		userExtMap = new Map<Id, User_Extension__c>([SELECT Id,User__c,Customer_Contacted__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__c != null AND User__r.SME_User__c = true]);
		userExtMapByUserId = new Map<String, User_Extension__c>();
        for(User_Extension__c eachExt : userExtMap.values()){
        	userExtMapByUserId.put(eachExt.User__c, eachExt);
        }

		query = 'SELECT Id,User__r.Id,Customer_Contacted__c FROM User_Extension__c WHERE Team_Structure__c != null AND User__c != null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('query = '+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User_Extension__c> listUserEx) {
   		List<String> listUserId = new List<String>();
   		for(User_Extension__c eachUserEx : listUserEx){
   			listUserId.add(eachUserEx.User__r.Id);
   		}

   		List<User_Extension__c> listUpdateUserEx = new List<User_Extension__c>();
   		List<String> queryRecordType = new List<String>();
		queryRecordType.addAll(GlobalConstants.CALL_PLAN_CALL_REPORT_SME_DEVNAME_SET);
		//queryRecordType.addAll(GlobalConstants.CALL_PLAN_CALL_REPORT_RBS_DEVNAME_SET);
		List<AggregateResult> listCountEvent = [SELECT OwnerId Owner_Id,COUNT_DISTINCT(Job__r.AccountId) Number_Of_Visited_Customer FROM Event WHERE OwnerId IN :listUserId AND RecordType.DeveloperName IN :queryRecordType GROUP BY OwnerId];
		for(AggregateResult eachCountEvent : listCountEvent){
			String ownerId = (String)eachCountEvent.get('Owner_Id');
			if(ownerId != null && userExtMapByUserId.containsKey(ownerId)){
				User_Extension__c userVisitCustomer = userExtMapByUserId.get(ownerId);
				Integer numberOfVisitedCustomer = (Integer)eachCountEvent.get('Number_Of_Visited_Customer');
				userVisitCustomer.Customer_Contacted__c = numberOfVisitedCustomer;
				listUpdateUserEx.add(userVisitCustomer);
			}
		}

   		TriggerHandler.bypass('UserExtensionTriggerHandler');
   		update listUpdateUserEx;
   		TriggerHandler.clearBypass('UserExtensionTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {
		Database.executeBatch(new SummaryTeamPerformance_Batch());
	}
	
}