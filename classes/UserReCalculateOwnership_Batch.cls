public without sharing class UserReCalculateOwnership_Batch implements Database.Batchable<sObject> {
	@TestVisible
	private static Boolean doChainJob = true;
	String query;
	
	public UserReCalculateOwnership_Batch() {
		this.query = 'SELECT Id, Name, FirstName, LastName, Segment__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, IsActive, Profile.Name FROM User WHERE Pending_for_Ownership_Calculation__c = true';
	}

	public UserReCalculateOwnership_Batch(String queryCondition) {
		this.query = 'SELECT Id, Name, FirstName, LastName, Segment__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, IsActive, Profile.Name FROM User' + queryCondition;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<User> scope) {
        Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
        for(User eachUser : scope) {
            User_MaskModel eachUserMask = new User_MaskModel();
            eachUserMask.isReCalculateOwnership = true;
            eachUserMask.setNewUser(eachUser);
            eachUserMask.setOldUser(eachUser);
            userMaskMapByUserId.put(eachUser.Id, eachUserMask);
            eachUser.Pending_for_Ownership_Calculation__c = false;
        }
        if(doChainJob) {
        	System.enqueueJob(new ApprovalAssignmentQueue(userMaskMapByUserId));
        }
        TriggerHandler.bypass('UserTriggerHandler');
        update scope;
        TriggerHandler.clearBypass('UserTriggerHandler');
	}
	
	public void finish(Database.BatchableContext BC) {
		
	}
	
}