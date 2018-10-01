public with sharing class BudgetAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	private Map<Id, User_MaskModel> userMaskMapByUserId;

	public BudgetAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
		this.userMaskMapByUserId = userMaskMapByUserId;
	}

	public void execute(QueueableContext context) {
		List<Budget__c> budgetList = getObjectList();
		if(!budgetList.isEmpty()) {
			cancelChangedBudgetOwnership(budgetList);
		}
	}

	private void cancelChangedBudgetOwnership(List<Budget__c> budgetList) {
		List<Budget__c> cancelledBudgetList = new List<Budget__c>();
		for(Budget__c eachBudget : budgetList) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachBudget.OwnerId);
			if (userMask.isChangeToInactive || userMask.isChangeRCCode) {
				if(eachBudget.Stage__c == GlobalConstants.BUDGET_OPEN
				|| eachBudget.Stage__c == GlobalConstants.BUDGET_WAITING_FOR_APPROVE
				|| eachBudget.Stage__c == GlobalConstants.BUDGET_APPROVED
				|| eachBudget.Stage__c == GlobalConstants.BUDGET_COLLECT_DOCUMENT) {
					Budget__c cancelledBudget = new Budget__c();
					cancelledBudget.Id					= eachBudget.Id;
					cancelledBudget.Stage__c			= GlobalConstants.BUDGET_CANCELLED;
					cancelledBudget.recordTypeId		= convertToBudgetReadOnly(eachBudget.recordTypeId);
					// System.debug(GlobalUtility.getRecordTypeDevNameById(cancelledBudget.recordTypeId));
					cancelledBudgetList.add(cancelledBudget);
				}
			}
		}
		TriggerHandler.bypass('BudgetTriggerHandler');
			update cancelledBudgetList;
		TriggerHandler.clearBypass('BudgetTriggerHandler');
	}

	private static Id convertToBudgetReadOnly(Id recTypeId) {
		String recTypeDevName = GlobalUtility.getRecordTypeDevNameById(recTypeId);
		if(recTypeDevname.contains('Transfer')) recTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME);
		else if(recTypeDevname.contains('Request')) recTypeId = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_READ_ONLY_DEVNAME);
		return recTypeId;
	}

	public override List<SObject> getObjectList() {
		List<Budget__c> budgetList = new List<Budget__c>();
		budgetList = [SELECT Id, Stage__c, OwnerId, recordTypeId FROM Budget__c
			WHERE OwnerId IN :userMaskMapByUserId.keySet() AND Budget_ParentId__c = null];
		return budgetList;
	}
}