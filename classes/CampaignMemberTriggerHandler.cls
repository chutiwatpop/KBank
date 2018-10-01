public with sharing class CampaignMemberTriggerHandler extends TriggerHandler {
	public override void beforeInsert() {
		Set<Id> contactIds = new Set<Id>();
		Set<Id> campaignIds = new Set<Id>();
		User currentUser = [SELECT Id,Profile.Name,Segment__c FROM User WHERE Id = :UserInfo.getUserId()];

		for (CampaignMember campMember : (List<CampaignMember>) Trigger.new) {
			if(campMember.CampaignId!=null){
				contactIds.add(campMember.ContactId);
				campaignIds.add(campMember.CampaignId);
			}
		}

		// Map Campaign Member Contact Id by Customer Name 
		Map<Id, Id> mapMemberContactByAccId = new Map<Id, Id>();
		List<Id> accountIds = new List<Id>();
		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Customer_Name__c, AccountId, Phone_Numbers__c FROM Contact WHERE Id IN :contactIds]);
		for (Contact eachContact : mapContacts.values()) {
			accountIds.add(eachContact.AccountId);
			mapMemberContactByAccId.put(eachContact.Id, eachContact.AccountId);
		}

		Map<String,Target_List__c> tglAccountAndCampaignString = new Map<String,Target_List__c>();
		for (Target_List__c tgl : [SELECT Id,CIS_ID_Prospect_Name__c,Lead_Campaign__c,Lead_Campaign__r.RecordType.DeveloperName FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :accountIds AND Lead_Campaign__c IN :campaignIds]) {
			if(tgl.CIS_ID_Prospect_Name__c!=null && tgl.Lead_Campaign__c!=null) {
				tglAccountAndCampaignString.put(tgl.CIS_ID_Prospect_Name__c+' '+tgl.Lead_Campaign__c,tgl);
			}
		}

		for (CampaignMember campMember : (List<CampaignMember>) Trigger.new) {
			if (currentUser.Profile.Name.contains('SME-') && !(campMember.ContactId!=null && campMember.CampaignId!=null && tglAccountAndCampaignString.containsKey(mapMemberContactByAccId.get(campMember.ContactId)+' '+campMember.CampaignId))) {
				campMember.addError(GlobalConstants.CANNOT_INSERT_CAMMEM);
			}
			if(campMember.ContactId != null && mapContacts.containsKey(campMember.ContactId)){
				campMember.Contact_Phone_Number__c = mapContacts.get(campMember.ContactId).Phone_Numbers__c;
			}
		}
	}
}