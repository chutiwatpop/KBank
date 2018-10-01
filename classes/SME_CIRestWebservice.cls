/*------------------------------------------------------------
Author: Sasitorn Saisuttichai
Company : Beryl8
Description:   A webservice class for CI connecting.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Sasitorn.S          First Create
19/02/2016  Charnun.T           Clean code and Refactor
14/03/2016  Charnun.T           Refactor Code to callout
------------------------------------------------------------*/
global class SME_CIRestWebservice {
    private static String CLASS_NAME = 'SME_CIRestWebservice';
    public static final String CALLOUT_URL = CustomSettingUtil.getEndpointByName('KbankURL');
    public static final String TRANSACTBP_ENDPOINT = CALLOUT_URL + 'SMETransactBPInformation';
    public static final String SAVING_ENDPOINT = CALLOUT_URL + 'SMESavingDepositInformation';
    public static final String FIXED_ENDPOINT = CALLOUT_URL + 'SMEFixedDepositInformation';
    public static final String CURRENT_ENDPOINT = CALLOUT_URL + 'SMECurrentDepositInformation';
    public static final String MUTUALFUND_ENDPOINT = CALLOUT_URL + 'SMEMutualFundInformation';
    public static final String TAWEESUP_ENDPOINT = CALLOUT_URL + 'SMETaweesupDepositInformation';
    public static final String NON_CREDIT_OUTSTANDING_ENDPOINT = CALLOUT_URL + 'SMEOutstandingNoneCreditInformation';
    public static final String CREDIT_OUTSTANDING_ENDPOINT = CALLOUT_URL + 'SMEOutstandingCreditInformation';
    public static final String SEARCH_ENDPOINT = CALLOUT_URL + 'SMECustomSearch';
    public static final String SORT_ENDPOINT = CALLOUT_URL + 'SMECustomSort';
    public static final String PROSPECT_ENDPOINT = CALLOUT_URL + 'SMEOnlineConvertProspect';
    public static final String UPSERT_LEAD_CST_ENDPOINT = CALLOUT_URL + 'CIUpsertLeadCst';
    public static final String UPSERT_LEAD_MST_ENDPOINT = CALLOUT_URL + 'CIUpsertLeadMst';
    public static final String PURGE_LEAD_ENDPOINT = CALLOUT_URL + 'SME_Purge_Lead_Expired';
    public static final String PURGE_LEAD_BY_SFDC_BIN_ENDPOINT = CALLOUT_URL + 'SME_Delete_Diff_Lead';
    public static final String SYNC_LEAD_FROM_SF_TO_CDB_ENDPOINT = CALLOUT_URL + 'upsertTargerListCampaign';
    public static final String UPSERT_BUSINESS_CODE = CALLOUT_URL + 'CIUpsertBusinessCode';
    public static final String GET_FRAUD_ENDPOINT =  CALLOUT_URL +  'GetFraudStatus';
    public static final String UPDATE_LEAD_MLP_ENDPOINT = CALLOUT_URL + 'CIUpdateDIHMLP';

    public static final String CREDIT_CARD_ENDPOINT = CALLOUT_URL + 'SMECreditCardInformation';
    public static final String K_EXPRESS_CASH_ENDPOINT = CALLOUT_URL + 'SMEKECInformation';
    public static final String FCD_ENDPOINT =   CALLOUT_URL +  'GetFCD';
    public static final String POD_ENDPOINT = CALLOUT_URL + 'SMEKECInformation';

    public static final String CREDIT_CARD_INFO_ENDPOINT = CALLOUT_URL + 'GetCreditCardInfo';
    public static final String CUSTOMER_WEALTH_INFO_ENDPOINT = CALLOUT_URL + 'GetCustomerWealthInfo';
    public static final String ATM_DEBIT_CARD_INFO_ENDPOINT = CALLOUT_URL + 'GetAtmDebitCardInfo';
    public static final String FNC_ENDPOINT = CALLOUT_URL + 'GetFNC';
    public static final String LPM_TDR_ENDPOINT = CALLOUT_URL + 'GetLPMTDR';
    public static final String OD_LIMIT_ENDPOINT = CALLOUT_URL + 'GetODLimit';

    public static HTTPResponse continuationResponse {get;set;}
    public static Object continuationObject;

    public static String UPDATE_CAMPAIGN_LEAD_ENDPOINT = 'callout:CIUpdateCampaignLeadEndpoint';
    public static String UPDATE_CONTACT_PREF_ENDPOINT = 'callout:CIUpdateContactPrefEndpoint';

    public static HttpRequest createHttpRequestWithCIS(String cis, String endpoint) {
        String requestStr = 'IP_ID=' + cis;
        return SME_HTTPCallUtil.createHttpRequest(endpoint, requestStr, 120);
    }

    public static HttpRequest createHttpRequestWithJsonBody(String requestStr,String endpoint){
        return SME_HTTPCallUtil.createHttpRequest(endpoint, requestStr, 120);
    }

    private static String getCIExceptionMessageFromHTTPResponse(HTTPResponse resp) {
        String errorMessage;
        if(resp.getStatusCode() == 503){
            errorMessage = ExceptionMessage.APPLICATION_SERVER_NOT_AVAILABLE+ 'Status:' + resp.getStatus() + ' Code:'+resp.getStatusCode();
        }else if(resp.getStatusCode() == 504){
            errorMessage = ExceptionMessage.APPLICATION_TIMEOUT+ 'Status:' + resp.getStatus() + ' Code:'+resp.getStatusCode();
        }else if(resp.getStatusCode() == 401){
            errorMessage = ExceptionMessage.AUTHENTICATION_FAILED+ 'Status:' + resp.getStatus() + ' Code:'+resp.getStatusCode();
        }else{
            errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+ 'Status:' + resp.getStatus() + ' Code:'+resp.getStatusCode();
        }
        System.debug('getCIExceptionMessageFromHTTPResponse:' + errorMessage);
        return errorMessage;
    }
    

    public static HTTPResponse handleReturnException(HttpResponse returnResp){
        if(returnResp.getStatusCode() != 200) { // 500 = fail
            String errorMessage = getCIExceptionMessageFromHTTPResponse(returnResp);
            throw new CIWebserviceException(errorMessage);
        }
        return returnResp;
    }
    
    public static HTTPResponse sendHTTPRequest(String endpoint,String requestStr){
        HTTPResponse resp;
        String errorMessage;
        try {
            resp = SME_HTTPCallUtil.sendHttpCallout(endpoint,requestStr);
        } catch(CalloutException e){
            errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+'Endpoint:'+endpoint+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        } catch(Exception e){
            errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+'Endpoint:'+endpoint+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        }
    
        if(resp.getStatusCode() != 200) {
            errorMessage = getCIExceptionMessageFromHTTPResponse(resp);
            throw new CIWebserviceException(errorMessage);
        }
        return resp;
    }

    public static CustomerResponseModel getResponseModelFromSearchResultStr(String jsonResponseStr){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        String functionName = 'getResponseModelFromSearchResultStr';
        SearchResultResponse searchResult;
        String errorMessage;

        try{
            searchResult = SearchResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            throw new CIWebserviceException(errorMessage);
        } 
        if (searchResult != null && searchResult.searchResponse != null){
            if(searchResult.searchResponse.errorMessage != null){
                errorMessage = ExceptionMessage.CI_RESPONSE_ERROR+searchResult.searchResponse.errorMessage;
                throw new CIWebserviceException(errorMessage);
            }else if(searchResult.searchResponse.cis_id != null){
                responseModel.cisList = searchResult.searchResponse.cis_id;
            }else{
                writeDebugMessage(functionName,'Empty Response');
            }
        }
        return responseModel;
    }

    public static CustomerResponseModel getResponseModelFromSortResultStr(String jsonResponseStr){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        String functionName = 'getResponseModelFromSortResultStr';
        String errorMessage;
        SortResultResponse sortResult;

        try{
            sortResult = SortResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            throw new CIWebserviceException(errorMessage);
        } 

        if (sortResult != null && sortResult.sortResponse != null){
            if(sortResult.sortResponse.errorMessage != null){
                errorMessage = ExceptionMessage.CI_RESPONSE_ERROR+sortResult.sortResponse.errorMessage;
                throw new CIWebserviceException(errorMessage);
            }else if(sortResult.sortResponse.cis_id != null){
                responseModel.cisList = sortResult.sortResponse.cis_id;
            }else{
                writeDebugMessage(functionName,'Empty Response');
            }
        }
        return responseModel;
    }

    public static String getRequestStringFromMap(Map<String,String> requestMap){
        String resultStr='';
        for(String key:requestMap.keySet()){
            String val = requestMap.get(key);
            if (resultStr != ''){
                resultStr = resultStr+'&&';
            }
            resultStr = resultStr+key+'='+val;
        }

        return resultStr;
    }

    public static void writeDebugMessage(String sourceFunction,String logMessage){
        String sourceClass = CLASS_NAME;
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;
        Exception ex = null;
        Long timeTaken = null;
        String severity = 'DEBUG';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }
    // ------------- Get Fraud Status Real-time -------------
    webservice static String getFraudStatus(GetFraud_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'getFraudStatus';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        HTTPResponse resp = sendHTTPRequest(GET_FRAUD_ENDPOINT,requestStr);
        String jsonResponseStr = resp.getBody();

        return jsonResponseStr;
    }
    // ------------- Create Prospect Real-time -------------
    webservice static String createProspectRequest(CreateProspect_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'createProspectRequest';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        
        HTTPResponse resp = sendHTTPRequest(PROSPECT_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }
    // ------------- Upsert Lead -------------
    webservice static String upsertLeadMSTRequest(CampaignLead_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'upsertLeadMSTRequest';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        
        HTTPResponse resp = sendHTTPRequest(UPSERT_LEAD_MST_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }

    webservice static String upsertLeadCSTRequest(CampaignLead_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'upsertLeadCSTRequest';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        
        HTTPResponse resp = sendHTTPRequest(UPSERT_LEAD_CST_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }

    webservice static String purgeLeadRequest(CampaignLead_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'purgeLeadRequest';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        
        HTTPResponse resp = sendHTTPRequest(PURGE_LEAD_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }
    //Purge Lead Issue_INC000000559537
    webservice static String purgeLeadBySfdcBinRequest(CampaignLead_Webservice.RequestModel requestModel){
        String requestStr;
        String functionName = 'purgeLeadBySfdcBinRequest';

        if (requestModel.requestMap != null) {
            requestStr = getRequestStringFromMap(requestModel.requestMap);
        }
        
        HTTPResponse resp = sendHTTPRequest(PURGE_LEAD_BY_SFDC_BIN_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }

    webservice static String syncLeadToCDBRequest(){
        String requestStr = '';
        String functionName = 'syncLeadToCDBRequest';

        HTTPResponse resp = sendHTTPRequest(SYNC_LEAD_FROM_SF_TO_CDB_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }

    webservice static CustomerResponseModel searchCISListByCustomerSearchRequest(CustomerSearchRequestModel searchRequest){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        List<String> cisList = new List<String>();
        String requestStr = null;
        String errorMessage;
        String jsonResponseStr;
        String functionName = 'searchCISListByCustomerSearchRequest';

        if (searchRequest.requestMap != null) {
            requestStr = getRequestStringFromMap(searchRequest.requestMap);
        }

        HTTPResponse resp = sendHTTPRequest(SEARCH_ENDPOINT,requestStr);

        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        responseModel = getResponseModelFromSearchResultStr(resp.getBody());

        return responseModel;
    }

    webservice static CustomerResponseModel sortCISListByCustomerSearchRequest(CustomerSearchRequestModel searchRequest){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        List<String> cisList = new List<String>();
        String requestStr;
        String functionName = 'sortCISListByCustomerSearchRequest';

        if (searchRequest.requestMap != null) {
            requestStr = getRequestStringFromMap(searchRequest.requestMap);
        }

        HTTPResponse resp = sendHTTPRequest(SORT_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        responseModel = getResponseModelFromSortResultStr(resp.getBody());
        
        return responseModel;
    }

    webservice static SME_TransactBPResultResponse getTransactBPRequest(String cisID){
        SME_TransactBPResultResponse responseModel = new SME_TransactBPResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getTransactBPRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(TRANSACTBP_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_TransactBPResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
            throw new CIWebserviceException(errorMessage);
        } 

        return responseModel;
    }

    webservice static SME_UpdateCampaignLeadResultResponse updateCampaignLeadRequest(List<Target_List__c> updateTargetList){
        SME_UpdateCampaignLeadResultResponse responseModel = new SME_UpdateCampaignLeadResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'updateCampaignLeadRequest';

        List<Id> targetListId = new List<Id>();
        for(Target_List__c eachTargetList : updateTargetList){
            targetListId.add(eachTargetList.Id);
        }
        List<Target_List__c> matchUpdateTargetList = [SELECT Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.Name, Status__c, Lead_Campaign__r.Name FROM Target_List__c WHERE Id IN :targetListId];
        if(matchUpdateTargetList.size()>0){
            requestStr = SME_JSONGenerator.leadStatusJSONGenerator(matchUpdateTargetList);
        }
        
        HTTPResponse resp = sendHTTPRequest(UPDATE_CAMPAIGN_LEAD_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_UpdateCampaignLeadResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_UpdateContactPrefResultResponse updateContactPrefRequestList(List<Contact> updateContactPrefList){
        String requestStr = SME_JSONGenerator.contactPrefJSONGenerator(updateContactPrefList);
        return updateContactPrefRequest(requestStr);
    }

    webservice static SME_UpdateContactPrefResultResponse updateContactPrefRequest(String requestStr){
        SME_UpdateContactPrefResultResponse responseModel = new SME_UpdateContactPrefResultResponse();
        String errorMessage;
        String functionName = 'updateContactPrefRequest';

        HTTPResponse resp = sendHTTPRequest(UPDATE_CONTACT_PREF_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_UpdateContactPrefResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static String updateStatusLeadMLPToDIH(String requestModelString){
        Map<String,String> requestModel = (Map<String,String>)JSON.deserialize(requestModelString, Map<String,String>.class);
        String requestStr;
        String functionName = 'upsertLeadCSTRequest';

        if (requestModel != null) {
            requestStr = getRequestStringFromMap(requestModel);
        }
        
        HTTPResponse resp = sendHTTPRequest(UPDATE_LEAD_MLP_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        return jsonResponseStr;
    }
}