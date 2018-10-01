global class CampaignActive_Batch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    List<Campaign> updateCam = new List<Campaign>();
    Map<String, Id> recordTypeIdMapByDevName;

    global CampaignActive_Batch(){
        recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign');
        this.query = 'SELECT Id,RecordTypeId,Status,IsActive FROM Campaign WHERE Status = \''+GlobalConstants.PLANNED+'\' And StartDate <= TODAY And RecordTypeId IN (\''+recordTypeIdMapByDevName.get(GlobalConstants.RBS_LEAD_DEVNAME)+'\',\''+recordTypeIdMapByDevName.get(GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME)+'\',\''+recordTypeIdMapByDevName.get(GlobalConstants.CBS_LEAD_DEVNAME)+'\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Campaign> listCampaign) {
    	for(Campaign eachCam : listCampaign){
    		CampaignLead_Service.setCampaignToActive(eachCam);
    		updateCam.add(eachCam);
    	}
    }
    
    global void finish(Database.BatchableContext BC) {
    	update updateCam;
    	Database.executeBatch(new CampaignChangeStatus_Batch());
    }
}