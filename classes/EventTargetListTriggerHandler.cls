public with sharing class EventTargetListTriggerHandler extends TriggerHandler {
	private Set<Id> campIds;
	private Set<Id> accountIds;

	public override void allBefore() {
		campIds = new Set<Id>();
		accountIds = new Set<Id>();
	}	

	public override void beforeInsert() {
		for(Event_Target_List__c eachEventTarget : (List<Event_Target_List__c>) Trigger.new) {
			if(eachEventTarget.Event_Name__c != null) {
				campIds.add(eachEventTarget.Event_Name__c);
			}
			accountIds.add(eachEventTarget.CIS_ID_Prospect_Name__c);
		}
		if(!campIds.isEmpty()) concatExternalId();
	}

	public override void beforeUpdate() {
		Event_Target_List__c oldRecord;
		for(Event_Target_List__c eachEventTarget : (List<Event_Target_List__c>) Trigger.new) {
			oldRecord = (Event_Target_List__c) Trigger.oldMap.get(eachEventTarget.Id);
			if(eachEventTarget.Event_Name__c != oldRecord.Event_Name__c || eachEventTarget.CIS_ID_Prospect_Name__c != oldRecord.CIS_ID_Prospect_Name__c) {
				campIds.add(eachEventTarget.Event_Name__c);
				accountIds.add(eachEventTarget.CIS_ID_Prospect_Name__c);
			}
		}
		if(!campIds.isEmpty()) concatExternalId();
	}

	public void concatExternalId() {
		Id RECORDTYPE_SME_CUSTOMER = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER);
		Id RECORDTYPE_SME_PROSPECT = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT);

		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, RecordTypeId, CIS__c FROM Account WHERE Id IN :accountIds]);
		Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign WHERE Id IN :campIds]);

		for(Event_Target_List__c eachEventTarget : (List<Event_Target_List__c>) Trigger.new) {
			if(accountMap.containsKey(eachEventTarget.CIS_ID_Prospect_Name__c) && campaignMap.containsKey(eachEventTarget.Event_Name__c)) {
				if(accountMap.get(eachEventTarget.CIS_ID_Prospect_Name__c).RecordTypeId == RECORDTYPE_SME_PROSPECT) {
					eachEventTarget.External_ID__c = campaignMap.get(eachEventTarget.Event_Name__c).Lead_Campaign_Event_Code__c + '' + accountMap.get(eachEventTarget.CIS_ID_Prospect_Name__c).Id;
				} else if(accountMap.get(eachEventTarget.CIS_ID_Prospect_Name__c).RecordTypeId == RECORDTYPE_SME_CUSTOMER) {
					eachEventTarget.External_ID__c = campaignMap.get(eachEventTarget.Event_Name__c).Lead_Campaign_Event_Code__c + '' + accountMap.get(eachEventTarget.CIS_ID_Prospect_Name__c).CIS__c;
				}
			}
		}
	}

	public override void beforeDelete() {
		String eventRecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.SME_EVENT);
        String nonRecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.SME_EVENT_NON_TARGET);

        Set<Id> deletedCampIds = new Set<Id>();
		for(Event_Target_List__c eachEventTarget : (List<Event_Target_List__c>) Trigger.old) {
			if(eachEventTarget.Event_Name__c != null)
				deletedCampIds.add(eachEventTarget.Event_Name__c);
		}
		Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, RecordTypeId FROM Campaign WHERE Id IN :deletedCampIds AND (RecordTypeId = :eventRecordTypeId OR RecordTypeId = :nonRecordTypeId)]);

        Map<Id, Profile> profileMap =  new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name=:GlobalConstants.SME_RM OR Name=:GlobalConstants.SME_TM OR Name=:GlobalConstants.SME_AH OR Name=:GlobalConstants.SME_NH OR Name=:GlobalConstants.SME_EVENT]);
		
		for(Event_Target_List__c eachEventTarget : (List<Event_Target_List__c>) Trigger.old) {
			if(campaignMap.containsKey(eachEventTarget.Event_Name__c)) {
				if(campaignMap.get(eachEventTarget.Event_Name__c).RecordTypeId == eventRecordTypeId && profileMap.containsKey(UserInfo.getProfileId()) && profileMap.get(UserInfo.getProfileId()).Name != GlobalConstants.SME_EVENT) {
					eachEventTarget.addError(profileMap.get(UserInfo.getProfileId()).Name + ' cannot delete ' + GlobalConstants.SME_EVENT);
				} else if (campaignMap.get(eachEventTarget.Event_Name__c).RecordTypeId == nonRecordTypeId && profileMap.containsKey(UserInfo.getProfileId()) && profileMap.get(UserInfo.getProfileId()).Name == GlobalConstants.SME_EVENT) {
					eachEventTarget.addError(profileMap.get(UserInfo.getProfileId()).Name + ' cannot delete ' + GlobalConstants.SME_EVENT_NON_TARGET);
				}
			}
		}

	}

}