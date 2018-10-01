global class CampaignLead_Webservice {

	private static CampaignLead_Webservice instance;
	public static Map<String,String> mapTypeWithNumber = new Map<String,String>{GlobalConstants.LEAD_FOR_SALES => '01'
																			, GlobalConstants.LEAD_TO_DO => '02'
																			, GlobalConstants.LEAD_TO_INFORM => '03'
																			, GlobalConstants.CAMPAIGN => '04'
																			, GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER => '05'
																			, GlobalConstants.LEAD_FOR_FEEDBACK => '06'};
	public static Map<String,String> mapSubTypeWithNumber = new Map<String,String>{GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA => '01'
																			, GlobalConstants.LEAD_SUB_TYPE_STRONG_HYBRID => '02'
																			, GlobalConstants.LEAD_SUB_TYPE_REFINANCE => '03'
																			, GlobalConstants.LEAD_SUB_TYPE_CHEQUE => '04'
																			, GlobalConstants.LEAD_SUB_TYPE_REFER => '05'
																			, GlobalConstants.LEAD_SUB_TYPE_BA => '06'
																			, GlobalConstants.LEAD_SUB_TYPE_LI => '07'
																			, GlobalConstants.LEAD_SUB_TYPE_ACCOUNT_PLAN => '08'
																			, GlobalConstants.LEAD_SUB_TYPE_VALUE_CHAIN => '09'
																			, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM => '10'
																			, GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM => '11'
																			, GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER => '12'
																			, GlobalConstants.LEAD_SUB_TYPE_DPD => '13'
																			, GlobalConstants.LEAD_SUB_TYPE_EDC => '14'
																			, GlobalConstants.LEAD_SUB_TYPE_VALUE_CHAIN_CHAIN => '15'
																			, GlobalConstants.LEAD_SUB_TYPE_STRATEGIC_PROVINCE => '16'
																			, GlobalConstants.LEAD_SUB_TYPE_ACCOUNT_PLANNING_HUB => '17'
																			, GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST => '18'
																			, GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_FEE => '19'
																			, GlobalConstants.LEAD_SUB_TYPE_TRADE_INCREASE_LOAN => '20'
																			, GlobalConstants.LEAD_SUB_TYPE_TRADE_RELATIONSHIP => '21'
																			, GlobalConstants.LEAD_SUB_TYPE_INACTIVE => '22'
																			, GlobalConstants.LEAD_SUB_TYPE_REFUND_FEE => '23'
																			, GlobalConstants.LEAD_SUB_TYPE_PN_UN_USED => '24'
																			, GlobalConstants.LEAD_SUB_TYPE_CLOSE => '25'};

	public static CampaignLead_Webservice getInstance() {
        if(instance == null) instance = new CampaignLead_Webservice();
        return instance;
    }

	global class RequestModel {
		global RequestModel() {
			this.requestMap = new Map<String, String>();
		}

		global RequestModel(Campaign camp,String oldCode,String importType) {
			this.requestMap = new Map<String, String>();
			// MST
			if(camp.Lead_Campaign_Event_Code__c != oldCode){
				requestMap.put('newCode', camp.Lead_Campaign_Event_Code__c);
			}
			requestMap.put('leadCode', oldCode);
			requestMap.put('leadName', camp.Name);
			if(camp.Promotion__c != null) {
				if((camp.Promotion__c).length() > 255){
					requestMap.put('promotion', (camp.Promotion__c).substring(0,255));
				}else{
					requestMap.put('promotion', camp.Promotion__c);
				}
			} else {
				requestMap.put('promotion', '');
			}
			if(camp.Description != null) {
				if((camp.Description).length() > 255){
					requestMap.put('desc', (camp.Description).substring(0,255));
				}else{
					requestMap.put('desc', camp.Description);
				}
			} else {
				requestMap.put('desc', '');
			}
			requestMap.put('startDate',	SME_JSONGenerator.toValue(camp.StartDate));
			requestMap.put('endDate', SME_JSONGenerator.toValue(camp.EndDate));

			String leadType = '';
			if(CampaignLead_Webservice.mapTypeWithNumber.containsKey(camp.Type__c)){
				leadType = CampaignLead_Webservice.mapTypeWithNumber.get(camp.Type__c);
			}

			requestMap.put('leadType', leadType);

			String leadSubType = '';
			if(CampaignLead_Webservice.mapSubTypeWithNumber.containsKey(camp.Sub_Type__c)){
				leadSubType = CampaignLead_Webservice.mapSubTypeWithNumber.get(camp.Sub_Type__c);
			}else if(CampaignLead_Webservice.mapSubTypeWithNumber.containsKey(camp.Sub_Type_CBS__c)){
				leadSubType = CampaignLead_Webservice.mapSubTypeWithNumber.get(camp.Sub_Type_CBS__c);
			}

			requestMap.put('leadSubType', leadSubType);

			String camTypeCd = '';
			if(camp.Campaign_Type__c == GlobalConstants.CAMP_TYPE_TARGET) {
				camTypeCd = '01';
			} else if(camp.Campaign_Type__c == GlobalConstants.CAMP_TYPE_NON_TARGET) {
				camTypeCd = '02';
			} else {
				camTypeCd = '';
			}
			requestMap.put('camTypeCd', camTypeCd);

			// Create User
			if(camp.Created_By_CDB__c != null) {
				requestMap.put('createdUser', camp.Created_By_CDB__c);
			} else {
				requestMap.put('createdUser', String.valueOf(camp.CreatedBy.Employee_Id__c));	
			}

			// Create Date
			if(camp.Created_Date_CDB__c != null) {
				requestMap.put('createdDate', camp.Created_Date_CDB__c.substringBefore(' '));
			} else {
				requestMap.put('createdDate', SME_JSONGenerator.toValue(camp.CreatedDate));
			}
			
			// Update User
			if(camp.Last_Modified_By_CDB__c != null) {
				requestMap.put('updatedUser', camp.Last_Modified_By_CDB__c);
			} else {
				requestMap.put('updatedUser', String.valueOf(camp.LastModifiedBy.Employee_Id__c));
			}

			// Update Date
			if(camp.Last_Modified_Date_CDB__c != null) {
				requestMap.put('updatedDate', camp.Last_Modified_Date_CDB__c.substringBefore(' '));
			} else {
				requestMap.put('updatedDate', SME_JSONGenerator.toValue(camp.LastModifiedDate));
			}

			if(camp.Priority_Group__c == null) {
				requestMap.put('leadPriorityGroup', '');
			} else if(camp.Priority_Group__c == GlobalConstants.LEAD_HOT) {
				requestMap.put('leadPriorityGroup', 'H');
			} else if(camp.Priority_Group__c == GlobalConstants.LEAD_WARM) {
				requestMap.put('leadPriorityGroup', 'W');
			} else if(camp.Priority_Group__c == GlobalConstants.LEAD_COLD) {
				requestMap.put('leadPriorityGroup', 'C');
			}

			if(camp.Priority__c != null) {
				requestMap.put('leadPriority', camp.Priority__c);
			} else {
				requestMap.put('leadPriority', '');
			}

			if(camp.Add_Associated_Lead__c == null || camp.Add_Associated_Lead__c == false) {
				requestMap.put('addAssoFlag', '0');
			} else {
				requestMap.put('addAssoFlag', '1');
			}

			if(camp.Status == GlobalConstants.EXPIRE_PROCESS){
				requestMap.put('status', GlobalConstants.EXPIRED);
			}else if(camp.Status == GlobalConstants.CANCEL_PROCESS){
				requestMap.put('status', GlobalConstants.CANCEL);
			}else{
				if((camp.Status).length() > 50){
					requestMap.put('status', (camp.Status).substring(0,50));
				}else{
					requestMap.put('status', camp.Status);
				}
			}

			requestMap.put('importType', importType);
			requestMap.put('importStatusId', '0');
			requestMap.put('srcId', '723');
		}

		global RequestModel(Target_List__c targetList,String oldExternalId,String importType) {
			this.requestMap = new Map<String, String>();
			// CST
			if(targetList.External_ID_CDB__c != oldExternalId){
				requestMap.put('newCode', targetList.External_ID_CDB__c);
			}
			requestMap.put('code', oldExternalId);
			requestMap.put('name', targetList.Name);
			requestMap.put('leadCode', targetList.Lead_Campaign__r.Lead_Campaign_Event_Code__c);
			
			if(targetList.CIS_ID_Prospect_Name__r.RecordType.Name == GlobalConstants.ORGANIZATION_PROSPECT
				|| targetList.CIS_ID_Prospect_Name__r.RecordType.Name == GlobalConstants.INDIVIDUAL_PROSPECT){
				requestMap.put('ipId', '');
				requestMap.put('prospName',	targetList.CIS_ID_Prospect_Name__r.Name);
			}

			if(targetList.CIS_ID_Prospect_Name__r.Encrypt_Identification_No__c != null) {
				String trimIdent = targetList.CIS_ID_Prospect_Name__r.Encrypt_Identification_No__c.replace(' ','');
				requestMap.put('identNo', trimIdent);
			} else {
				requestMap.put('identNo', '');
			}

			if(targetList.Personalised_Message__c != null) {
				if((targetList.Personalised_Message__c).length() > 255){
					requestMap.put('msg', targetList.Personalised_Message__c.substring(0,255));
				}else{
					requestMap.put('msg', targetList.Personalised_Message__c);
				}
			} else {
				requestMap.put('msg', '');
			}

			// Create User
			if(targetList.Created_By_CDB__c != null) {
				requestMap.put('createdUser', targetList.Created_By_CDB__c);
			} else {
				requestMap.put('createdUser', String.valueOf(targetList.CreatedBy.Employee_Id__c));	
			}

			// Create Date
			if(targetList.Created_Date_CDB__c != null) {
				requestMap.put('createdDate', targetList.Created_Date_CDB__c.substringBefore(' '));
			} else {
				requestMap.put('createdDate', SME_JSONGenerator.toValue(targetList.CreatedDate));
			}
			
			// Update User
			if(targetList.Last_Modified_By_CDB__c != null) {
				requestMap.put('updatedUser', targetList.Last_Modified_By_CDB__c);
			} else {
				requestMap.put('updatedUser', String.valueOf(targetList.LastModifiedBy.Employee_Id__c));
			}

			// Update Date
			if(targetList.Last_Modified_Date_CDB__c != null) {
				requestMap.put('updatedDate', targetList.Last_Modified_Date_CDB__c.substringBefore(' '));
			} else {
				requestMap.put('updatedDate', SME_JSONGenerator.toValue(targetList.LastModifiedDate));
			}

			if(targetList.CIS_ID_Prospect_Name__r.Owner.Employee_Id__c != null) {
				requestMap.put('rmId', targetList.CIS_ID_Prospect_Name__r.Owner.Employee_Id__c);
			} else {
				requestMap.put('rmId', '');
			}
			
			if((targetList.Status__c).length() > 50){
				requestMap.put('status', (targetList.Status__c).substring(0,50));
			}else{
				requestMap.put('status', targetList.Status__c);
			}
			
			requestMap.put('importType', importType);
			requestMap.put('importStatusId', '0');
			requestMap.put('srcId', '723');
		}

		global RequestModel(String numberOfPurgeDays) {
			this.requestMap = new Map<String, String>();
			
			requestMap.put('Lead_NumberOfPurgeDays', numberOfPurgeDays);
			requestMap.put('importType', '0');
			requestMap.put('importStatus', '0');
			requestMap.put('batchTag','723_'+System.now());
		}
	
        //Purge Lead Issue_INC000000559537
		global RequestModel(Boolean isRunFirstTime,String purgeObjectName,String jsonRequestId) {
			this.requestMap = new Map<String, String>();
			
			if(isRunFirstTime){
				requestMap.put('IS_FIRST_CHUNK', 'true');
			}else{
				requestMap.put('IS_FIRST_CHUNK', 'false');
			}
			requestMap.put('objectName', purgeObjectName);
			requestMap.put('LIST_DELETED_ID', jsonRequestId);
		}

		public Map<String,String> requestMap {get;set;}
	}

	// Upsert Lead Master
	public CIBaseResponseModel upsertMSTWebservice(Campaign camp,String oldCode) {
    	String functionName = 'upsertMstWebservice';
    	CampaignLead_Webservice.RequestModel requestModel = new CampaignLead_Webservice.RequestModel(camp,oldCode,'2');
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    	    if(!requestModel.requestMap.isEmpty()) {
    	    	responseModel = getResponseUpsertMSTWebservice(requestModel);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';	
    	    }
    	} catch (Exception e) {
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();	
    	}

    	return responseModel;
    }

    private CIBaseResponseModel getResponseUpsertMSTWebservice(CampaignLead_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.upsertLeadMSTRequest(requestModel);

        CIBaseResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }

    // Purge Lead
	public CIBaseResponseModel purgeLeadWebservice(String numberOfPurgeDays) {
    	CampaignLead_Webservice.RequestModel requestModel = new CampaignLead_Webservice.RequestModel(numberOfPurgeDays);
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    	    if(!requestModel.requestMap.isEmpty()) {
    	    	responseModel = getResponsePurgeLeadWebservice(requestModel);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';	
    	    }
    	} catch (Exception e) {
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();	
    	}

    	return responseModel;
    }

    private CIBaseResponseModel getResponsePurgeLeadWebservice(CampaignLead_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.purgeLeadRequest(requestModel);
		//Purge Lead Issue_INC000000559537
        CIBaseResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }

    // Purge Lead By Bin
    //Purge Lead Issue_INC000000559537
	public CIBaseResponseModel purgeLeadByBinWebservice(Boolean isRunFirstTime,String purgeObjectName,String jsonRequestId) {
    	CampaignLead_Webservice.RequestModel requestModel = new CampaignLead_Webservice.RequestModel(isRunFirstTime,purgeObjectName,jsonRequestId);
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    	    if(!requestModel.requestMap.isEmpty()) {
    	    	responseModel = getResponsePurgeLeadByBinWebservice(requestModel);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';	
    	    }
    	} catch (Exception e) {
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();	
    	}

    	return responseModel;
    }
	
    //Purge Lead Issue_INC000000559537
    private CIBaseResponseModel getResponsePurgeLeadByBinWebservice(CampaignLead_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.purgeLeadBySfdcBinRequest(requestModel);

        CIBaseResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }

    // Sync Lead To CDB
	public CIBaseResponseModel syncLeadToCDBWebservice() {
    	CampaignLead_Webservice.RequestModel requestModel = new CampaignLead_Webservice.RequestModel();
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    		responseModel = getResponseSyncLeadToCDBWebservice();
    	} catch (Exception e) {
    		System.debug('error = '+e.getMessage());
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();	
    	}

    	return responseModel;
    }

    private CIBaseResponseModel getResponseSyncLeadToCDBWebservice(){
      	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.syncLeadToCDBRequest();

        CIBaseResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }

    // Upsert Targetlist
    public CIBaseResponseModel upsertCSTWebservice(Target_List__c targetList,String oldExternalId) {
    	String functionName = 'upsertCSTWebservice';
    	CampaignLead_Webservice.RequestModel requestModel = new CampaignLead_Webservice.RequestModel(targetList,oldExternalId,'2');
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    	    if(!requestModel.requestMap.isEmpty()) {
    	    	responseModel = getResponseUpsertCSTWebservice(requestModel);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';	
    	    }
    	} catch (Exception e) {
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();
    	}

    	return responseModel;
    }

    private CIBaseResponseModel getResponseUpsertCSTWebservice(CampaignLead_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.upsertLeadCSTRequest(requestModel);

        CIBaseResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }
    
    public static CIBaseResponseModel parseJSONString(String jsonString) {
		return (CIBaseResponseModel) System.JSON.deserialize(jsonString, CIBaseResponseModel.class);
	}
}