global class SME_BatchCreateLeadSharing implements Database.Batchable<sObject>,Database.Stateful {
	private String query;
	private Boolean isUpdateCampaign;
	private Map<Id,Campaign> mapUpdateCampaignInfo;

	global SME_BatchCreateLeadSharing(List<Id> listTargetListId) {
    	this.query = 'SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,Lead_Campaign__r.EndDate,End_Date__c,Lead_Campaign__c,Share_With__r.IsActive FROM Target_List__c WHERE Id IN (\'' + String.join(listTargetListId,'\',\'') + '\')';
    }

    global SME_BatchCreateLeadSharing(List<Id> listCampaignId,Boolean isUpdateCampaignInfo) {
    	this.isUpdateCampaign = isUpdateCampaignInfo;
    	this.query = 'SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,Lead_Campaign__r.EndDate,End_Date__c,Lead_Campaign__c,Share_With__r.IsActive FROM Target_List__c WHERE Lead_Campaign__c IN (\'' + String.join(listCampaignId,'\',\'') + '\')';
    }
    
    global SME_BatchCreateLeadSharing(Map<Id,Campaign> mapUpdateCampaignInfo,Boolean isUpdateCampaignInfo) {
    	this.isUpdateCampaign = isUpdateCampaignInfo;
    	this.mapUpdateCampaignInfo = mapUpdateCampaignInfo;
    	List<Id> listCampaignId = new List<Id>(mapUpdateCampaignInfo.keySet());
    	this.query = 'SELECT Id,CIS_ID_Prospect_Name__c,CIS_ID_Prospect_Name__r.OwnerId,CIS_ID_Prospect_Name__r.Share_With__c,Share_With__c,Lead_Type__c,Lead_Subtype__c,Lead_Sharing__c,Lead_Status__c,Lead_Campaign__r.EndDate,End_Date__c,Lead_Campaign__c,Share_With__r.IsActive FROM Target_List__c WHERE Lead_Campaign__c IN (\'' + String.join(listCampaignId,'\',\'') + '\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	System.debug('query = '+query);
        System.debug('isUpdateCampaign = '+isUpdateCampaign);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Target_List__c> listTargetListWithInfo) {
    	if(this.isUpdateCampaign != null){
	    	if(this.isUpdateCampaign){
	    		ManageSharing_Service.updateAccountInfoFromCampaignInfo(listTargetListWithInfo,mapUpdateCampaignInfo);
	    	}else{
	        	ManageSharing_Service.createAccountShareFromActiveCampaign(listTargetListWithInfo);
	        }
	    }else{
	    	ManageSharing_Service.calculateCreateAccountShareFromGoodToBad(listTargetListWithInfo);
	    }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}