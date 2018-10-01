global class SME_PurgeLead_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{
	
	String query;
	String numberOfPurgeDays;
	
	global SME_PurgeLead_Batch() {
		initialParameter(System.Label.Lead_NumberOfPurgeDays);
	}

	global SME_PurgeLead_Batch(String numberOfPurgeDays) {
		this.numberOfPurgeDays = numberOfPurgeDays;
		initialParameter(numberOfPurgeDays);
	}

	private void initialParameter(String numberOfPurgeDays){
		this.numberOfPurgeDays = numberOfPurgeDays;
		Date lastEndDate = System.today() - Integer.valueof(numberOfPurgeDays);
		Datetime purgeDateTime = Datetime.newInstance(lastEndDate.year(), lastEndDate.month(), lastEndDate.day());
		String dateTimeFormat = purgeDateTime.format('yyyy-MM-dd');
		this.query = 'SELECT Id FROM Campaign WHERE EndDate < ' + dateTimeFormat +' AND RecordType.Name NOT IN (\''+Globalconstants.SME_EVENT+'\',\''+Globalconstants.SME_EVENT_NON_TARGET+'\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC,List<Campaign> listCampaign) {
		delete listCampaign;
	}
	
	global void finish(Database.BatchableContext BC) {
		try {
            // Call Webservice
            CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
            CIBaseResponseModel responseModel = webServiceInstance.purgeLeadWebservice(this.numberOfPurgeDays);
        } catch (Exception e) {
            System.debug('Exception:' + e);
            GlobalUtility.logMessage('ERROR','SME_PurgeLead_Batch','purgeLead',null,null,e.getMessage(),null,e,null);
        }
	}
	
}