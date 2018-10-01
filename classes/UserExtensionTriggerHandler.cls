public without sharing class UserExtensionTriggerHandler extends TriggerHandler{
	public override void beforeUpdate() {
		User_Extension__c oldUserExt;
		Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>();

		for(User_Extension__c eachUserExt : (List<User_Extension__c>)Trigger.new) {
			oldUserExt = (User_Extension__c) Trigger.oldMap.get(eachUserExt.Id);
			if(eachUserExt.Team_Structure__c != null && eachUserExt.Team_Structure__c != oldUserExt.Team_Structure__c) {
				userExtMap.put(eachUserExt.Id,eachUserExt);
			}
		}

		if(!userExtMap.isEmpty()) {			
			UserExtension_Service.teamChange(userExtMap);
		}
	}

	public override void afterInsert(){
		List<User_Extension__c> newUserExtensionList = [SELECT Id,Employee_ID__c,Segment__c, User__r.Profile.Name, User__r.RC_Code__c, User__r.IsActive From User_Extension__c WHERE Id IN :Trigger.newMap.keySet()];
		BottomUp_Service.createSaleTargetForNewUserExtension(newUserExtensionList);
	}


	public override void afterfinally(){
		if(BottomUp_Service.globalSalesTargetForUpsert != null && BottomUp_Service.globalSalesTargetForUpsert.size() > 0){
             upsert BottomUp_Service.globalSalesTargetForUpsert External_ID__c;
             BottomUp_Service.globalSalesTargetForUpsert = null;
        }
        
	}


}