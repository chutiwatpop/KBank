public with sharing class Opportunity_OverrideListView_Controller {
	public PageReference redirectToListView(){
		PageReference pageRef;
		User targetUser = [SELECT Id, Profile.Name,Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
		List<User_Mirror_Management__c> userMirrorManagements = [SELECT Employee_ID__c FROM User_Mirror_Management__c WHERE Employee_ID__c = :targetUser.Employee_ID__c];

		if(((String)targetUser.Profile.Name).contains('CBS')||(!userMirrorManagements.isEmpty())) {
			pageRef = new PageReference('/apex/Opportunity_Custom_Page');	
		} else {
			Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
	        String keyPrefix = r.getKeyPrefix();
	        pageRef = new PageReference('/'+keyPrefix);	
		}
        return pageRef;
    }
}