public with sharing class OwnershipAssignment_Queue implements Queueable  {
	@TestVisible
	private static Boolean doChainJob = true;
	private Boolean isFromBulkAssignment = false;
	private Map<Id,User_MaskModel> inActiveOrChangeTeamUserMaskMapByUserId;
	private BulkAssignmentManager bulkManager;
	public OwnershipAssignment_Queue(Map<Id,User_MaskModel> inActiveOrChangeTeamUserMaskMapByUserId) {
		this.inActiveOrChangeTeamUserMaskMapByUserId = inActiveOrChangeTeamUserMaskMapByUserId;
		bulkManager = new BulkAssignmentManager(inActiveOrChangeTeamUserMaskMapByUserId);
		bulkManager.createBulkAssignment();
		bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
	}

	public OwnershipAssignment_Queue(List<Bulk_Assignment_Queue__c> bulkAssignmentQueue){
		this.isFromBulkAssignment = true;
		bulkManager = new BulkAssignmentManager(bulkAssignmentQueue);
		
	}

	public void execute(QueueableContext context) {
		Account_Service.resetAllFlagOwnership();
		if(isFromBulkAssignment){
			Account_Service.isBulk = true;
			OwnershipAssignment_Queue.doChainJob = false;
		}else{
			Account_Service.isHRIS = true;
		}
		bulkManager.setAccountInfoFromBulkInfo();
		bulkManager.updateAccount();
		bulkManager.completeJobUpdateBulkQueueAndBulkAssignmentStatus();

		//to be refactor
		List<Bulk_Assignment__c> bulkAssignments = bulkManager.getBulkAssignments();
		Map<Id,Account> accountSMETempUpdateMap = new Map<Id,Account>();
		for(Bulk_Assignment__c eachAssignment : bulkAssignments){
			if(eachAssignment.SME_Temporary_Customer__c != null){
                	Account eachTempAccount = new Account(Id = eachAssignment.CIS_ID__c,OwnerId= eachAssignment.SME_Temporary_Customer__c);
					accountSMETempUpdateMap.put(eachTempAccount.Id,eachTempAccount);
				}
		}
		if(!accountSMETempUpdateMap.isEmpty()){
			AccountChangeOwner accountService = new AccountChangeOwner();
			System.debug('Debug -- accountSMETempUpdateMap ::'+accountSMETempUpdateMap);
			Map<Id,User_Extension__c> possibleUserExtension = accountService.getUserExtensionMapWithUserId(accountSMETempUpdateMap,null);
			System.debug('Debug -- possibleUserExtension ::'+possibleUserExtension);
			accountService.closeTempOwnerEvent(accountSMETempUpdateMap);
	        accountService.changeAllOpenJob(accountSMETempUpdateMap, possibleUserExtension);
    	}
    	//to be refactor
		if(doChainJob && GlobalUtility.isApexClassConfigActive('ApprovalAssignmentQueue')) {
        	System.enqueueJob(new ApprovalAssignmentQueue(inActiveOrChangeTeamUserMaskMapByUserId));
        }
	}
}