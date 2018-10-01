public class ContentDocumentTriggerHandler extends TriggerHandler {

	public override void allAfter() {
		if(!Trigger.isDelete) {
			Id profileId = userInfo.getProfileId();
			String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;
			Map<Id, ContentDocument> contentDocMapById = (Map<Id, ContentDocument>) Trigger.newMap;
			Set<Id> ContentDocIdSet = contentDocMapById.keySet();

			List<ContentDocumentLink> contentDocLinkList = [
				SELECT Id, LinkedEntityId, LinkedEntity.type, ContentDocumentId
				FROM ContentDocumentLink
				WHERE ContentDocumentId IN :ContentDocIdSet
			];

			Map<Id, ContentDocumentLink> documentLinkMapByBudgetId = new Map<Id, ContentDocumentLink>();
			for(ContentDocumentLink contentDocLink : contentDocLinkList) {
				if(contentDocLink.LinkedEntityId.getSObjectType() == Budget__c.SObjectType) {
					documentLinkMapByBudgetId.put(contentDocLink.LinkedEntityId, contentDocLink);
				}
			}

			List<Budget__c> attachedBudgetList = [
				SELECT Id, recordTypeId, stage__c, OwnerId
				FROM Budget__c
				WHERE Id IN :documentLinkMapByBudgetId.keySet()
			];

			for(Budget__c attachedBudget : attachedBudgetList) {
				if((!(attachedBudget.Stage__c == GlobalConstants.BUDGET_OPEN || attachedBudget.Stage__c == GlobalConstants.BUDGET_INCORRECT || attachedBudget.Stage__c == GlobalConstants.BUDGET_COLLECT_DOCUMENT) && userInfo.getUserId() == attachedBudget.OwnerId) 
					|| (!Label.Profile_can_delete_budget.contains(profileName)
						&& userInfo.getUserId() != attachedBudget.OwnerId)) {
					contentDocMapById.get(documentLinkMapByBudgetId.get(attachedBudget.Id).ContentDocumentId).addError(Label.NotAllowAddDeleteFile);
				}
			}
		}
	}

	public override void beforeDelete() {	
		Id profileId = userInfo.getProfileId();
		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;	
		Map<Id, ContentDocument> contentDocMapById = (Map<Id, ContentDocument>) Trigger.oldMap;
		Set<Id> ContentDocIdSet = contentDocMapById.keySet();

		List<ContentDocumentLink> contentDocLinkList = [
			SELECT Id, LinkedEntityId, LinkedEntity.type, ContentDocumentId
			FROM ContentDocumentLink
			WHERE ContentDocumentId IN :ContentDocIdSet
		];

		Map<Id, ContentDocumentLink> documentLinkMapByBudgetId = new Map<Id, ContentDocumentLink>();
		for(ContentDocumentLink contentDocLink : contentDocLinkList) {
			if(contentDocLink.LinkedEntityId.getSObjectType() == Budget__c.SObjectType) {
				documentLinkMapByBudgetId.put(contentDocLink.LinkedEntityId, contentDocLink);
			}
		}

		List<Budget__c> attachedBudgetList = [
			SELECT Id, recordTypeId, Stage__c, OwnerId
			FROM Budget__c
			WHERE Id IN :documentLinkMapByBudgetId.keySet()
		];

		for(Budget__c attachedBudget : attachedBudgetList) {
			if((!(attachedBudget.Stage__c == GlobalConstants.BUDGET_OPEN || attachedBudget.Stage__c == GlobalConstants.BUDGET_INCORRECT || attachedBudget.Stage__c == GlobalConstants.BUDGET_COLLECT_DOCUMENT) && userInfo.getUserId() == attachedBudget.OwnerId) 
				|| (!Label.Profile_can_delete_budget.contains(profileName)
					&& userInfo.getUserId() != attachedBudget.OwnerId)) {
				contentDocMapById.get(documentLinkMapByBudgetId.get(attachedBudget.Id).ContentDocumentId).addError(Label.NotAllowAddDeleteFile);
			}
		}
	}
}