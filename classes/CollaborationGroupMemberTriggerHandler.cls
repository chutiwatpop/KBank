public class CollaborationGroupMemberTriggerHandler extends TriggerHandler{

	private Map<String, Team_Structure__c> mapTeamStructureMapByName;
	private Map<String, CollaborationGroup> mapCollaborationGroupMapById;

	public override void allBefore(){
		if(mapTeamStructureMapByName == null){
			List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
	        teamStructureList = [SELECT Id, External_ID__c,RC_Code__C, OwnerId, Segment__c, Name, Type__c,NH_RC_Code__c FROM Team_Structure__c];
	        mapTeamStructureMapByName = new Map<String, Team_Structure__c>();

	        for(Team_Structure__c eachTeam : teamStructureList) {
	            mapTeamStructureMapByName.put(eachTeam.Name, eachTeam);
	        }
		}

		if(mapCollaborationGroupMapById == null){
			mapCollaborationGroupMapById = new Map<String, CollaborationGroup>([SELECT Id,Name FROM CollaborationGroup]);
		}
	}

	public override void beforeInsert() {
        for(CollaborationGroupMember eachMember : (List <CollaborationGroupMember>)Trigger.new){
        	String groupName = mapCollaborationGroupMapById.get(eachMember.CollaborationGroupId).Name;
        	if(isGroupNameConvertedFromConfig(groupName) || isGroupNameCreatedFromTeamStructureNameWithoutConvert(groupName)){
        		if(eachMember.CollaborationRole == 'Standard'){
    				eachMember.NotificationFrequency = Chatter_Group_Email_Noti__c.getValues('Member').NotificationFrequency__c;
    			}
        	}
        }
    }

    private Boolean isGroupNameConvertedFromConfig(String groupName){
    	for(Chatter_Group_Name__c replaceGroupName : Chatter_Group_Name__c.getall().values()){
    		if(groupName.contains(replaceGroupName.Name)){
    			return true;
    		}
    	}
    	return false;
    }

    private Boolean isGroupNameCreatedFromTeamStructureNameWithoutConvert(String groupName){
    	if(mapTeamStructureMapByName.containsKey(groupName)){
    		if(mapTeamStructureMapByName.get(groupName).Type__c == 'Network'){
    			return true;
    		}
    	}
    	return false;
    }
}