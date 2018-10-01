public class BudgetTriggerHandler extends TriggerHandler {

	public override void beforeInsert() {
		BudgetService.stampInsertedMainBudget((List<Budget__c>) Trigger.new);
	}

	public override void beforeUpdate() {
		BudgetService.checkBudgetSubmissionAndStampRecordType((List<Budget__c>) Trigger.new, (Map<Id, Budget__c>) Trigger.oldMap);
	}

	public override void afterUpdate() {
		BudgetService.createNewItemBudget((Map<Id, Budget__c>) Trigger.newMap, (Map<Id, Budget__c>) Trigger.oldMap);
		BudgetService.clearAndStampMainBudgetFieldAfterCreateItemBudget((List<Budget__c>) Trigger.new, (Map<Id, Budget__c>) Trigger.oldMap);
		BudgetService.updateItemBudgetInfo((List<Budget__c>) Trigger.new, (Map<Id, Budget__c>) Trigger.oldMap);
	}

	public override void beforeDelete() {
		BudgetService.deleteBudget((List<Budget__c>) Trigger.old);
	}
}