global class SME_SyncLeadToCDB implements Schedulable {

	global void execute(SchedulableContext sc) {
        // Call Webservice
        syncLeadToCDB();
	}

    @future(callout=true)
    public static void syncLeadToCDB(){
        CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
        CIBaseResponseModel responseModel = webServiceInstance.syncLeadToCDBWebservice();
        System.debug('responseModel:'+responseModel);
    }
}