global class UpdateLeadMlpToTemp_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
	String query;
	String whereQuery;
	
	global void initialQuery(){
		String queryField = '';
		for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
			queryField = queryField + eachMapping.Field_API_Name__c + ',';
		}
		queryField = queryField + ' Lead_MLP_Reference_Mapping__c,CIS_ID__c,Status ';
		query = 'SELECT '+queryField+' FROM LEAD ';
	}

	global UpdateLeadMlpToTemp_Batch() {
		whereQuery = ' WHERE LastModifiedDate = today AND Status != \'Opened\'';
	}

	global UpdateLeadMlpToTemp_Batch(List<Id> listIds) {
		whereQuery = ' WHERE Id IN (\'' + String.join(listIds,'\',\'') + '\')' ;
	}

	global UpdateLeadMlpToTemp_Batch(String whereCondition) {
		whereQuery = ' WHERE ' + whereCondition;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		initialQuery();
		query = query + whereQuery + ' AND Recordtype.DeveloperName IN (\''+GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_DEVNAME+'\',\''+GlobalConstants.LEAD_RECORDTYPE_TELESALES_LEAD_MLP_READ_ONLY_DEVNAME+'\')';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Lead> listLead) {
   		Map<String,Lead_MLP__c> mapUpdateMlpStatusByExternalId = new Map<String,Lead_MLP__c>();
		for(Lead eachLead : listLead){
			Map<String,String> mapDihKeyByProductName = (Map<String,String>)JSON.deserialize(eachLead.Lead_MLP_Reference_Mapping__c, Map<String,String>.class);
			Boolean didCustomerResponse = canContactCustomerAndCustomerResponse(eachLead);

			for(String productName : mapDihKeyByProductName.keySet()){
				Lead_MLP__c updateMlpStatus = new Lead_MLP__c();
				updateMlpStatus.REFR_ID__c = mapDihKeyByProductName.get(productName);
				updateMlpStatus.Is_Sync_Completed__c = false;

				Telesales_Product_Name_to_Field_Mapping__c fieldMapping = Telesales_Product_Name_to_Field_Mapping__c.getValues(productName);
				if(didCustomerResponse){
					if(fieldMapping != null && eachLead.get(fieldMapping.Field_API_Name__c)==true){
						updateMlpStatus.REL_ST__c = eachLead.Status;
					}else{
						updateMlpStatus.REL_ST__c = 'Unqualified';
					}
				}else{
					updateMlpStatus.REL_ST__c = eachLead.Status;
				}
				mapUpdateMlpStatusByExternalId.put(updateMlpStatus.REFR_ID__c, updateMlpStatus);
			}
		}

		if(mapUpdateMlpStatusByExternalId.values().size() > 0) upsert mapUpdateMlpStatusByExternalId.values() REFR_ID__c;
	}
	
	private Boolean canContactCustomerAndCustomerResponse(Lead eachLead){
		for(Telesales_Product_Name_to_Field_Mapping__c eachMapping : Telesales_Product_Name_to_Field_Mapping__c.getall().values()){
			if(eachLead.get(eachMapping.Field_API_Name__c)==true){
				return true;
			}
		}
		return false;
	}
	global void finish(Database.BatchableContext BC) {
		try {
            MLPWebService webServiceInstance = MLPWebService.getInstance();
            CIBaseResponseModel responseModel = webServiceInstance.calloutWebservice();
            System.debug('responseModel = '+responseModel);
        } catch (Exception e) {
            System.debug('Exception:' + e);
            GlobalUtility.logMessage('ERROR','UpdateLeadMlpToTemp_Batch','UpdateLeadMlp',null,null,e.getMessage(),null,e,null);
        }
	}
	
}