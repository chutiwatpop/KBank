public with sharing class TeamStructureSelector {
	Schema.SObjectType sObjectType;

	public TeamStructureSelector() {
		this.sObjectType = Team_Structure__c.sObjectType;
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return GlobalUtility.getAllCreatableSchemaSObjectFields(sObjectType);
	}

	public List<Team_Structure__c> selectByIds(Set<Id> idSet) {
		List<Team_Structure__c> teamStructureList = (List<Team_Structure__c>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id IN :idSet').toSOQL());
		return teamStructureList;
	}

	public Team_Structure__c selectById(Id queryId) {
		List<Team_Structure__c> teamStructureList = (List<Team_Structure__c>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('Id = :queryId').toSOQL());
		return (!teamStructureList.isEmpty()) ? teamStructureList[0] : null;
	}

	public Team_Structure__c selectByRCCode(String rcCode) {
		List<Team_Structure__c> teamStructureList = (List<Team_Structure__c>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).setCondition('RC_Code__c = :rcCode').toSOQL());
		return (!teamStructureList.isEmpty()) ? teamStructureList[0] : null;
	}

	public List<Team_Structure__c> selectAllTeamStructure() {
		List<Team_Structure__c> teamStructureList = (List<Team_Structure__c>) Database.query(new QueryBuilder(sObjectType).selectFields(getSObjectFieldList()).toSOQL());
		return teamStructureList;
	}

	public Map<String, Team_Structure__c> getAllTeamStructureMapByRCCode(){
		List<Team_Structure__c> teamStructureList = this.selectAllTeamStructure();
		Map<String, Team_Structure__c> teamStructureMapByRCCode = new Map<String, Team_Structure__c>(teamStructureList);
		for(Team_Structure__c eachTeam : teamStructureList) {
			if(eachTeam.RC_Code__c != null) {
				teamStructureMapByRCCode.put(eachTeam.RC_Code__c, eachTeam);
			}
		}
		return teamStructureMapByRCCode;
	}
}