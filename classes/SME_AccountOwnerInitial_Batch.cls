global class SME_AccountOwnerInitial_Batch implements Database.Batchable<sObject> {
	
	String query;
	private Map<String, Id> teamMapByRc;
	private Map<String, Id> userExtMapByEmpId;

	global SME_AccountOwnerInitial_Batch() {
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

		this.query = 'SELECT Id, Ownership__c, Owner.Employee_ID__c, Owner.RC_Code__c, Owner.AH_RC_Code__c, Owner.NH_RC_Code__c, Previous_Owner__c, Previous_Owner__r.Employee_ID__c, Previous_Owner__r.RC_Code__c, Previous_Owner__r.AH_RC_Code__c, Previous_Owner__r.NH_RC_Code__c FROM Account';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accountList) {
   		Set<Id> accountIds = new Set<Id>();
   		for(Account eachAccount : accountList) {
   			accountIds.add(eachAccount.Id);
   		}
   		List<Year_End_Assignment__c> yearEndList = [SELECT Id, CIS_ID__c, Final_Assigned_RM__c, Final_Assigned_RM__r.Employee_ID__c, Final_Assigned_RM__r.RC_Code__c, Final_Assigned_RM__r.AH_RC_Code__c, Final_Assigned_RM__r.NH_RC_Code__c FROM Year_End_Assignment__c WHERE CIS_ID__c IN :accountIds];
   		Map<Id, Year_End_Assignment__c> yearEndMapByCIS = new Map<Id, Year_End_Assignment__c>();
   		for(Year_End_Assignment__c eachYearEnd : yearEndList) {
   			if(eachYearEnd.CIS_ID__c != null && eachYearEnd.Final_Assigned_RM__c != null)
   				yearEndMapByCIS.put(eachYearEnd.CIS_ID__c, eachYearEnd);
   		}

   		Year_End_Assignment__c tempYearEnd;
		for(Account eachAccount : accountList) {
			if(yearEndMapByCIS.containsKey(eachAccount.Id)) {
				tempYearEnd = yearEndMapByCIS.get(eachAccount.Id);
			}

			if(eachAccount.Ownership__c != null && eachAccount.Ownership__c == GlobalConstants.OWNERSHIP_PERMANENT) {
				eachAccount.Permanent_Owner_Extension__c = userExtMapByEmpId.get(eachAccount.Owner.Employee_ID__c);
				eachAccount.Permanent_AH_Name__c = teamMapByRc.get(eachAccount.Owner.AH_RC_Code__c);
				eachAccount.Permanent_NH_Name__c = teamMapByRc.get(eachAccount.Owner.NH_RC_Code__c);
				eachAccount.Permanent_Team_Name__c = teamMapByRc.get(eachAccount.Owner.RC_Code__c);
			} else {
				eachAccount.Permanent_Owner_Extension__c = (tempYearEnd != null) ? userExtMapByEmpId.get(tempYearEnd.Final_Assigned_RM__r.Employee_ID__c) : userExtMapByEmpId.get(eachAccount.Previous_Owner__r.Employee_ID__c);
				eachAccount.Permanent_AH_Name__c = (tempYearEnd != null) ? teamMapByRc.get(tempYearEnd.Final_Assigned_RM__r.AH_RC_Code__c) : teamMapByRc.get(eachAccount.Previous_Owner__r.AH_RC_Code__c);
				eachAccount.Permanent_NH_Name__c = (tempYearEnd != null) ? teamMapByRc.get(tempYearEnd.Final_Assigned_RM__r.NH_RC_Code__c) : teamMapByRc.get(eachAccount.Previous_Owner__r.NH_RC_Code__c);
				eachAccount.Permanent_Team_Name__c = (tempYearEnd != null) ? teamMapByRc.get(tempYearEnd.Final_Assigned_RM__r.RC_Code__c) : teamMapByRc.get(eachAccount.Previous_Owner__r.RC_Code__c);
			}
			
			eachAccount.Ownership_Text__c = eachAccount.Ownership__c;

			eachAccount.Previous_Owner_Extension__c = userExtMapByEmpId.get(eachAccount.Previous_Owner__r.Employee_ID__c);
			eachAccount.Previous_AH_Name__c = teamMapByRc.get(eachAccount.Previous_Owner__r.AH_RC_Code__c);
			eachAccount.Previous_NH_Name__c = teamMapByRc.get(eachAccount.Previous_Owner__r.NH_RC_Code__c);
			eachAccount.Previous_Team_Name__c = teamMapByRc.get(eachAccount.Previous_Owner__r.RC_Code__c);

			eachAccount.Current_Owner_Extension__c = userExtMapByEmpId.get(eachAccount.Owner.Employee_ID__c);
			eachAccount.Current_AH_Name__c = teamMapByRc.get(eachAccount.Owner.AH_RC_Code__c);
			eachAccount.Current_NH_Name__c = teamMapByRc.get(eachAccount.Owner.NH_RC_Code__c);
			eachAccount.Current_Team_Name__c = teamMapByRc.get(eachAccount.Owner.RC_Code__c);
		}

		update accountList;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}