/**
* @author chansak.s@beryl8.com
* @30/10/2017 createddate
* @22/03/2017 CR098
*/

global class CMAS_Calculate_AppHistory_Batch implements Database.Batchable<sObject>,Database.Stateful {
    String query;
    Map<String,PIM__c> allPIMCodeMap = new Map<String,PIM__c>(); 
    Map<String,String> creditTypeCodeMap = new Map<String,String>();
    Boolean isTodayCondition = true;

    global CMAS_Calculate_AppHistory_Batch() {
        query = 'SELECT CWU_REF_No__c,Credit_Type_Code__c,CMAS_App_Type__c,CMAS_App_Id__c,Id,Application_Created_By__c,Application_Created_DateTime__c,Application_Last_Updated_By__c,Application_Last_Updated_DateTime__c,Application_Type_Code__c,ARM_Employee_ID__c,Business_Code__c,CMAS_Reference_Number__c,Customer_ID__c,CWU_Status__c,Industry_Code__c,Opportunity__c  FROM CMAS__c WHERE  LastModifiedDate = TODAY';
        init();
    }

    global CMAS_Calculate_AppHistory_Batch(String cwuRefNo) {
        query = 'SELECT CWU_REF_No__c,Credit_Type_Code__c,CMAS_App_Type__c,CMAS_App_Id__c,Id,Application_Created_By__c,Application_Created_DateTime__c,Application_Last_Updated_By__c,Application_Last_Updated_DateTime__c,Application_Type_Code__c,ARM_Employee_ID__c,Business_Code__c,CMAS_Reference_Number__c,Customer_ID__c,CWU_Status__c,Industry_Code__c,Opportunity__c  FROM CMAS__c WHERE  CWU_REF_No__c =\''+cwuRefNo+'\'';
        isTodayCondition = false;
        init();
    }    

    private void init(){
        List<PIM__c> pimList = [SELECT Id,Product_Name_English__c, PIM_code__c, Product_Name_Thai__c, Product_Description__c, Product_Line_Description_in_English__c, Product_Group_Code__c, Product_subGroup_Code__c, Product_Group_English__c, Product_in_GL_Code__c, Product_subGroup_English__c, Product_in_GL_English__c, Product_Status_Code__c, Timestamp__c, Publish_Date__c, Source_System_Id__c, Product_Line__c, CMAS_Flag__c FROM PIM__c WHERE Product_Status_Code__c ='Active'];
        for(PIM__c eachPIM : pimList){
            allPIMCodeMap.put(eachPIM.PIM_code__c, eachPIM);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CMAS__c> cmasList) {
        //init Data
        Set<Id> oppRelatedSet = new Set<Id>();
        Set<String> cmasSet = new Set<String>();
        Set<String> cmasAPPIdSet = new Set<String>();
        Map<String,List<CMAS_Fac_Info__c>> facInfoByCMASIdMap = new Map<String,List<CMAS_Fac_Info__c>>();
        Map<String,List<CMAS_Workflow_History__c>> workflowHistoryByCMASIdMap = new Map<String,List<CMAS_Workflow_History__c>>();
        Map<String,Application_History__c> firstAppByCWUMap  =new Map<String,Application_History__c>();

        for(CMAS__c eachCMAS : cmasList){   
            cmasSet.add(eachCMAS.CWU_REF_No__c);
            cmasAPPIdSet.add(eachCMAS.CMAS_App_Id__c);
        }
        List<CMAS_Fac_Info__c> cmasFacilityList;
        List<CMAS_Workflow_History__c> cmasWorkflowList;
        if(isTodayCondition){
            cmasFacilityList = [SELECT CMAS_Facility_Id__c,CMAC_FAC_Active__c,CMAS_App_Id__c,Facility_Code__c,Facility_Created_By__c,Facility_Created_DateTime__c,Facility_Exiting__c,Facility_Last_Updated_By__c,Facility_Last_Updated_DateTime__c,Facility_Limit_Approved__c,Facility_Limit_Proposed__c,Facility_One_Time_Credit_Use_Flag__c,Facility_Status_Code__c,Proposed_Facility_Tenure_Term__c,Proposed_Facility_Tenure_Type__c,CMAS_FAC_Calculated__c FROM CMAS_Fac_Info__c WHERE CMAS_App_Id__c =:cmasAPPIdSet AND LastModifiedDate = TODAY];
            cmasWorkflowList = [SELECT CMAS_App_Id__c,WorkFlow_Transaction_Id__c,Application_History_App__c,From_Date__c,From_Status__c,From_User__c,To_Date__c,To_Status__c,To_User__c FROM CMAS_Workflow_History__c  WHERE CMAS_App_Id__c =:cmasAPPIdSet AND LastModifiedDate = TODAY ORDER BY CMAS_App_Id__c,To_Date__c];
        }else{
            cmasFacilityList = [SELECT CMAS_Facility_Id__c,CMAC_FAC_Active__c,CMAS_App_Id__c,Facility_Code__c,Facility_Created_By__c,Facility_Created_DateTime__c,Facility_Exiting__c,Facility_Last_Updated_By__c,Facility_Last_Updated_DateTime__c,Facility_Limit_Approved__c,Facility_Limit_Proposed__c,Facility_One_Time_Credit_Use_Flag__c,Facility_Status_Code__c,Proposed_Facility_Tenure_Term__c,Proposed_Facility_Tenure_Type__c,CMAS_FAC_Calculated__c FROM CMAS_Fac_Info__c WHERE CMAS_App_Id__c =:cmasAPPIdSet];
            cmasWorkflowList = [SELECT CMAS_App_Id__c,WorkFlow_Transaction_Id__c,Application_History_App__c,From_Date__c,From_Status__c,From_User__c,To_Date__c,To_Status__c,To_User__c FROM CMAS_Workflow_History__c  WHERE CMAS_App_Id__c =:cmasAPPIdSet ORDER BY CMAS_App_Id__c,To_Date__c];
        }

        List<Application_History__c> appHistoryList = [SELECT ID,IS_Create_By_Integration__c,RecordTypeId,CWU_Number__c,OppName__r.StageName,RMSubmitIssue__c,RMCreditModel__c,CMAS_WF_Id__c,App_Num_CMAS__c,OppName__c,Index__c,SP_Submit_Issue__c,SPBusinessCode__c,SP_Requested_Amt__c,SP_Cancel_Requested_Amt__c,SP_Approved_Amt__c,SP_Cancel_Approved_Amt__c,SP_CAPF_Received_DT__c,SP_CAPB_Workout_DT__c,SP_Approval_Result__c,SP_Approve_Option__c,SP_UW_Name__c,SP_UWA_Name__c,TentativeSubmitDate__c,SP_Credit_Model__c,SP_UW_Lane__c,SP_UW_Color__c,ManualSP__c,Industry_Grade__c,BureauVerificationDate__c,SP_Submit_Round__c,CreatedById,IsLatestApp__c,Current_Owner_Extension__c,Current_Team_Name__c,Current_AH_Team__c,Current_NH_Team__c,Report_Actual_Visit_Date__c,AppInDate__c,FirstRequestedAmt__c,FirstSubmittedDate__c,FirstApplicationSOReceiveDate__c  FROM Application_History__c WHERE (Id=:cmasSet OR CWU_Number__c =:cmasSet) AND BU_Force_Data__c = false  ORDER BY OppName__c,Index__c];
        List<Opportunity> opportunityList = [SELECT Id,SP_Submit_Issue__c,Submit_Issue__c,IsConvertFromCallReport__c,AccountId,CMAS_Status__c,CWU_Number__c,Business_Code__c,Business_Code__r.Name,Owner.Segment__c FROM Opportunity WHERE CWU_Number__c=:cmasSet  or Id=:cmasSet ];
        Map<String,Application_History__c>  appHistoryByAPPNoMap = new Map<String,Application_History__c>();
        
        for(CMAS_Workflow_History__c eachCMASWorkflow : cmasWorkflowList){
            if(workflowHistoryByCMASIdMap.containsKey(eachCMASWorkflow.CMAS_App_Id__c)){
                workflowHistoryByCMASIdMap.get(eachCMASWorkflow.CMAS_App_Id__c).add(eachCMASWorkflow);
            }else{
                List<CMAS_Workflow_History__c> wfList = new List<CMAS_Workflow_History__c>();
                wfList.add(eachCMASWorkflow);
                workflowHistoryByCMASIdMap.put(eachCMASWorkflow.CMAS_App_Id__c, wfList);
            }
        }
        
        for(CMAS_Fac_Info__c eachCMASFacInfo : cmasFacilityList){
            if(facInfoByCMASIdMap.containsKey(eachCMASFacInfo.CMAS_App_Id__c)){
                facInfoByCMASIdMap.get(eachCMASFacInfo.CMAS_App_Id__c).add(eachCMASFacInfo);
            }else{
                List<CMAS_Fac_Info__c> facInfoList = new List<CMAS_Fac_Info__c>();
                facInfoList.add(eachCMASFacInfo);
                facInfoByCMASIdMap.put(eachCMASFacInfo.CMAS_App_Id__c,facInfoList);
            }
        }

        for(Application_History__c eachAppHistory : appHistoryList){
            if(eachAppHistory.IS_Create_By_Integration__c == false){
                if(eachAppHistory.CWU_Number__c !='' && eachAppHistory.CWU_Number__c !=null){
                    firstAppByCWUMap.put(eachAppHistory.CWU_Number__c ,eachAppHistory);
                }else{
                    firstAppByCWUMap.put(String.valueof(eachAppHistory.Id).substring(0,15),eachAppHistory);
                }
            }
            if(eachAppHistory.App_Num_CMAS__c !='' && eachAppHistory.App_Num_CMAS__c !=null ){
                appHistoryByAPPNoMap.put(eachAppHistory.App_Num_CMAS__c,eachAppHistory);
            }
        }

        //Create List Insert
        Map<String,String> newAppNoMap = new Map<String,String>();
        Map<String,List<Application_History__c>>  allApplicationMap = new Map<String,List<Application_History__c>>();
        for(CMAS__c eachCMAS : cmasList){
            if(workflowHistoryByCMASIdMap.containsKey(eachCMAS.CMAS_App_Id__c) && firstAppByCWUMap.containsKey(eachCMAS.CWU_REF_No__c)){
                List<CMAS_Workflow_History__c> tempWFList = workflowHistoryByCMASIdMap.get(eachCMAS.CMAS_App_Id__c);
                List<Application_History__c> tempAppList = new List<Application_History__c>();
                
                Integer countAPP = 1;
                String approvalUser = '';
                String submitIssue = '';
                Application_History__c tempApp = firstAppByCWUMap.get(eachCMAS.CWU_REF_No__c); // FirstAPP
                
                //if(creditTypeCodeMap.containsKey(eachCMAS.Credit_Type_Code__c)){
                //     submitIssue = creditTypeCodeMap.get(eachCMAS.Credit_Type_Code__c);
                //}

                tempApp.SP_Submit_Issue__c = tempApp.RMSubmitIssue__c;
                tempApp.ManualSP__c = True;
                if(eachCMAS.Business_Code__c !=null){
                    if(eachCMAS.Business_Code__c.length() > 9){
                        tempApp.SPBusinessCode__c = eachCMAS.Business_Code__c.substring(0, 9) ;
                    }else{
                        tempApp.SPBusinessCode__c = eachCMAS.Business_Code__c;  
                    }
                }
                
                for(CMAS_Workflow_History__c eachWF : tempWFList){
                    tempApp.ManualSP__c = True;
                    if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_CREATED){
                        tempApp.App_Num_CMAS__c = eachCMAS.CMAS_Reference_Number__c;
                        tempApp.CMAS_WF_Id__c = eachWF.WorkFlow_Transaction_Id__c;
                        tempApp.RMSubmitChannel__c = 'CMAS';
                        tempApp.SP_Credit_Model__c = tempApp.RMCreditModel__c;
                        tempApp.FirstSubmittedDate__c = tempApp.FirstApplicationSOReceiveDate__c;
                    }else if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_WITHDRAWN){
                        tempApp.SP_Approval_Result__c = GlobalConstants.DECLINE;
                        tempApp.SP_Approve_Option__c ='';
                    }else if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_PENDING_VERIFICATION){
                        tempApp.SP_Approval_Result__c = GlobalConstants.WORK_IN_PROGRESS;
                        tempApp.SP_Approve_Option__c ='';
                        tempApp.SP_CAPF_Received_DT__c = eachWF.To_Date__c.date();
                        tempApp.SP_CAPB_Workout_DT__c = eachWF.To_Date__c.date();
                    }else if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_APPROVED){
                        tempApp.SP_Approval_Result__c = GlobalConstants.FINAL_APPROVE;
                        tempApp.SP_Approve_Option__c = 'A';
                        tempApp.SP_CAPB_Workout_DT__c = eachWF.To_Date__c.date();
                    }else if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_APPROVED_WITH_CONDITION){
                        tempApp.SP_Approval_Result__c = GlobalConstants.FINAL_APPROVE;
                        tempApp.SP_Approve_Option__c = 'D';
                        tempApp.SP_CAPB_Workout_DT__c = eachWF.To_Date__c.date();
                    }else if(eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_APPLICATION_RETURNED || eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_REJECTED){
                        tempApp.SP_CAPB_Workout_DT__c = eachWF.To_Date__c.date();
                        tempApp.SP_Approval_Result__c = GlobalConstants.DECLINE;
                        tempApp.SP_Approve_Option__c ='';
                    }else if(eachWF.From_Status__c == GlobalConstants.CMAS_WF_ST_PENDING_UW_APPROVAL && eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_PENDING_CONCLUSION ){
                        if(approvalUser !=''){
                            approvalUser = approvalUser + ' | ' +eachWF.From_User__c;
                        }else{
                            approvalUser = eachWF.From_User__c;
                        }
                        tempApp.SP_UW_Name__c = approvalUser;
                    }else if(eachWF.From_Status__c == GlobalConstants.CMAS_WF_ST_PENDING_SUPERIOR_APPROVAL && eachWF.To_Status__c == GlobalConstants.CMAS_WF_ST_PENDING_RESUBMIT){
                        tempApp.IsLatestApp__c = false;
                        tempApp.App_Result__c = GlobalConstants.CANCELLED;
                        tempAppList.add(tempApp); //    Add New App to Loop                 
                        String newAPPNo = Cmas_Service.calculateCMASAppNo(eachCMAS.CMAS_Reference_Number__c,countAPP);
                        if(appHistoryByAPPNoMap.containsKey(newAPPNo)){
                            tempApp = appHistoryByAPPNoMap.get(newAPPNo);
                        }else{
                            tempApp = tempApp.clone(false,true);
                            tempApp.App_Num_CMAS__c  = Cmas_Service.calculateCMASAppNo(eachCMAS.CMAS_Reference_Number__c,countAPP);
                            tempApp.CMAS_WF_Id__c = eachWF.WorkFlow_Transaction_Id__c;
                            tempApp.SP_Approval_Result__c = '';
                            tempApp.ManualSP__c = True;
                            tempApp.App_Result__c = GlobalConstants.WORK_IN_PROGRESS;
                            tempApp.IS_Create_By_Integration__c  = true;
                            tempApp.SP_Approve_Option__c ='';
                            tempApp.SP_CAPB_Workout_DT__c = null;
                            tempApp.RMSubmitChannel__c = 'CMAS';
                            tempApp.Index__c = countAPP+1;
                            tempApp.SP_Credit_Model__c = tempApp.RMCreditModel__c;
                            tempApp.SP_Submit_Issue__c = tempApp.RMSubmitIssue__c;
                            tempApp.IsLatestApp__c = false;
                        }
                        
                        countAPP++;
                    }
                    tempApp.CMAS_Status__c = eachWF.To_Status__c ;      
                }
                tempAppList.add(tempApp);
                allApplicationMap.put(eachCMAS.CMAS_App_Id__c, tempAppList);
                
            }else{
                System.debug('Error CMAS ID Not Found :'+eachCMAS.Id);
            }

        }
        
        //List<Application_History__c> allAPPList = new List<Application_History__c>();
        List<Application_History__c> updatelist = new List<Application_History__c>(); 
        for( List<Application_History__c> appList : allApplicationMap.values() ){
            for(Application_History__c eachAPP :appList){
                if(eachAPP.OppName__r.StageName !=GlobalConstants.FINISHED){
                    updatelist.add(eachAPP);
                }
            }
        }
        
        TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
        if(!updatelist.isEmpty()){
            try{
                String errorMessage = '';
                Schema.SobjectField idField = Schema.getGlobalDescribe().get('Application_History__c').getDescribe().fields.getMap().get('Id');
                Database.UpsertResult[] srList = Database.upsert(updatelist,idField, false);
                Integer index  = 0;
                for (Database.UpsertResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            String errorId = (updatelist[index]!=null && updatelist[index].ID!=null)?updatelist[index].ID:''; 
                            errorMessage = errorMessage + ' Application History ID :'+ errorId + ' - Error Msg :'+ String.valueOf(err.getMessage()) +  '\n' ;
                        }
                    }
                    index++;
                }
                if(errorMessage != ''){
                    String emailSubject = 'CMAS Batch Application Error';
                    BulkAssignment_Email_Error__c customSettingMap = BulkAssignment_Email_Error__c.getInstance();
                    if(customSettingMap.toRecipients__c != null && customSettingMap.toRecipients__c != '' && customSettingMap.subjectMessage__c != null && customSettingMap.subjectMessage__c != ''){
                        String[] toRecipients = customSettingMap.toRecipients__c.split(',');
                        String[] ccRecipients = customSettingMap.ccRecipients__c.split(',');
                        GlobalUtility.sendEmail(toRecipients, ccRecipients, customSettingMap.senderDisplayName__c, emailSubject, errorMessage);
                    }
                }
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }

        //End Update & Create APP By Worlflow

        //Calculate Facility
        List<CMAS_Fac_Info__c>  updateFacInfoList = new List<CMAS_Fac_Info__c>();
        List<Application_History__c>  updateAppHisSumFacility = new List<Application_History__c>();
        List<Id> removeCreditInfoByOppIdSet = new List<Id>();
        List<Credit_Info__c>  creditInfoList = new List<Credit_Info__c>();
        List<String> exitsCMASAppIDList = new List<String>();
        
        for(String cmasAppID : allApplicationMap.keySet()){
            List<Application_History__c>  tmpLoopAppHis = allApplicationMap.get(cmasAppID);             
            Boolean createOppProduct = false;
            if(tmpLoopAppHis.size() > 0){
                Integer maxIndex = tmpLoopAppHis.size() - 1;
                Application_History__c  appHisLastUpdate = tmpLoopAppHis.get(maxIndex);
                removeCreditInfoByOppIdSet.add(appHisLastUpdate.OppName__c);
                if(appHisLastUpdate.SP_Approval_Result__c == GlobalConstants.WORK_IN_PROGRESS || appHisLastUpdate.SP_Approval_Result__c == GlobalConstants.FINAL_APPROVE){
                    createOppProduct = true; 
                }
                if(facInfoByCMASIdMap.containsKey(cmasAppID)){
                    Decimal sumSPRequestAmt = 0;
                    Decimal sumSPCancelledRequestAmount = 0;
                    Decimal sumSPApprovedAmt = 0;
                    Decimal sumSPCancelledApproveAmount = 0;
                    List<CMAS_Fac_Info__c> tmpFacList = facInfoByCMASIdMap.get(cmasAppID);

                    Map<String,Credit_Info__c> oppProductTmpMap = new Map<String,Credit_Info__c>();

                    for(CMAS_Fac_Info__c  eachCMASFacInfo : tmpFacList){
                        if(createOppProduct){
                            if(eachCMASFacInfo.CMAS_FAC_Calculated__c != true && eachCMASFacInfo.CMAC_FAC_Active__c !=false){
                                Credit_Info__c tempOppProduct;
                                if(oppProductTmpMap.containsKey(eachCMASFacInfo.Facility_Code__c)){
                                    tempOppProduct = oppProductTmpMap.get(eachCMASFacInfo.Facility_Code__c);
                                    if(eachCMASFacInfo.Facility_Limit_Proposed__c > eachCMASFacInfo.Facility_Exiting__c){
                                        tempOppProduct.Requested_Amount__c =  tempOppProduct.Requested_Amount__c + (eachCMASFacInfo.Facility_Limit_Proposed__c - eachCMASFacInfo.Facility_Exiting__c);
                                    }
                                    if(eachCMASFacInfo.Facility_Limit_Approved__c > eachCMASFacInfo.Facility_Exiting__c){
                                        tempOppProduct.Approved_Amount__c =  tempOppProduct.Approved_Amount__c + (eachCMASFacInfo.Facility_Limit_Approved__c - eachCMASFacInfo.Facility_Exiting__c);
                                    }
                                    if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Approved__c ){
                                        tempOppProduct.Cancel_Approve__c =  tempOppProduct.Cancel_Approve__c + (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Approved__c);
                                    }
                                    if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Proposed__c ){
                                        tempOppProduct.Cancel_Request__c =  tempOppProduct.Cancel_Request__c + (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Proposed__c);
                                    }
                                    if(tempOppProduct.Cancel_Request__c !=0){
                                        if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Approved__c ){
                                            tempOppProduct.Cancel_Approve__c =  tempOppProduct.Cancel_Approve__c + (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Approved__c);
                                        }
                                    }else{
                                        tempOppProduct.Cancel_Approve__c = 0;
                                    }
                                }else{  //New Opp Product
                                    tempOppProduct= new Credit_Info__c ();
                                    tempOppProduct.Application_History__c = appHisLastUpdate.Id;
                                    tempOppProduct.Application_Number__c = cmasAppID+':'+eachCMASFacInfo.Facility_Code__c;
                                    tempOppProduct.Requested_Amount__c = 0;
                                    tempOppProduct.Approved_Amount__c = 0;
                                    tempOppProduct.Cancel_Approve__c = 0;
                                    tempOppProduct.Cancel_Request__c = 0;
                                    if(eachCMASFacInfo.Facility_Limit_Proposed__c > eachCMASFacInfo.Facility_Exiting__c){
                                        tempOppProduct.Requested_Amount__c = (eachCMASFacInfo.Facility_Limit_Proposed__c - eachCMASFacInfo.Facility_Exiting__c);
                                    }
                                    if(eachCMASFacInfo.Facility_Limit_Approved__c > eachCMASFacInfo.Facility_Exiting__c){
                                        tempOppProduct.Approved_Amount__c = (eachCMASFacInfo.Facility_Limit_Approved__c - eachCMASFacInfo.Facility_Exiting__c);
                                    }
                                    if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Proposed__c ){
                                        tempOppProduct.Cancel_Request__c =  (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Proposed__c);
                                    }
                                    if(tempOppProduct.Cancel_Request__c !=0){
                                        if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Approved__c ){
                                            tempOppProduct.Cancel_Approve__c = (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Approved__c);
                                        }
                                    }else{
                                        tempOppProduct.Cancel_Approve__c = 0;
                                    }
                                    
                                    tempOppProduct.COA_Product_Feature_Code__c = eachCMASFacInfo.Facility_Code__c;
                                    if(allPIMCodeMap.containsKey(eachCMASFacInfo.Facility_Code__c)){
                                        PIM__c pimObj = allPIMCodeMap.get(eachCMASFacInfo.Facility_Code__c);
                                        tempOppProduct.COA_Product_Group_English__c = pimObj.Product_Group_English__c;
                                        tempOppProduct.COA_Product_Name_English__c = pimObj.Product_Name_English__c;
                                        tempOppProduct.COA_Product_subGroup_English__c = pimObj.Product_subGroup_English__c;
                                    }else{
                                        tempOppProduct.COA_Product_Group_English__c  = Label.CMAS_Product_Name_Others;
                                        tempOppProduct.COA_Product_Name_English__c  = Label.CMAS_Product_Name_Others;
                                        tempOppProduct.COA_Product_subGroup_English__c  = Label.CMAS_Product_Name_Others;
                                    }
                                }
                                oppProductTmpMap.put(eachCMASFacInfo.Facility_Code__c,tempOppProduct);
                            }
   
                        }
                        
                        if(eachCMASFacInfo.CMAS_FAC_Calculated__c != true && eachCMASFacInfo.CMAC_FAC_Active__c !=false){
                            if(eachCMASFacInfo.Facility_Limit_Proposed__c > eachCMASFacInfo.Facility_Exiting__c){
                                sumSPRequestAmt =  sumSPRequestAmt + (eachCMASFacInfo.Facility_Limit_Proposed__c - eachCMASFacInfo.Facility_Exiting__c);
                            }
                            if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Proposed__c ){
                                sumSPCancelledRequestAmount =  sumSPCancelledRequestAmount + (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Proposed__c);
                            }
                            if(eachCMASFacInfo.Facility_Limit_Approved__c > eachCMASFacInfo.Facility_Exiting__c){
                                sumSPApprovedAmt =  sumSPApprovedAmt + (eachCMASFacInfo.Facility_Limit_Approved__c - eachCMASFacInfo.Facility_Exiting__c);
                            }
                            
                            if(sumSPCancelledRequestAmount != 0){
                                if(eachCMASFacInfo.Facility_Exiting__c > eachCMASFacInfo.Facility_Limit_Approved__c ){
                                    sumSPCancelledApproveAmount =  sumSPCancelledApproveAmount + (eachCMASFacInfo.Facility_Exiting__c - eachCMASFacInfo.Facility_Limit_Approved__c);
                                }
                            }else{
                                sumSPCancelledApproveAmount = 0;
                            }
                            eachCMASFacInfo.CMAS_FAC_Calculated__c = true;
                        }else{
                            eachCMASFacInfo.CMAC_FAC_Active__c = false;
                        }
                        updateFacInfoList.add(eachCMASFacInfo);
                        
                    }
                    creditInfoList.addAll(oppProductTmpMap.values());
                    appHisLastUpdate.SP_Requested_Amt__c = sumSPRequestAmt;
                    appHisLastUpdate.SP_Cancel_Requested_Amt__c = sumSPCancelledRequestAmount;
                    appHisLastUpdate.SP_Approved_Amt__c = sumSPApprovedAmt;
                    appHisLastUpdate.SP_Cancel_Approved_Amt__c = sumSPCancelledApproveAmount;
                    appHisLastUpdate.ManualSP__c = True;
                    if(maxIndex == 0){
                        appHisLastUpdate.FirstRequestedAmt__c = appHisLastUpdate.SP_Requested_Amt__c;
                    }
                    updateAppHisSumFacility.add(appHisLastUpdate);
                    exitsCMASAppIDList.add(cmasAppID);
                }
            }
        }

        if(!updateFacInfoList.isEmpty()){
            DB_Service.updateSObject(updateFacInfoList,false);
        }
        
        if(!updateAppHisSumFacility.isEmpty()){
            DB_Service.updateSObject(updateAppHisSumFacility,false);
        }
   
        TriggerHandler.clearBypass('ApplicationHistoryTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        if(!removeCreditInfoByOppIdSet.isEmpty()){
            delete [SELECT Id FROM Credit_Info__c WHERE CMAS_App_Id__c =:exitsCMASAppIDList];
        }
        if(!creditInfoList.isEmpty()){
            Schema.SobjectField appNumberField = Schema.getGlobalDescribe().get('Credit_Info__c').getDescribe().fields.getMap().get('Application_Number__c');
            Database.UpsertResult[] srList = Database.upsert(creditInfoList,appNumberField, false);
        }
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}