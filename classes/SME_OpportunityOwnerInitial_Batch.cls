global class SME_OpportunityOwnerInitial_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	private Map<String, Id> teamMapByRc;
	private Map<String, Id> userExtMapByEmpId;
	
	global SME_OpportunityOwnerInitial_Batch() {
		this.init();
	}

	private void init() {
		teamMapByRc = new Map<String, Id>();
		userExtMapByEmpId = new Map<String, Id>();

		List<Team_Structure__c> teamList = [SELECT Id, External_ID__c FROM Team_Structure__c];
		for(Team_Structure__c eachTeam : teamList) {
			teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
		}

		List<User_Extension__c> userExtList = [SELECT Id, External_ID__c FROM User_Extension__c];
		for(User_Extension__c eachUserExt : userExtList) {
			userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
		}

		this.query = 'SELECT Id, AccountId FROM Opportunity';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
		Map<Id, Id> accountMapByCallRepId = new Map<Id, Id>();
		for(Opportunity eachOpp : oppList) {
			accountMapByCallRepId.put(eachOpp.Id, eachOpp.AccountId);
		}

		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Ownership_Text__c, Port_Pool__c, Owner_Emp_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c  FROM Account WHERE Id IN:accountMapByCallRepId.values()]);

		Account tempAccount;
		for(Opportunity eachOpp : oppList) {
			if(accountMap.containsKey(accountMapByCallRepId.get(eachOpp.Id))) {
				tempAccount = accountMap.get(accountMapByCallRepId.get(eachOpp.Id));

				if(teamMapByRc.containsKey(tempAccount.RC_Code__c)) 
					eachOpp.Current_Team_Name__c = teamMapByRc.get(tempAccount.RC_Code__c);
				if(teamMapByRc.containsKey(tempAccount.AH_RC_Code__c)) 
					eachOpp.Current_AH_Name__c = teamMapByRc.get(tempAccount.AH_RC_Code__c);
				if(teamMapByRc.containsKey(tempAccount.NH_RC_Code__c)) 
					eachOpp.Current_NH_Name__c = teamMapByRc.get(tempAccount.NH_RC_Code__c);
				if(userExtMapByEmpId.containsKey(tempAccount.Owner_Emp_ID__c))
					eachOpp.Current_Owner_Extension__c = userExtMapByEmpId.get(tempAccount.Owner_Emp_ID__c);

				eachOpp.Port_Pool__c = tempAccount.Port_Pool__c;
				eachOpp.Ownership__c = tempAccount.Ownership_Text__c;
			}
		}
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update oppList;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}