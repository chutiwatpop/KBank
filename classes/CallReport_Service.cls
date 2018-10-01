/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
* @17/07/2015 remove future annotation, change delete condition from whatid to Call_Plan_Call_Report__c, use upsert instead of insert due to additional req.
* @07/02/2017 Remove unused code
*/
public class CallReport_Service {
    public static Set<ID> callReportRelateIDSet;
    
    public static List<User_Extension__c> userExtList;
    public static List<Team_Structure__c> teamStructureList;
    public static List<Call_Report_Opportunity__c> callReportOpptyList;
    public static Map<Id,Account> accountMap;
    public static Map<Id,Account> accountMapByCallReportCustomer;
    public static Map<Id,User> userMapByCallReportCreateby;
    

    public static void updateEvent(List<sObject> sObjectList){
        //try{
            update sObjectList;
        //}catch(DMLException dex){
            //throw
        //}
    }
    public static void insertEvent(List<sObject> sObjectList){
        //try{
            insert sObjectList;
        //}catch(DMLException dex){
            //throw
        //}
    }
    public static void deleteEvent(Set<Id> callReportIdSet){
        //try{
            delete [SELECT Id FROM Event WHERE Call_Plan_Call_Report__c IN:callReportIdSet];
        //}catch(DMLException dex){system.debug('DML Exception : ' + dex);}
    }
        
    public static Map<Id,Account> getAccountMapByCallReportCustomer(List<Call_Report__c> callReportList){
        Set<Id> accountSet = getAccountIdsFromCallReport(callReportList);
        
        Map<Id,Account> accountMapResult = new Map<Id,Account>();

        //SME-Campaign/Lead'
        accountMapResult = new Map<Id,Account>([SELECT Id,First_Visited_Date__c,Last_Visited_By__c,Trash_Pool_Flag__c,Current_Activity__c,Current_Activity_By__c,Ownership_Text__c,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c, Owner_Emp_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, CIS__c,Identification_No__c,Temp_Owner_Changed_Date__c,Customer_Owner_Release_Flag__c,Name,Port_Pool__c,OwnerId,Owner.Profile.Name,Owner.ManagerId,Owner.AH_RC_CODE__c,Owner.NH_RC_CODE__c,Previous_Owner__c,Customer_Importance_Note__c,RecordTypeId,RecordType.Name,Birthdate_Registration_Date__c,Identification_No_Prospect__c,(SELECT Id,Lead_Type__c,CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.Name_Surname_TH__c FROM Campaign_Members_Leads__r WHERE Lead_Campaign__r.IsActive=true AND Status__c='New' AND Lead_Campaign__r.Sub_Type__c IN ('Strong Hybrid','Strong Formula','Refinance','Cheque','Refer','BA','LI', 'Account Plan',null) AND (Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES OR Lead_Type__c =: GlobalConstants.LEAD_TO_DO OR Lead_Type__c =: GlobalConstants.LEAD_TO_INFORM)) FROM Account WHERE Id IN :accountSet]);
        return accountMapResult;
    }

    public static Set<Id> getAccountIdsFromCallReport(List<Call_Report__c> callReportList){
        Set<Id> accountSet = new Set<Id>();
        
        for(Call_Report__c eachCallReport : (List<Call_Report__c>)callReportList){
            accountSet.add(eachCallReport.CIS_ID__c);
        }

        return accountSet;
    }

    public static Map<Id,User> getUserMapByCallReportCreateby(List<Call_Report__c> callReportList){
        Set<Id> userSet = new Set<Id>();
        
        Map<Id,User> userMap = new Map<Id,User>();

        for(Call_Report__c eachCallReport : (List<Call_Report__c>) callReportList){
            System.debug('CreatedById : '+eachCallReport.CreatedById);
            userSet.add(eachCallReport.CreatedById);
        }
        userMap = new Map<Id,User>([SELECT Id,ManagerId FROM User WHERE Id IN :userSet]);
        return userMap;
    }

