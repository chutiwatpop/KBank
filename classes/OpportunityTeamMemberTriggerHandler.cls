public class OpportunityTeamMemberTriggerHandler extends TriggerHandler {

    public override void afterDelete() {
        List<OpportunityTeamMember> oppTeams = ((List<OpportunityTeamMember>) Trigger.old);
        Set<Id> teamMemberIdSet = new Set<Id>();

        for(OpportunityTeamMember eachTeamMember:oppTeams){
            teamMemberIdSet.add(eachTeamMember.OpportunityId);
        }
        Map<Id, Opportunity> oppName =  new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN :teamMemberIdSet]);
        for(OpportunityTeamMember eachTeamMember:oppTeams){
            String msg = System.Label.Job_Removed_Job_Team +' '+ oppName.get(eachTeamMember.OpportunityId).Name;
            if(!Test.isRunningTest()) {
                GlobalUtility.createBellNotification(eachTeamMember.UserId, eachTeamMember.UserId, msg);
            }
        }
        unFlagHasJobTeamMember(teamMemberIdSet,oppTeams);
    }

    public override void afterInsert(){
        List<OpportunityTeamMember> oppTeams = ((List<OpportunityTeamMember>) Trigger.new);
        List<Id> possibleUserExtensionListId = new List<Id>();
        Map<Id,Opportunity> mapUpdateOpp = new Map<Id,Opportunity>();
        Map<Id,User_Extension__c> userExtensionMapUserId = new Map<Id,User_Extension__c>();
        List<OpportunityTeamMember> updateOpportunityTeamMemberList = new List<OpportunityTeamMember>();

        for(OpportunityTeamMember teamMember: oppTeams) {
            mapUpdateOpp.put(teamMember.OpportunityId,new Opportunity(Id = teamMember.OpportunityId, HasJobTeamMember__c = true));
            possibleUserExtensionListId.add(teamMember.UserId);
        }
        userExtensionMapUserId = UserExtension_Service.getUserExtensionMapByUserId(possibleUserExtensionListId);
        for(OpportunityTeamMember eachOpportunityTeamMember : ((List<OpportunityTeamMember>) Trigger.new)){
            if(userExtensionMapUserId.containsKey(eachOpportunityTeamMember.UserId)){
                updateOpportunityTeamMemberList.add(new OpportunityTeamMember(Id = eachOpportunityTeamMember.Id, User_Extension__c = userExtensionMapUserId.get(eachOpportunityTeamMember.UserId).Id));
            }
        }

        if(mapUpdateOpp.values().size() > 0) update mapUpdateOpp.values();
        if(updateOpportunityTeamMemberList.size() > 0) update updateOpportunityTeamMemberList;
    }

    private void unFlagHasJobTeamMember(Set<Id> teamMemberIdSet,List<OpportunityTeamMember> listOpportunityTeamMember){
        List<AggregateResult> groupOppTeams = [SELECT OpportunityId,Count(Id) CountOppMember FROM OpportunityTeamMember WHERE OpportunityId IN :teamMemberIdSet GROUP BY OpportunityId HAVING Count(Id) > 0];
        Map<Id,Opportunity> mapUpdateOpp = new Map<Id,Opportunity>();
        Map<Id,Integer> mapNumberOfMemberInOppByOppId = new Map<Id,Integer>();
        for(AggregateResult eachGroup : groupOppTeams){
            mapNumberOfMemberInOppByOppId.put((Id)eachGroup.get('OpportunityId'), (Integer)eachGroup.get('CountOppMember'));
        }

        for(OpportunityTeamMember eachOpportunityTeamMember : listOpportunityTeamMember){
            if(!mapNumberOfMemberInOppByOppId.containsKey(eachOpportunityTeamMember.OpportunityId)){
                mapUpdateOpp.put(eachOpportunityTeamMember.OpportunityId,new Opportunity(Id=eachOpportunityTeamMember.OpportunityId, HasJobTeamMember__c = false));
            }
        }

        if(mapUpdateOpp.values().size() > 0) update mapUpdateOpp.values();
    }
}