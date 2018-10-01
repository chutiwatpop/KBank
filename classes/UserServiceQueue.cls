public class UserServiceQueue implements Queueable {

	private Map<Id,User_MaskModel> userMaskMapByUserId;
	public UserServiceQueue(Map<Id,User_MaskModel> userMaskMapByUserId) {
		this.userMaskMapByUserId = userMaskMapByUserId;
	}

	public void execute(QueueableContext context) {
		List<Team_Structure__c> teamStructures = [SELECT Id, RC_Code__c, OwnerId, Province__c, Segment__c, AH_Name__c, AH_Name__r.OwnerId, NH_Name__c, NH_Name__r.OwnerId FROM Team_Structure__c WHERE Acting_Flag__c = false];
        List<User_Extension__c> userExtensions = [SELECT Id, User__c, OwnerId FROM User_Extension__c WHERE User__c IN :userMaskMapByUserId.keySet()];
        Map<String, Team_Structure__c> teamMapByRcCode = new Map<String, Team_Structure__c>();
        Map<Id, List<Team_Structure__c>> teamMapByOwnerId = new Map<Id, List<Team_Structure__c>>();
        Map<String, User_Extension__c> userExtMapByUser = new Map<String, User_Extension__c>();
        
        for(Team_Structure__c eachTeam : teamStructures) {
        	if(eachTeam.RC_Code__c != null) {
        		teamMapByRcCode.put(eachTeam.RC_Code__c, eachTeam);
        	}
        	if(!teamMapByOwnerId.containsKey(eachTeam.OwnerId)) {
        		teamMapByOwnerId.put(eachTeam.OwnerId, new List<Team_Structure__c>());
        	}
        	teamMapByOwnerId.get(eachTeam.OwnerId).add(eachTeam);
        }
        for(User_Extension__c eachExtension : userExtensions) {
        	if(eachExtension.User__c != null) {
	            userExtMapByUser.put(eachExtension.User__c, eachExtension);
	        }
        }

        Map<Id, Team_Structure__c> updateTeamMap 	= new Map<Id, Team_Structure__c>();
        List<User_Extension__c> updateUserExtList 	= new List<User_Extension__c>();
        Map<Id, User_MaskModel> targetUserMaskMap 	= new Map<Id, User_MaskModel>();
		for(Id userId : userMaskMapByUserId.keySet()) {
			User_MaskModel userMask = userMaskMapByUserId.get(userId);
			User eachUser = userMask.getNewUser();
			// Update Team Structure owner
			if(teamMapByOwnerId.containsKey(userId) && 
				(userMask.isChangeTeamHierachy || userMask.isChangeToInactive)) {
				for(Team_Structure__c eachTeam : teamMapByOwnerId.get(userId)) {
					updateTeamMap.put(eachTeam.Id, eachTeam);
				}
			} else if(eachUser.RC_Code__c != null && teamMapByRcCode.containsKey(eachUser.RC_Code__c) && 
				(userMask.isChangeTeamHierachy || userMask.isChangeToInactive || userMask.isChangeToActive)) {
				updateTeamMap.put(teamMapByRcCode.get(eachUser.RC_Code__c).Id, teamMapByRcCode.get(eachUser.RC_Code__c));
			}

			// Update User Extension
			if(userExtMapByUser.containsKey(userId)) {
               	User_Extension__c userExt = userExtMapByUser.get(userId);
				if(userMask.isChangeRCCode) {
					userExt.Team_Structure__c = teamMapByRcCode.containsKey(eachUser.RC_Code__c) ? teamMapByRcCode.get(eachUser.RC_Code__c).Id : null;
				} 
				if(userMask.isChangeName) {
					userExt.Name = (eachUser.FirstName != null) ? (eachUser.FirstName + ' ' + eachUser.LastName) : eachUser.LastName;
				}
				if(userMask.isChangeSegment) {
					userExt.Segment_Text__c = eachUser.Segment__c;
				}
				if(userMask.isChangeToActive && userExt.OwnerId != userId) {
					userExt.OwnerId = userId;
				}
				updateUserExtList.add(userExt);
			}

			if(userMask.isChangeTeamHierachy || userMask.isChangeToInactive || userMask.isChangeToActive) {
                if(!userMask.isReCalculateOwnership) {
                	targetUserMaskMap.put(userMask.userId, userMask);
                }
            }
		}
        calculateTeamOwner(updateTeamMap.values());
        TriggerHandler.bypass('UserExtensionTriggerHandler');
        update updateUserExtList;
        TriggerHandler.clearBypass('UserExtensionTriggerHandler');
        if(!Test.isRunningTest()) {
        	if(!targetUserMaskMap.isEmpty())
	        	System.enqueueJob(new OwnershipAssignment_Queue(targetUserMaskMap));
	    }
	}

	private void calculateTeamOwner(List<Team_Structure__c> updateTeamList) {
		UserService.calculateTeamOwner(updateTeamList);
	}
}