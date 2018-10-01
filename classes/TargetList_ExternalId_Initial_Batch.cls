global class TargetList_ExternalId_Initial_Batch implements Database.Batchable<sObject> {
	
	String query;
	String campaignNewBookingCode;
	String campaignThankyouCode;
	
	global TargetList_ExternalId_Initial_Batch() {
		Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
        campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        campaignThankyouCode = campaignSetting.ThankYou_Code__c;

		query = 'SELECT Id, CIS_ID_Prospect_Name__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, External_ID__c FROM Target_List__c WHERE External_ID_CDB__c = null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Target_List__c> scope) {
		for(Target_List__c eachTarget : scope) {
			if(eachTarget.Lead_Campaign__r.Lead_Campaign_Event_Code__c == campaignNewBookingCode || eachTarget.Lead_Campaign__r.Lead_Campaign_Event_Code__c == campaignThankyouCode) {
				// Not concat
			} else {
				eachTarget.External_ID__c = eachTarget.Lead_Campaign__r.Lead_Campaign_Event_Code__c + ':' + eachTarget.CIS_ID_Prospect_Name__c;
                eachTarget.External_ID_CDB__c = eachTarget.Lead_Campaign__r.Lead_Campaign_Event_Code__c + ':' + eachTarget.CIS_ID_Prospect_Name__c;
			}
		}

		TriggerHandler.bypass('TargetListTriggerHandler');
		update scope;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
	}
	
	global void finish(Database.BatchableContext BC) {}
	
}