    public static void updateActualVisitDateOfOpp(Set<Id> oppIdSet) {
        List<Call_Report_Opportunity__c> callReportOppList = [SELECT Id, Opportunity_Name__c, Call_Plan_Call_Report__r.Actual_visit_Date__c FROM Call_Report_Opportunity__c WHERE Opportunity_Name__c IN :oppIdSet AND Call_Plan_Call_Report__r.IsSLACount__c = true ORDER BY Call_Plan_Call_Report__r.Actual_visit_Date__c ASC];
        Map<Id, Opportunity> oppMapByIdForUpdate = new Map<Id, Opportunity>();
        for(Call_Report_Opportunity__c callReportOpp : callReportOppList) {
            if(!oppMapByIdForUpdate.containsKey(callReportOpp.Opportunity_Name__c)) {
                Opportunity updateOpp = new Opportunity(Id = callReportOpp.Opportunity_Name__c, 
                                                        Actual_visit_Date__c = callReportOpp.Call_Plan_Call_Report__r.Actual_visit_Date__c);
                oppMapByIdForUpdate.put(callReportOpp.Opportunity_Name__c, updateOpp);
            }
        }

        if(!oppMapByIdForUpdate.isEmpty()) {
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update oppMapByIdForUpdate.values();
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }
    // Edit For INC000000570851
    public static Map<Id,User_Extension__c> getMapActiveUserExtForCreateMonthly(Date thisday){
        Integer yearToQuery = GlobalUtility.getYearInChristianCalendar(thisday);
        List<Call_Report__c> callReportList = [SELECT Id,Current_Owner_Extension__c From Call_Report__c WHERE CALENDAR_MONTH(Actual_visit_Date__c) = :thisday.month() AND CALENDAR_YEAR(Actual_visit_Date__c) = :yearToQuery ];
        Set<Id> userSet = new Set<Id>();
        for(Call_Report__c eachCallReport : callReportList){
            userSet.add(eachCallReport.Current_Owner_Extension__c);
        }
        Map<Id,User_Extension__c> activeUserExtMapByCallReportOwner = new Map<Id,User_Extension__c>([SELECT Id FROM User_Extension__c WHERE Id IN :userSet OR Active__c = TRUE]);
        return activeUserExtMapByCallReportOwner;
    }
    
    /*Taranyoo.B Used in inCBS_CallReportNewEdit_Controller*/
    public static List<Call_Report__c> getCallPlanForEditPage(Id callPlanId){
        String getCallPlanQuery = 'SELECT Id, Name, Wallet_Size_Credit_Limit__c, SOW_Credit_Limit__c, Wallet_Size_Credit_Outstanding__c, SOW_Credit_Outstanding__c, Wallet_Size_Credit_Exposure__c, SOW_Credit_Exposure__c, CIS_ID__c, Plan_Date__c, Planned_Visit_Objective_CBS__c, Planned_Product_CBS__c, Note_CBS__c, Status__c, Status_Display__c FROM Call_Report__c WHERE Id =: callPlanId';
        List<Call_Report__c> callPlanObjects = Database.query(getCallPlanQuery);
        return callPlanObjects;
    }
    /*Taranyoo.B Used in inCBS_CallReportNewEdit_Controller*/

    //Add Service CallOppty by chansak.s
    public static List<Call_Report_Opportunity__c> getCallReportOpptyRelationByCRID(Set<ID> callReportSet){
        //
        if(CallReport_Service.callReportRelateIDSet == null){
            CallReport_Service.callReportRelateIDSet = callReportSet;
        }
        if(!CallReport_Service.callReportRelateIDSet.containsAll(callReportSet) || CallReport_Service.callReportOpptyList == null){
            CallReport_Service.callReportOpptyList = [SELECT Id, Opportunity_Name__c, Call_Plan_Call_Report__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c IN :callReportSet];
        }

        return CallReport_Service.callReportOpptyList;
    }

    public static Map<Id,Customer_Business_Code__c> setBusinessCodeSnapshotInCallReport(List<Call_Report__c> callReportList,Set<Id> customerBusinessCodeList){
        //Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById = new Map<Id,Customer_Business_Code__c>([SELECT CIS__c,Industry_Risk_Rating__c,Ratio__c,Room_Left__c,Business_Code__c,Risky_Control_FL__c,Exception_FL__c,Risky_Control_HPL__c,Exception_HPL__c,Risky_Control_PL__c,Exception_PL__c,Business_Code__r.Name,Description__c,Keyword__c From Customer_Business_Code__c WHERE Id IN :customerBusinessCodeList]);
        Map<Id,Customer_Business_Code__c> customerBusinessCodeMapById = Customer_BusinessCode_Service.getCustomerBusinessCodeMapById(customerBusinessCodeList);
        for(Call_Report__c eachCallReport : callReportList){
            if(eachCallReport.Customer_Business_Code__c != null && customerBusinessCodeMapById.containsKey(eachCallReport.Customer_Business_Code__c)){
                Customer_Business_Code__c eachCustomerBusinessCode = customerBusinessCodeMapById.get(eachCallReport.Customer_Business_Code__c);
                CallReport_Service.setBusinessCodeDataInCallReport(eachCallReport,eachCustomerBusinessCode);
            }
        }
        Customer_BusinessCode_Service.setLatestUsedCustomerBusinessCode(customerBusinessCodeMapById);
        return customerBusinessCodeMapById;
    }

    public static void setBusinessCodeDataInCallReport(Call_Report__c callreport,Customer_Business_Code__c customerBusinessCode){
        String riskyControl;
        String exceptionText;
        if(callreport.Estimate_Credit_Model__c == GlobalConstants.ESTIMATE_CREDIT_MODEL_FL){
            riskyControl = customerBusinessCode.Risky_Control_FL__c;
            exceptionText = customerBusinessCode.Exception_FL__c;
        }else if(callreport.Estimate_Credit_Model__c == GlobalConstants.ESTIMATE_CREDIT_MODEL_HPL){
            riskyControl = customerBusinessCode.Risky_Control_HPL__c;
            exceptionText = customerBusinessCode.Exception_HPL__c;
        }else if(callreport.Estimate_Credit_Model__c == GlobalConstants.ESTIMATE_CREDIT_MODEL_PL){
            riskyControl = customerBusinessCode.Risky_Control_PL__c;
            exceptionText = customerBusinessCode.Exception_PL__c;
        }
        callreport.Risky_Control__c = riskyControl;
        callreport.Exception__c = exceptionText;

        callreport.Business_Code_Text__c = customerBusinessCode.Business_Code__r.Name;
        callreport.Description__c = customerBusinessCode.Description_Text__c;
        callreport.Keyword__c = customerBusinessCode.Keyword_Text__c;
        callreport.Industry_Room_Left__c = customerBusinessCode.Room_Left__c;
        callreport.Ratio__c = String.valueOf(customerBusinessCode.Ratio__c);
        callreport.Industry_Risk_Rating__c = customerBusinessCode.Industry_Risk_Rating__c;

    }
    
}