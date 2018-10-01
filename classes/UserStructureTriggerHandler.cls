public class UserStructureTriggerHandler extends TriggerHandler{
	public override void beforeInsert() {
		Organization orgInfo = [SELECT IsSandbox FROM Organization];
		if(orgInfo.IsSandbox){
	        for(User_Structure__c eachUserStructure : (List<User_Structure__c>) Trigger.new){
	        	if(eachUserStructure.Email__c != null){
	            	eachUserStructure.Email__c = eachUserStructure.Email__c + Label.SANDBOX_EMAIL_SUFFIX;
	            }
	        }
	    }
    }
}