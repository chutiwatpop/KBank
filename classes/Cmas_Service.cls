/**
** For manage request response 
*/
@RestResource(urlMapping='/CMASservices/*') 

global without sharing class Cmas_Service {
    public static final String CMAS_ENDPOINT = SME_CIRestWebservice.CALLOUT_URL + 'CRMCreateCreditWriteUp';
    public static List<Application_Log__c> appLogList;


    @AuraEnabled
    webService static String sendToCMAS(Id applicationHistoryId){
            String responseMSG = '';
            Datetime todatDT = Datetime.now();

            Integer workHour =   Integer.valueOf(todatDT.format('HH')) ;
            String workDay = todatDT.format('EEE');
            Integer workingStart =  Integer.valueOf(Label.CMASWorkingTimeStart); 
            Integer workingEnd =  Integer.valueOf(Label.CMASWorkingTimeStop);
            if(workHour >= workingStart && workHour < workingEnd && workDay !='Sat' &&workDay !='Sun' ){
                    Application_History__c  cmasApp = [SELECT ID,LPM_Customer__c,LPM_Customer__r.LPM__r.LPM__c,OppName__c,CWU_Number__c,App_Num_CMAS__c,RMSubmitChannel__c,LPM_no__c,CMAS_Status__c,Send_to_CMAS_status__c,Business_Code__r.Sub_Industry_Group__c,Current_Owner_Extension__c,Current_Team_Name__r.Hub_Code__c FROM Application_History__c WHERE Id=:applicationHistoryId LIMIT 1];
                    Opportunity cmasOpp;
                    User_Extension__c userExt;
                    User rmUser;
                    Integer countOpportunityProduct;

                    if(cmasApp !=null && cmasApp.OppName__c !=null){
                        cmasOpp = [SELECT Id,Account.CIS__c,Account.Customer_Status__c,Account.Customer_Type_Code__c  FROM Opportunity WHERE ID=:cmasApp.OppName__c LIMIT 1];
                    }
                    if(cmasApp !=null && cmasApp.Current_Owner_Extension__c !=null ){
                        userExt = [SELECT User__c FROM User_Extension__c WHERE ID=:cmasApp.Current_Owner_Extension__c LIMIT 1];
                    }
                    if(userExt !=null && userExt.User__c != null){
                        rmUser = [SELECT Id,Segment__c,Name,Profile.Name,Employee_ID__c,Email, Phone,MobilePhone, Manager.Id,Manager.Name,Manager.Profile.Name,Manager.Employee_ID__c,Manager.Email,Manager.Phone,Manager.MobilePhone,Manager.Manager.Id,Manager.Manager.Name,Manager.Manager.Profile.Name,Manager.Manager.Employee_ID__c,Manager.Manager.Email,Manager.Manager.Phone,Manager.Manager.MobilePhone,Manager.Manager.Manager.Id,Manager.Manager.Manager.Name,Manager.Manager.Manager.Profile.Name,Manager.Manager.Manager.Employee_ID__c,Manager.Manager.Manager.Email, Manager.Manager.Manager.Phone , Manager.Manager.Manager.MobilePhone  FROM User WHERE ID=:userExt.User__c LIMIT 1];    
                    }
                    if(cmasApp !=null){
                        List<OpportunityLineItem> oppLineItemsList = [SELECT Id FROM OpportunityLineItem WHERE Application__c =:cmasApp.Id OR Application_CBS__c =:cmasApp.Id];
                        countOpportunityProduct = oppLineItemsList.size();
                    }

                    String crmRefno = String.valueOf(applicationHistoryId).substring(0, 15);
                    String todayTXT = todatDT.format('YYYY-MM-dd');
                    
                    if(cmasOpp !=null && cmasApp !=null && userExt !=null && rmUser !=null ){
                        String lpmNo = '';
                        String errorMsg = '';
                        if(countOpportunityProduct == 0){
                            errorMsg += Label.Not_Allow_Sent_To_Cmas;
                        }

                        if(cmasApp.LPM_Customer__c !=null && cmasApp.LPM_Customer__r.LPM__r.LPM__c != null){
                            lpmNo = cmasApp.LPM_Customer__r.LPM__r.LPM__c.leftPad(10,'0');
                        }else if(cmasApp.LPM_no__c !=null){
                            lpmNo = cmasApp.LPM_no__c.leftPad(10,'0');
                        }

                        if(cmasApp.CWU_Number__c != null && cmasApp.CWU_Number__c !=''){
                            crmRefno = cmasApp.CWU_Number__c;
                        }
                        if(cmasApp.CMAS_Status__c !=null && cmasApp.CMAS_Status__c !=''){
                            errorMsg += Label.Cannot_Resend_to_CMAS;
                        }else if(cmasApp.RMSubmitChannel__c !='CMAS' ){
                            errorMsg += Label.Submit_Channel_not_CMAS;
                        }

                        if(String.isBlank(errorMsg)){
                            String origUnitCode = '';
                            if(rmUser.Segment__c == GlobalConstants.SEGMENT_CB || rmUser.Segment__c == GlobalConstants.SEGMENT_MB){
                                origUnitCode = rmUser.Segment__c;
                            }else if(rmUser.Segment__c == GlobalConstants.SEGMENT_SE || rmUser.Segment__c == GlobalConstants.SEGMENT_ME){
                                origUnitCode = 'MD';
                            }
                            CMASModelExtensions.CreditWriteUpModel  creditWriteUpModel = new CMASModelExtensions.CreditWriteUpModel();
                            CMASModelExtensions.CreditWriteUpModelDetail creditModelDetail = new CMASModelExtensions.CreditWriteUpModelDetail();
                            CMASModelExtensions.EAIHeader eaiHeader = new CMASModelExtensions.EAIHeader();
                            CMASModelExtensions.CMSCCreditWriteUpModel cmscCreditWriteUpModel = new CMASModelExtensions.CMSCCreditWriteUpModel();
                            CMASModelExtensions.CRMCustomers crmCustomers = new CMASModelExtensions.CRMCustomers();
                            CMASModelExtensions.CustomersVect crmCustomersVect = new CMASModelExtensions.CustomersVect();
                            CMASModelExtensions.CRMCustomer crmCustomer = new CMASModelExtensions.CRMCustomer();
                            CMASModelExtensions.CRMCustomerSale crmCustomerSale = new CMASModelExtensions.CRMCustomerSale();
                            CMASModelExtensions.OpportFacilsObj opportFacilsObj = new CMASModelExtensions.OpportFacilsObj();
                            CMASModelExtensions.OpportFacilsVect opportFacilsVect=new CMASModelExtensions.OpportFacilsVect();
                            CMASModelExtensions.CMSCOpportFacil cmscOpportFacil =new  CMASModelExtensions.CMSCOpportFacil ();
                            CMASModelExtensions.SalesTeamObj saleTeamObj = new CMASModelExtensions.SalesTeamObj();
                            CMASModelExtensions.SalesEmpsVect saleEmpVect = new CMASModelExtensions.SalesEmpsVect();
                            List<CMASModelExtensions.CRMSalesEmployee> saleTeamList = new List<CMASModelExtensions.CRMSalesEmployee>();

                            eaiHeader.sourceTransactionId = crmRefno;

                            cmscOpportFacil.num = cmasOpp.Account.CIS__c.leftPad(10,'0');
                            cmscOpportFacil.facilCode = '';
                            cmscOpportFacil.facilLimitAmt = '0';

                            opportFacilsVect.CMSCOpportFacil = cmscOpportFacil;
                            opportFacilsObj.opportFacilsVect  =opportFacilsVect;
                            cmscCreditWriteUpModel.opportFacilsObj = opportFacilsObj;
                            cmscCreditWriteUpModel.CRMRefNum = crmRefno;
                            cmscCreditWriteUpModel.origEmpNum = rmUser.Employee_ID__c;
                            cmscCreditWriteUpModel.origUnitCode =  origUnitCode; // MD = sme,CB and MB = cbs
                            cmscCreditWriteUpModel.origHubCode = cmasApp.Current_Team_Name__r.Hub_Code__c;
                            cmscCreditWriteUpModel.createdDate = todayTXT;
                            cmscCreditWriteUpModel.cobrwLPMCustNum = lpmNo;
                            cmscCreditWriteUpModel.docNum = '';

                            if(rmUser.Id != null){
                                CMASModelExtensions.CRMSalesEmployee rm = new CMASModelExtensions.CRMSalesEmployee();
                                CMASModelExtensions.Phone rmPhone = new CMASModelExtensions.Phone();
                                CMASModelExtensions.Phone rmMobile = new CMASModelExtensions.Phone();
                                rm.empNum = rmUser.Employee_ID__c;
                                rm.salesTypeCode = mappingToCMASProfile(rmUser.Profile.Name);
                                rm.empName = rmUser.Name;
                                rm.email = rmUser.Name;
                                rmPhone.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Phone);
                                rmMobile.phoneNum = trimPhoneNumberToSpecificLength(rmUser.MobilePhone);
                                rm.phObj = rmPhone;
                                rm.mobilePhObj = rmMobile;
                                saleTeamList.add(rm);
                            }

                            if(rmUser.Manager.Id != null){
                                CMASModelExtensions.CRMSalesEmployee tm = new CMASModelExtensions.CRMSalesEmployee();
                                CMASModelExtensions.Phone tmPhone = new CMASModelExtensions.Phone();
                                CMASModelExtensions.Phone tmMobile = new CMASModelExtensions.Phone();
                                tm.empNum = rmUser.Manager.Employee_ID__c;
                                tm.salesTypeCode = mappingToCMASProfile(rmUser.Manager.Profile.Name);
                                tm.empName = rmUser.Manager.Name;
                                tm.email = rmUser.Manager.Name;
                                tmPhone.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.Phone);
                                tmMobile.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.MobilePhone);
                                tm.phObj = tmPhone;
                                tm.mobilePhObj = tmMobile;
                                saleTeamList.add(tm);
                            }

                            if(rmUser.Manager.Manager.Id != null){
                                CMASModelExtensions.CRMSalesEmployee ah = new CMASModelExtensions.CRMSalesEmployee();
                                CMASModelExtensions.Phone ahPhone = new CMASModelExtensions.Phone();
                                CMASModelExtensions.Phone ahMobile = new CMASModelExtensions.Phone();
                                ah.empNum = rmUser.Manager.Manager.Employee_ID__c;
                                ah.salesTypeCode = mappingToCMASProfile(rmUser.Manager.Manager.Profile.Name);
                                ah.empName = rmUser.Manager.Manager.Name;
                                ah.email = rmUser.Manager.Manager.Name;
                                ahPhone.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.Manager.Phone);
                                ahMobile.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.Manager.MobilePhone);
                                ah.phObj = ahPhone;
                                ah.mobilePhObj = ahMobile;
                                saleTeamList.add(ah);
                            }

                            if(rmUser.Manager.Manager.Manager.Id != null){
                                CMASModelExtensions.CRMSalesEmployee nh = new CMASModelExtensions.CRMSalesEmployee();
                                CMASModelExtensions.Phone nhPhone = new CMASModelExtensions.Phone();
                                CMASModelExtensions.Phone nhMobile = new CMASModelExtensions.Phone();
                                nh.empNum = rmUser.Manager.Manager.Manager.Employee_ID__c;
                                nh.salesTypeCode = mappingToCMASProfile(rmUser.Manager.Manager.Manager.Profile.Name);
                                nh.empName = rmUser.Manager.Manager.Manager.Name;
                                nh.email = rmUser.Manager.Manager.Manager.Name;
                                nhPhone.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.Manager.Manager.Phone);
                                nhMobile.phoneNum = trimPhoneNumberToSpecificLength(rmUser.Manager.Manager.Manager.MobilePhone);
                                nh.phObj = nhPhone;
                                nh.mobilePhObj = nhMobile;
                                saleTeamList.add(nh);
                            }

                            saleEmpVect.CRMSalesEmployee = saleTeamList;
                            saleTeamObj.salesEmpsVect = saleEmpVect;

                            crmCustomer.num =  cmasOpp.Account.CIS__c.leftPad(10,'0');
                            crmCustomer.LPMCustNum = lpmNo;
                            crmCustomer.brwRelTypeCode = 'P';
                            crmCustomer.prospectFlag = cmasOpp.Account.Customer_Status__c;
                            //crmCustomer.prospectFlag = 'P';
                            crmCustomer.CISCustNum =  cmasOpp.Account.CIS__c.leftPad(10,'0');
                            crmCustomer.CISTypeCode = cmasOpp.Account.Customer_Type_Code__c;
                            crmCustomer.svcBrchCode = '';
                            crmCustomer.indtryCde = cmasApp.Business_Code__r.Sub_Industry_Group__c;
                            crmCustomer.occCode = '';
                            crmCustomer.salutationCode = '';

                            crmCustomersVect.CRMCustomer = crmCustomer;
                            crmCustomers.customersVect = crmCustomersVect;


                            crmCustomerSale.num =  cmasOpp.Account.CIS__c.leftPad(10,'0');
                            crmCustomerSale.LPMCustNum =  lpmNo;
                            crmCustomerSale.brwRelTypeCode = 'P';
                            crmCustomerSale.CISCustNum =  cmasOpp.Account.CIS__c.leftPad(10,'0');
                            crmCustomerSale.salesTeamObj  = saleTeamObj;

                            creditModelDetail.EAIHeader = eaiHeader;
                            creditModelDetail.CMSCCreditWriteUp = cmscCreditWriteUpModel;
                            creditModelDetail.CRMCustomers = crmCustomers;
                            creditModelDetail.CRMCustomer = crmCustomerSale;

                            creditWriteUpModel.TFB0186a01 = creditModelDetail;
                            errorMsg += validateApplicationData(creditWriteUpModel);
                            if(String.isBlank(errorMsg)){
                                String jsonRequest = JSON.serialize(creditWriteUpModel);
                                try{
                                    HTTPResponse response = SME_CIRestWebservice.sendHTTPRequest(Cmas_Service.CMAS_ENDPOINT,jsonRequest);
                                    Map<String,String> resultMap = (Map<String,String>)JSON.deserialize(response.getBody(), Map<String,String>.class);
                                    if(resultMap.containsKey('status') && resultMap.get('status') == '0'){
                                        cmasApp.CWU_Number__c = crmRefno;
                                        cmasApp.Send_to_CMAS_status__c = GlobalConstants.CMAS_STATUS_PENDING;
                                        cmasApp.ManualSP__c =true;

                                        TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
                                        update cmasApp;
                                        TriggerHandler.clearBypass('ApplicationHistoryTriggerHandler');
                                    }
                                    responseMSG =  response.getBody();
                                    addCMASApplicationLog('SendToCMAS',jsonRequest);
                                }catch(DmlException ex){
                                    responseMSG = '{"status":"9","reasonDesc":"cc'+ex+'"}';
                                }catch(Exception e){
                                    responseMSG = '{"status":"9","reasonDesc":"Cannot Connect To CI"}';
                                }
                            }else{
                                responseMSG = '{"status":"9","reasonDesc":"'+errorMsg+' "}';
                            }
                        }else{
                            responseMSG = '{"status":"9","reasonDesc":"'+errorMsg+'"}';    
                        }
                    }else{
                        responseMSG = '{"status":"9","reasonDesc":"This Application History does not match Condition"}';
                    }
            }else{
                    responseMSG = '{"status":"9","reasonDesc":"'+Label.Time_Send_to_CMAS+' "}';
            }

            addCMASApplicationLog('SendToCMAS',responseMSG);
            
            if(appLogList !=null && appLogList.size() > 0){
                insert appLogList;
            }
            return responseMSG;
    }

    @httpPOST
    global static void doPost() {
        RestContext.response.addHeader('Content-Type', 'application/json;charset=UTF-8');
        String requestBody = RestContext.request.requestBody.toString();
        String jsonResponseText;
        Datetime todatDT = Datetime.now();
        String todayTXT = todatDT.format('YYYY-MM-dd-HH.mm.ss.000000'); 
        addCMASApplicationLog('RestServiceResponseMSG',requestBody);

        RestResponseModel.CMASrequestModel jsonResponse = (RestResponseModel.CMASrequestModel) JSON.deserialize(requestBody, RestResponseModel.CMASrequestModel.class);
        if(jsonResponse.batch_Name == 'TFB_SO_OPP'){//TFB_SO_OPP 133
            if(jsonResponse.cwu_ref_no !=''){
                List<Application_History__c> appList = [SELECT ID FROM Application_History__c WHERE Id =:jsonResponse.cwu_ref_no or OppName__r.CWU_Number__c =:jsonResponse.cwu_ref_no];
                if(appList.isEmpty()){
                    String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP} (91,50)';
                    String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    String errorMessageText2 = 'CRM record not found.';

                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cwu_ref_no,'TFB_SO_OPP',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);
                }else{
                    ModelExtensions.CMASmodelRS cmas_response = new ModelExtensions.CMASmodelRS();
                    ModelExtensions.TFBsoAppAvw app_a_vw_obj = new ModelExtensions.TFBsoAppAvw();
                    ModelExtensions.TFBsoAppBvw app_b_vw_obj = new ModelExtensions.TFBsoAppBvw();
                    app_b_vw_obj.tier= '';
                    app_b_vw_obj.rate_type= '';
                    app_b_vw_obj.sign= '';
                    app_b_vw_obj.spread= '';
                    app_b_vw_obj.tier_tenure= '';
                    app_b_vw_obj.tier_tenure_type= '';

                    app_a_vw_obj.opportunity_id='';
                    app_a_vw_obj.facility_cd='91';
                    app_a_vw_obj.facility_limit='2';
                    app_a_vw_obj.facility_status='';
                    app_a_vw_obj.facility_tenure='91';
                    app_a_vw_obj.facility_tenure_type='';
                    app_a_vw_obj.tfb_so_opp_b_vw = new List<ModelExtensions.TFBsoAppBvw>();
                    app_a_vw_obj.tfb_so_opp_b_vw.add(app_b_vw_obj);

                    cmas_response.batch_Name = 'TFB_SO_OPP';
                    cmas_response.component = 'TFB_SO_OPP';
                    cmas_response.createdate = todayTXT;
                    cmas_response.cwu_ref_no = jsonResponse.cwu_ref_no;
                    cmas_response.tfb_so_app_a_vw = new List<ModelExtensions.TFBsoAppAvw>();
                    cmas_response.tfb_so_app_a_vw.add(app_a_vw_obj);
                    jsonResponseText = JSON.serialize(cmas_response);
                }
            }else{
                    String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP} (91,50)';
                    String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    String errorMessageText2 = 'Input is null';

                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail('91','TFB_SO_OPP',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);
            }
        }else if(jsonResponse.batch_Name == 'TFB_SO_CW_STA'){//TFB_SO_CW_STA 131                
            if(jsonResponse.cwu_ref_no !=''){
                List<Application_History__c> appList = [SELECT ID FROM Application_History__c WHERE Id =:jsonResponse.cwu_ref_no or OppName__r.CWU_Number__c =:jsonResponse.cwu_ref_no];
                if(appList.isEmpty()){
                    String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CW_STA} (91,50)';
                    String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    String errorMessageText2 = 'CRM record not found.';

                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cwu_ref_no,'TFB_SO_CW_STA',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);                
                }else{
                    ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
                    cmasResponse.batch_Name = 'TFB_SO_CW_STA';
                    cmasResponse.component = 'TFB_SO_CW_STA';
                    cmasResponse.createdate = todayTXT;
                    cmasResponse.cwu_ref_no = jsonResponse.cwu_ref_no;
                    cmasResponse.cwu_status = '01';
                    cmasResponse.email_addr = GlobalConstants.EMAIL_NOTIFICATION;
                    jsonResponseText = JSON.serialize(cmasResponse);
                }
            }else{
                    String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CW_STA} (91,50)';
                    String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    String errorMessageText2 = 'CRM record not found.';
                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail('91','TFB_SO_CW_STA',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);
            }
        }else if(jsonResponse.batch_Name == 'TFB_SO_CW_STA_UPD'){ //132
                List<Application_History__c> appHistoryList = [SELECT ID,CMAS_Status__c,Send_to_CMAS_status__c,OppName__r.Owner.Email FROM Application_History__c WHERE  Id =:jsonResponse.cwu_ref_no or CWU_Number__c =:jsonResponse.cwu_ref_no ORDER BY CreatedDate DESC LIMIT 1];
                if(appHistoryList !=null && !appHistoryList.isEmpty()){
                    Application_History__c cmasAppHistory =  appHistoryList.get(0);
                    ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
                    cmasResponse.batch_Name = 'TFB_SO_CW_STA_UPD';
                    cmasResponse.component = 'TFB_SO_CW_STA_UPD';
                    cmasResponse.createdate = todayTXT;
                    cmasResponse.cwu_ref_no = jsonResponse.cwu_ref_no;
                    cmasResponse.cwu_status = jsonResponse.cwu_status;
                    cmasResponse.email_addr = cmasAppHistory.OppName__r.Owner.Email;
                    cmasResponse.notification = '1';
                    jsonResponseText = JSON.serialize(cmasResponse);

                    if(jsonResponse.cwu_status =='01' || jsonResponse.cwu_status =='04'){
                            cmasAppHistory.Send_to_CMAS_status__c = GlobalConstants.CMAS_STATUS_SUCCESS;
                            update cmasAppHistory;
                    }else if(jsonResponse.cwu_status =='02' || jsonResponse.cwu_status =='03'){
                            cmasAppHistory.Send_to_CMAS_status__c = GlobalConstants.CMAS_STATUS_ERROR;
                            update cmasAppHistory;
                    }
                }else{
                        String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CW_STA_UPD} (91,50)';
                        String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                        String errorMessageText2 = 'CRM record not found.';

                        ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cwu_ref_no,'TFB_SO_CW_STA_UPD',errorMessageText,errorMessageExplainText,errorMessageText2);
                        jsonResponseText = JSON.serialize(cmasResponseFail); 
                }
        }else if(jsonResponse.batch_Name == 'TFB_SO_OPP_CR'){ //134
                if(jsonResponse.opportunity_id !=''){
                    List<Application_History__c> appList = [SELECT ID FROM Application_History__c WHERE Id =:jsonResponse.opportunity_id or OppName__r.CWU_Number__c =:jsonResponse.opportunity_id];
                    if(appList.isEmpty()){
                        String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP_CR} (91,50)';
                        String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                        String errorMessageText2 = 'CRM record not found.';

                        ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cwu_ref_no,'TFB_SO_OPP_CR',errorMessageText,errorMessageExplainText,errorMessageText2);
                        jsonResponseText = JSON.serialize(cmasResponseFail); 
                    }else{
                        ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
                        cmasResponse.batch_Name = 'TFB_SO_OPP_CR';
                        cmasResponse.component = 'TFB_SO_OPP_CR';
                        cmasResponse.createdate = todayTXT;
                        cmasResponse.cwu_ref_no = jsonResponse.cwu_ref_no;
                        cmasResponse.opportunity_id = jsonResponse.opportunity_id;
                        cmasResponse.notification = '1';
                        cmasResponse.email_addr = GlobalConstants.EMAIL_NOTIFICATION;
                        jsonResponseText = JSON.serialize(cmasResponse);
                    }
                }else{
                    String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP_CR} (91,50)';
                    String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    String errorMessageText2 = 'CRM record not found.';

                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail('91','TFB_SO_OPP_CR',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);
                }
        }else if(jsonResponse.batch_Name == 'TFB_SO_OPP_UPD'){ //135
                if(jsonResponse.opportunity_id !=''){
                        List<Application_History__c> appList = [SELECT ID FROM Application_History__c WHERE Id =:jsonResponse.opportunity_id or OppName__r.CWU_Number__c =:jsonResponse.opportunity_id];
                        if(appList.isEmpty()){
                                String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP_UPD} (91,50)';
                                String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                                String errorMessageText2 = 'CRM record not found.';

                                ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cwu_ref_no,'TFB_SO_OPP_UPD',errorMessageText,errorMessageExplainText,errorMessageText2);
                                jsonResponseText = JSON.serialize(cmasResponseFail);
                        }else{
                                ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
                                cmasResponse.batch_Name = 'TFB_SO_OPP_UPD';
                                cmasResponse.component = 'TFB_SO_OPP_UPD';
                                cmasResponse.createdate = todayTXT;
                                cmasResponse.cwu_ref_no = jsonResponse.cwu_ref_no;
                                cmasResponse.opportunity_id = jsonResponse.opportunity_id;
                                cmasResponse.notification = '1';
                                cmasResponse.cwu_status = '01';
                                cmasResponse.email_addr = GlobalConstants.EMAIL_NOTIFICATION;
                                jsonResponseText = JSON.serialize(cmasResponse);
                        }
                }else{  
                        String errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_OPP_UPD} (91,50)';
                        String errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                        String errorMessageText2 = 'CRM record not found.';

                        ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail('91','TFB_SO_OPP_UPD',errorMessageText,errorMessageExplainText,errorMessageText2);
                        jsonResponseText = JSON.serialize(cmasResponseFail);
                }   
        }else if(jsonResponse.batch_Name == 'TFB_SO_TEAM'){ //137
            ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
            cmasResponse.batch_Name = 'TFB_SO_TEAM';
            cmasResponse.component = 'TFB_SO_TEAM';
            cmasResponse.createdate = todayTXT;
            List<ModelExtensions.TFB_SO_TEAM_VW> saleTeamList= new List<ModelExtensions.TFB_SO_TEAM_VW>();
            Boolean foundError = true;
            String errorMessageText = '';
            String errorMessageExplainText = '';
            String cisNo = String.valueOf(Integer.valueOf(jsonResponse.cust_id));
            if(jsonResponse.cust_id  != ''){
                    List<Account> accountList = [SELECT id,Owner.Name,Owner.Profile.Name,Owner.Employee_ID__c,Owner.Email, Owner.Phone, Owner.Manager.Id,Owner.Manager.Name,Owner.Manager.Profile.Name,Owner.Manager.Employee_ID__c,Owner.Manager.Email,Owner.Manager.Phone,Owner.Manager.Manager.Id,Owner.Manager.Manager.Name,Owner.Manager.Manager.Profile.Name,Owner.Manager.Manager.Employee_ID__c,Owner.Manager.Manager.Email, Owner.Manager.Manager.Phone,Owner.Manager.Manager.Manager.Id,Owner.Manager.Manager.Manager.Name,Owner.Manager.Manager.Manager.Profile.Name,Owner.Manager.Manager.Manager.Employee_ID__c,Owner.Manager.Manager.Manager.Email, Owner.Manager.Manager.Manager.Phone FROM Account WHERE  CIS__c =:cisNo   LIMIT 1];
                    if(accountList != null && !accountList.isEmpty()){
                        cmasResponse.cust_id  = jsonResponse.cust_id.leftPad(10,'0');
                        Account searchAccount = accountList.get(0);
                        if(searchAccount.Owner.Id != null){
                            ModelExtensions.TFB_SO_TEAM_VW rm = new ModelExtensions.TFB_SO_TEAM_VW();
                            rm.primary_sale = 'N';
                            rm.primary_ps = 'N';
                            rm.emplid = searchAccount.Owner.Employee_ID__c;
                            rm.sales_role_cd = mappingToCMASProfile(searchAccount.Owner.Profile.Name);
                            rm.sales_nm = searchAccount.Owner.Name;
                            rm.email_addr = searchAccount.Owner.Email;
                            rm.phone = searchAccount.Owner.Phone;
                            saleTeamList.add(rm);
                        }

                        if(searchAccount.Owner.Manager.Id !=null){
                            ModelExtensions.TFB_SO_TEAM_VW tm = new ModelExtensions.TFB_SO_TEAM_VW();
                            tm.primary_sale = 'N';
                            tm.primary_ps = 'N';
                            tm.emplid = searchAccount.Owner.Manager.Employee_ID__c;
                            tm.sales_role_cd = mappingToCMASProfile(searchAccount.Owner.Manager.Profile.Name);
                            tm.sales_nm = searchAccount.Owner.Manager.Name;
                            tm.email_addr = searchAccount.Owner.Manager.Email;
                            tm.phone = searchAccount.Owner.Manager.Phone;
                            saleTeamList.add(tm);
                        }

                        if(searchAccount.Owner.Manager.Manager.Id !=null){
                            ModelExtensions.TFB_SO_TEAM_VW ah = new ModelExtensions.TFB_SO_TEAM_VW();
                            ah.primary_sale = 'N';
                            ah.primary_ps = 'N';
                            ah.emplid = searchAccount.Owner.Manager.Manager.Employee_ID__c;
                            ah.sales_role_cd = mappingToCMASProfile(searchAccount.Owner.Manager.Manager.Profile.Name);
                            ah.sales_nm = searchAccount.Owner.Manager.Manager.Name;
                            ah.email_addr = searchAccount.Owner.Manager.Manager.Email;
                            ah.phone = searchAccount.Owner.Manager.Manager.Phone;
                            saleTeamList.add(ah);
                        }

                        if(searchAccount.Owner.Manager.Manager.Manager.Id !=null){
                            ModelExtensions.TFB_SO_TEAM_VW nh = new ModelExtensions.TFB_SO_TEAM_VW();
                            nh.primary_sale = 'N';
                            nh.primary_ps = 'N';
                            nh.emplid = searchAccount.Owner.Manager.Manager.Manager.Employee_ID__c;
                            nh.sales_role_cd = mappingToCMASProfile(searchAccount.Owner.Manager.Manager.Manager.Profile.Name);
                            nh.sales_nm = searchAccount.Owner.Manager.Manager.Manager.Name;
                            nh.email_addr = searchAccount.Owner.Manager.Manager.Manager.Email;
                            nh.phone = searchAccount.Owner.Manager.Manager.Manager.Phone;
                            saleTeamList.add(nh);
                        }
                        foundError = false;
                    }else{
                        errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_TEAM} (91,50)';
                        errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    }
            }else{
                    errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_TEAM} (91,50)';
                    errorMessageExplainText = 'No rows exist in the database with the specified keys.';
            }

            if(foundError){
                    String errorMessageText2 = 'CRM record not found.';
                    ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cust_id,'TFB_SO_TEAM',errorMessageText,errorMessageExplainText,errorMessageText2);
                    jsonResponseText = JSON.serialize(cmasResponseFail);
            }else{
                    cmasResponse.tfb_so_team_vw = saleTeamList;
                    jsonResponseText = JSON.serialize(cmasResponse);
            }
        }else if(jsonResponse.batch_Name == 'TFB_SO_CUST_INFO'){ //138
                CMASModelExtensions.TFB_SO_CUST_INFO cmasResponse = new CMASModelExtensions.TFB_SO_CUST_INFO();
                Boolean foundError = true;
                String errorMessageText = '';
                String errorMessageExplainText = '';
                String cisNo = String.valueOf(Integer.valueOf(jsonResponse.cust_id));
                if(cisNo !=''){
                        List<Account> accountList = [SELECT Current_Team_Name__r.Branch_Code__c,Customer_Status__c,Customer_Type_Code__c,Mobile_Phone__c,Phone__c FROM account WHERE CIS__c =:cisNo  LIMIT 1];
                        if(!accountList.isEmpty()){
                                Account  searchAccount = accountList.get(0);
                                cmasResponse.cust_stat = searchAccount.Customer_Status__c;
                                cmasResponse.tfb_cis_id =  jsonResponse.cust_id.leftPad(10,'0');
                                cmasResponse.cust_type = searchAccount.Customer_Type_Code__c;
                                cmasResponse.branch_cd = searchAccount.Current_Team_Name__r.Branch_Code__c;
                                cmasResponse.itc_cd = searchAccount.Current_Team_Name__r.Branch_Code__c;
                                cmasResponse.off_phone_no = searchAccount.Phone__c;
                                cmasResponse.mobile_phone_no = searchAccount.Mobile_Phone__c;
                                cmasResponse.component = 'TFB_SO_CUST_INFO';
                                cmasResponse.datetime_added =  todayTXT;
                                cmasResponse.cust_id = cisNo.leftPad(10,'0');
                                cmasResponse.lpm_no = '';
                                cmasResponse.id_no = '';
                                cmasResponse.first_name = '';
                                cmasResponse.last_name = '';
                                cmasResponse.eng_first_nm = '';
                                cmasResponse.eng_last_nm = '';
                                cmasResponse.biz_reg_dt = '';
                                cmasResponse.biz_reg_tp = '';
                                cmasResponse.tax_id = '';
                                cmasResponse.off_phone_ext = '';
                                cmasResponse.mobile_phone_ext = '';
                                cmasResponse.home_phone_no = '';
                                cmasResponse.home_phone_ext = '';
                                cmasResponse.cust_since_dt = '';
                                cmasResponse.cust_opr_dt = '';
                                cmasResponse.country_cd = '';
                                cmasResponse.spouse_first_nm = '';
                                cmasResponse.spouse_last_nm = '';
                                cmasResponse.marital_stat = '';
                                cmasResponse.biz_nature = '';
                                cmasResponse.industry_id = '';
                                cmasResponse.employer = '';
                                cmasResponse.occupation = '';
                                cmasResponse.salutation_cd = '';
                                cmasResponse.fax_no = '';
                                cmasResponse.fax_ext = '';
                                cmasResponse.trade_name = '';
                                cmasResponse.regis_capt = '';
                                cmasResponse.paid_up_capt = '0';
                                cmasResponse.num_of_emp = '0';
                                cmasResponse.industry_grp = '';
                                foundError = false;
                        }else{
                                errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CUST_INFO} (91,50)';
                                errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                        }
                }else{
                        errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CUST_INFO} (91,50)';
                        errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                }

                if(foundError){
                        String errorMessageText2 = 'CRM record not found.';
                        ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cust_id,'TFB_SO_CUST_INFO',errorMessageText,errorMessageExplainText,errorMessageText2);
                        jsonResponseText = JSON.serialize(cmasResponseFail);
                }else{
                        jsonResponseText = JSON.serialize(cmasResponse);
                }
        }else if(jsonResponse.batch_Name == 'TFB_SO_CUST_ADDR'){ //139
                ModelExtensions.CMASmodelRS cmasResponse = new ModelExtensions.CMASmodelRS();
                List<ModelExtensions.TFB_SO_CADDR_VW> addressMoldelList= new List<ModelExtensions.TFB_SO_CADDR_VW>();
                String cisNo = String.valueOf(Integer.valueOf(jsonResponse.cust_id));
                Boolean foundError = true;
                String errorMessageText = '';
                String errorMessageExplainText = '';
                if(cisNo  != ''){
                    List<Address__c> addressList = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CIS_ID__c, Address_Type__c, Alley__c, Box_Number__c, Building__c, Country_code__c, District__c, External_ID__c, Floor__c, House_Number_Encrypt__c, Original_Code_from_CIS__c, Place_Name__c, Place__c, Postcode__c, Province__c, Room__c, Street__c, Sub_District__c, Village_Number__c, Village__c, Pin_Location__Latitude__s, Pin_Location__Longitude__s, Pin_Location__c, Sales_Smart_Address__c, Address__c, Address_Type_SalesSmart__c, Map__c, Has_Location__c FROM Address__c WHERE CIS_ID__r.CIS__c =:cisNo   LIMIT 1];
                    if(addressList != null && !addressList.isEmpty()){
                        for(Address__c  eachAddr: addressList){
                        ModelExtensions.TFB_SO_CADDR_VW tempAddr = new ModelExtensions.TFB_SO_CADDR_VW();
                        tempAddr.addr_type = eachAddr.Address_Type__c;
                        tempAddr.country_cd = eachAddr.Country_code__c;
                        tempAddr.moo_ban = eachAddr.Address_Type__c;
                        tempAddr.building = eachAddr.Building__c;
                        tempAddr.soi = eachAddr.Village_Number__c;
                        tempAddr.road = eachAddr.Street__c;
                        tempAddr.amphur = eachAddr.Sub_District__c;
                        tempAddr.num = '';
                        tempAddr.moo = '';
                        tempAddr.floor = eachAddr.Floor__c;
                        tempAddr.contact_dept = '';
                        tempAddr.district = eachAddr.District__c;
                        tempAddr.province = eachAddr.Province__c;
                        tempAddr.postal = eachAddr.Postcode__c;
                        addressMoldelList.add(tempAddr);
                        foundError = false;
                        }
                    }else{
                        errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CUST_ADDR} (91,50)';
                        errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                    }
                }else{
                        errorMessageText = 'No rows exist for the specified keys.  {TFB_SO_CUST_ADDR} (91,50)';
                        errorMessageExplainText = 'No rows exist in the database with the specified keys.';
                }

                if(foundError){
                        String errorMessageText2 = 'CRM record not found.';
                        ModelExtensions.CMASmodelRSfail cmasResponseFail = createResponseFail(jsonResponse.cust_id,'TFB_SO_CUST_ADDR',errorMessageText,errorMessageExplainText,errorMessageText2);
                        jsonResponseText = JSON.serialize(cmasResponseFail);
                }else{
                        cmasResponse.batch_Name = 'TFB_SO_CUST_ADDR';
                        cmasResponse.component = 'TFB_SO_CUST_ADDR';
                        cmasResponse.createdate = todayTXT;
                        cmasResponse.cust_id  = jsonResponse.cust_id.leftPad(10,'0');
                        cmasResponse.tfb_so_caddr_vw = addressMoldelList;
                        jsonResponseText = JSON.serialize(cmasResponse);
                }
        }else {
            jsonResponseText = JSON.serialize('');
        }
        addCMASApplicationLog('RestServiceResponseMSG',jsonResponseText);
        
        if(appLogList !=null && appLogList.size() > 0){
            insert appLogList;
        }

        RestContext.response.responseBody = Blob.valueOf(jsonResponseText);
    }

    private static String mappingToCMASProfile(String profileName){
        String cmasProfile = '';
        if(profileName == GlobalConstants.SME_RM || profileName == GlobalConstants.CBS_RM || profileName == GlobalConstants.CBS_TM  || profileName == GlobalConstants.AN_RM ){
            cmasProfile = 'TFRM';
        }else if(profileName == GlobalConstants.SME_TM || profileName == GlobalConstants.AN_TM ){
            cmasProfile = 'TFTS';
        }else if(profileName == GlobalConstants.SME_AH || profileName == GlobalConstants.CBS_TL || profileName == GlobalConstants.OT_AH_SALES || profileName == GlobalConstants.AN_AH){
            cmasProfile = 'TFTL';
        }else if(profileName == GlobalConstants.SME_NH || profileName == GlobalConstants.CBS_FSVP || profileName == GlobalConstants.OT_NH_SALES || profileName == GlobalConstants.AN_NH){
            cmasProfile = 'TFSM';
        }
        return cmasProfile;
    }


    public static String calculateCMASAppNo(String appNo,Integer index){
        String [] tempAppList = appNo.split('/');
        if(tempAppList !=null && !tempAppList.isEmpty()){
            if(tempAppList.size() == 4){
                return tempAppList[0]+'/'+tempAppList[1]+'/'+tempAppList[2].substring(2,4)+'R'+index+'/'+tempAppList[3]; 
            }else if(tempAppList.size() == 5){
                return tempAppList[0]+'/'+tempAppList[1]+'/'+tempAppList[2]+'/'+tempAppList[3].substring(2,4)+'R'+index+'/'+tempAppList[4]; 
            }else if(tempAppList.size() == 6){
                return tempAppList[0]+'/'+tempAppList[1]+'/'+tempAppList[2]+'/'+tempAppList[3]+'/'+tempAppList[4].substring(2,4)+'R'+index+'/'+tempAppList[5]; 
            }else{
                return '00/0000/0000/RR' ;
            }
        }else{
            return '00/0000/0000/RR' ;
        }
        
    }

    private static String trimPhoneNumberToSpecificLength(String phoneNum){
        if(phoneNum != null && phoneNum.length() > 20){
            return phoneNum.substring(0,20);
        }
        return phoneNum;
    }

    private static ModelExtensions.CMASmodelRSfail createResponseFail(String cust_id,String batch_Name,String errorMessageText,String errorMessageExplainText,String errorMessageText2){
        String faultcode = '200';
        String faultstring = 'Component Interface API.';
        String runcode = '0';
        String errorDetail = 'error';
        String detailKeyinformationId = '2';
        String responseDetailType = 'Error';
        String messagesetnumber = '91';
        String messagenumber1 = '50';
        String messagenumber2 = '59';

        ModelExtensions.CMASmodelRSfail cmasResponseFail = new ModelExtensions.CMASmodelRSfail();
        ModelExtensions.DetailMessage responeDetail  = new ModelExtensions.DetailMessage();
        ModelExtensions.DetailMessage responeDetail2  = new ModelExtensions.DetailMessage();
        cmasResponseFail.batch_Name = batch_Name;
        cmasResponseFail.faultcode = faultcode;
        cmasResponseFail.faultstring = faultstring;
        cmasResponseFail.runcode = runcode;
        cmasResponseFail.detail =  errorDetail;
        cmasResponseFail.detail_keyinformation = cust_id;
        cmasResponseFail.detail_keyinformation_id = detailKeyinformationId;

        responeDetail.type = responseDetailType;
        responeDetail.messagesetnumber = messagesetnumber;
        responeDetail.messagenumber = messagenumber1;
        responeDetail.messagetext = errorMessageText;
        responeDetail.explaintext = errorMessageExplainText;


        responeDetail2.type = responseDetailType;
        responeDetail2.messagesetnumber =  messagesetnumber;
        responeDetail2.messagenumber =  messagenumber2;
        responeDetail2.messagetext = errorMessageText2;

        cmasResponseFail.detail_message = new List<ModelExtensions.DetailMessage>{responeDetail,responeDetail2};
        return cmasResponseFail;
    }

    private static void addCMASApplicationLog(String sourceFunction,String message){
        if(appLogList == null){
            appLogList = new List<Application_Log__c>();
        }
        Datetime todatDT = Datetime.now();
        String formattedDt = todatDT.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
        Application_Log__c al = new Application_Log__c();
        al.Name = 'ALOG-SendToCMAS-RQ-'+formattedDt;
        al.Debug_Level__c = 'Debug';
        al.Message__c = message;
        al.Source_Function__c = sourceFunction;
        al.Source__c = 'CMASIntregation';
        appLogList.add(al);
    }

    private static String validateApplicationData(CMASModelExtensions.CreditWriteUpModel creditWriteUpModel){
        String errorText = '';
        if(String.isBlank(creditWriteUpModel.TFB0186a01.CRMCustomers.customersVect.CRMCustomer.indtryCde)){
            errorText = 'ApplicationHistory Business Code is Null';
        }else if(String.isBlank(creditWriteUpModel.TFB0186a01.CRMCustomers.customersVect.CRMCustomer.CISTypeCode)){
            errorText = 'Account CISTypeCode is Null (I/O)';
        }else if(String.isBlank(creditWriteUpModel.TFB0186a01.CMSCCreditWriteUp.origUnitCode)){
            errorText = 'UnitCode is Null';
        }else if(String.isBlank(creditWriteUpModel.TFB0186a01.CMSCCreditWriteUp.origHubCode)){
            errorText = 'HubCode is Null';
        }else if(String.isBlank(creditWriteUpModel.TFB0186a01.CRMCustomers.customersVect.CRMCustomer.prospectFlag)){
            errorText = 'ProspectFlag is Null';
        }
        return errorText;
    }
}