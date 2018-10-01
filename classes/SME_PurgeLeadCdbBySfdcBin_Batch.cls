//Purge Lead Issue_INC000000559537
global class SME_PurgeLeadCdbBySfdcBin_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	
	private final String CAMPAIGN_OBJECT_NAME = 'Campaign';
	private final String TARGET_LIST_OBJECT_NAME = 'Target_List';
	private String query;
	private String purgeObjectName;
	private Integer numberOfNextDay;
	private Integer numberOfLastDay;
	private Boolean isRunFirstTime;
	
	public class CustomOBject{
		List<String> externalIdCDB = new List<String>();
	}

	global SME_PurgeLeadCdbBySfdcBin_Batch() {
		this.purgeObjectName = CAMPAIGN_OBJECT_NAME;
		this.isRunFirstTime = true;
		this.numberOfNextDay = 1;
		this.numberOfLastDay = 0;
	}

	global SME_PurgeLeadCdbBySfdcBin_Batch(Integer numberOfNextDay, Integer numberOfLastDay, String purgeObjectName) {
		this.isRunFirstTime = true;
		this.numberOfNextDay = numberOfNextDay;
		this.numberOfLastDay = numberOfLastDay;
		this.purgeObjectName = purgeObjectName;
	}

	global SME_PurgeLeadCdbBySfdcBin_Batch(Integer numberOfNextDay, Integer numberOfLastDay, Boolean isRunFirstTimeFlag, String purgeObjectName) {
		this.numberOfNextDay = numberOfNextDay;
		this.numberOfLastDay = numberOfLastDay;
		this.purgeObjectName = purgeObjectName;
		this.isRunFirstTime = isRunFirstTimeFlag;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(this.purgeObjectName == CAMPAIGN_OBJECT_NAME){
			this.query = 'SELECT Id,Lead_Campaign_Event_Code__c FROM Campaign WHERE isDeleted = true AND LastModifiedDate >= LAST_N_DAYS:'+this.numberOfLastDay+' AND LastModifiedDate <= NEXT_N_DAYS:'+this.numberOfNextDay +' ALL ROWS';
		}else if(this.purgeObjectName == TARGET_LIST_OBJECT_NAME){
			this.query = 'SELECT Id,External_Id_CDB__c FROM Target_List__c WHERE isDeleted = true AND LastModifiedDate >= LAST_N_DAYS:'+this.numberOfLastDay+' AND LastModifiedDate <= NEXT_N_DAYS:'+this.numberOfNextDay +' ALL ROWS';
		}

		System.debug('this.query = '+this.query);
		return Database.getQueryLocator(this.query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('scope = '+scope);
   		CustomOBject customObj = new CustomOBject();
   		for(sObject s : scope){
   			if(this.purgeObjectName == CAMPAIGN_OBJECT_NAME){
   				Campaign eachCampaign = (Campaign) s;
   				customObj.externalIdCDB.add(eachCampaign.Lead_Campaign_Event_Code__c);
   			}else if(this.purgeObjectName == TARGET_LIST_OBJECT_NAME){
				Target_List__c eachTargetList = (Target_List__c) s;
				customObj.externalIdCDB.add(eachTargetList.External_Id_CDB__c);
			}
   		}

   		String jsonString = JSON.serialize(customObj);

   		try {
            // Call Webservice
            CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
            CIBaseResponseModel responseModel = webServiceInstance.purgeLeadByBinWebservice(this.isRunFirstTime,this.purgeObjectName,jsonString);
            if(isRunFirstTime){
            	isRunFirstTime = false;
            }
        } catch (Exception e) {
            System.debug('Exception:' + e);
            GlobalUtility.logMessage('ERROR','SME_PurgeLead_Batch','purgeLead',null,null,e.getMessage(),null,e,null);
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		if(purgeObjectName == CAMPAIGN_OBJECT_NAME){
			Database.executeBatch(new SME_PurgeLeadCdbBySfdcBin_Batch(this.numberOfNextDay,this.numberOfLastDay,this.isRunFirstTime,TARGET_LIST_OBJECT_NAME),2000);
		}else if(purgeObjectName == TARGET_LIST_OBJECT_NAME && isRunFirstTime){
			try {
	            // Call Webservice
	            CampaignLead_Webservice webServiceInstance = CampaignLead_Webservice.getInstance();
	            CIBaseResponseModel responseModel = webServiceInstance.purgeLeadByBinWebservice(this.isRunFirstTime,this.purgeObjectName,'{"externalIdCDB":[]}');
	            if(isRunFirstTime){
	            	isRunFirstTime = false;
	            }
	        } catch (Exception e) {
	            System.debug('Exception:' + e);
	            GlobalUtility.logMessage('ERROR','SME_PurgeLeadCdbBySfdcBin_Batch','purgeLead',null,null,e.getMessage(),null,e,null);
	        }
		}
	}
	
}