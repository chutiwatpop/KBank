public with sharing class UserManagementQueue implements Queueable {
	String segment;
	String teamType;
	public UserManagementQueue(String segment, String teamType) {
		this.segment 	= segment;
		this.teamType 	= teamType;
	}

	public void execute(QueueableContext context) {
		List<Team_Structure__c> teamList = [SELECT Id, RC_Code__c, External_Id__c, Segment__c 
											FROM Team_Structure__c 
											WHERE Segment__c = :segment AND Type__c = :teamType];
		Set<String> teamRCCodes = new Set<String>();
		for(Team_Structure__c eachTeam : teamList) {
			if(eachTeam.RC_Code__c != eachTeam.External_Id__c ||
				eachTeam.RC_Code__c == null) {
				continue;
			}
			teamRCCodes.add(eachTeam.RC_Code__c);
		}
		List<User_Structure__c> hrisUserList = [SELECT Id, Name, Team_Name__c, Email__c, First_Name__c, Last_Name__c, Segment__c, Job_Code__c, Status__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Effective_Date__c, Username__c 
													 FROM User_Structure__c 
													 WHERE RC_Code__c IN :teamRCCodes];

		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, ManagerId, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c, Area_Name__c, Network_Name__c 
													 FROM User 
													 WHERE RC_Code__c IN :teamRCCodes]);

	}
}