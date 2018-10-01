public without sharing class CampaignLead_Service {
    //private static Set<String> expectOppStageSet;
    //private static Set<String> callReportRecordTypeDevNameSet;
    //private static Set<String> callPlanRecordTypeDevNameSet;
    //private static Map<Id, String> recordTypeDevNameMapById;
    //public static List<Id> oppLeadAssoList = new List<Id>();
    //public static List<Id> callReportLeadAssoList = new List<Id>();
    //public static List<Opportunity> updateOpportunityStatus = new List<Opportunity>();

    //public static Set<String> getCallPlanRecordTypeDevName() {
    //    return new Set<String>{
    //    GlobalConstants.CALL_PLAN_DEVNAME,
    //    GlobalConstants.CLOSED_CANCELLED_CALLPLAN_DEVNAME,
    //    GlobalConstants.NEW_CALL_PLAN_DEVNAME,
    //    GlobalConstants.CBS_CALL_PLAN_DEVNAME,
    //    GlobalConstants.CBS_CLOSED_CANCELLED_CALLPLAN_DEVNAME };
    //}

    //public static Set<String> getCallReportRecordTypeDevName() {
    //    return new Set<String>{
    //    GlobalConstants.CALL_REPORT_DEVNAME,
    //    GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME,
    //    GlobalConstants.CONTACTED_CALLREPORT_E_LEAD_DEVNAME,
    //    GlobalConstants.CONTACTED_CALLREPORT_NO_P_E_DEVNAME,
    //    GlobalConstants.CONTACTED_CALLREPORT_NO_P_LAYOUT_DEVNAME,
    //    GlobalConstants.CONTACTED_SECONDARY_MAIN_BORROWER_NO_P_DEVNAME,
    //    GlobalConstants.CLOSED_CANCELLED_CALLREPORT_DEVNAME,
    //    GlobalConstants.CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME,
    //    GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME,
    //    GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME,

    //    GlobalConstants.CBS_CALL_REPORT_DEVNAME,
    //    GlobalConstants.CBS_CALL_REPORT_NO_PLAN_DEVNAME,
    //    GlobalConstants.CBS_CLOSED_CANCELLED_CALLREPORT_DEVNAME,
    //    GlobalConstants.CBS_CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME,
    //    GlobalConstants.CBS_CONTACTED_CALLREPORT_NO_P_E_DEVNAME,
    //    GlobalConstants.CBS_CONTACTED_CALLREPORT_E_LEAD_DEVNAME};
    //}

    //public static Set<String> getExpectOppStageSet() {
    //    Set<String> oppStageNameSet = new Set<String>{
    //        GlobalConstants.STOCK_NEGOTIATION,
    //        GlobalConstants.CREATE_WRITE_UP,
    //        GlobalConstants.WAITING_FOR_CREDIT_APPROVAL,
    //        GlobalConstants.CREDIT_APPROVAL_PROCESS,
    //        GlobalConstants.CASE_IS_REJECT,
    //        GlobalConstants.WAITING_FOR_CREDIT_SETUP,
    //        GlobalConstants.PARTIAL_LOAN_SETUP,
    //        GlobalConstants.ALL_LOAN_SETUP,
    //        GlobalConstants.CLOSE_LOST,
    //        GlobalConstants.AUTO_CLOSED,
    //        GlobalConstants.DELETED_OPPORTUNITY,
    //        GlobalConstants.CLOSED_WON,
    //        GlobalConstants.NEW_OPPORTUNITY
    //    };

    //    return oppStageNameSet;
    //}

    //public static Set<String> getClosedOppStageSet() {
    //    return new Set<String>{
    //        GlobalConstants.OPP_PLAN_LOST,
    //        GlobalConstants.OPP_PLAN_CANCELLED,
    //        GlobalConstants.OPP_PLAN_REJECTED,
    //        GlobalConstants.AUTO_CLOSED,
    //        GlobalConstants.CLOSE_LOST,
    //        GlobalConstants.DELETED_OPPORTUNITY
    //    };
    //}

    //public static Map<Id, String> getRecordTypeDevNameMapById() {
    //    return GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Call_Report__c');
    //}

    //public static Boolean isCallPlan(Id recTypeId) {
    //    if(recordTypeDevNameMapById == null) {
    //        recordTypeDevNameMapById = getRecordTypeDevNameMapById();
    //    }
    //    if(callPlanRecordTypeDevNameSet == null) {
    //        callPlanRecordTypeDevNameSet = getCallPlanRecordTypeDevName();
    //    }
    //    if(callPlanRecordTypeDevNameSet.contains(recordTypeDevNameMapById.get(recTypeId))) {
    //        return true;
    //    }
    //    return false;
    //}

    //public static Boolean isCallReport(Id recTypeId) {
    //    if(recordTypeDevNameMapById == null) {
    //        recordTypeDevNameMapById = getRecordTypeDevNameMapById();
    //    }
    //    if(callReportRecordTypeDevNameSet == null) {
    //        callReportRecordTypeDevNameSet = getCallReportRecordTypeDevName();
    //    }
    //    if(callReportRecordTypeDevNameSet.contains(recordTypeDevNameMapById.get(recTypeId))) {
    //        return true;
    //    }
    //    return false;
    //}

    //public static Boolean isSecondaryCallReport(Id recTypeId) {
    //    if(recordTypeDevNameMapById == null) {
    //        recordTypeDevNameMapById = getRecordTypeDevNameMapById();
    //    }
    //    if(recordTypeDevNameMapById.get(recTypeId) == GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME || 
    //        recordTypeDevNameMapById.get(recTypeId) == GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME ||
    //        recordTypeDevNameMapById.get(recTypeId) == GlobalConstants.CONTACTED_SECONDARY_MAIN_BORROWER_NO_P_DEVNAME) {
    //        return true;
    //    }
    //    return false;
    //}

    //public static Boolean isConvertCallPlanToCallReport(Call_Report__c eachCallReport) {
    //    if(isCallReport(eachCallReport.RecordTypeId) && eachCallReport.Plan_Date__c != null){
    //        return true;
    //    }
    //    return false;
    //}

    //public static String getNewLeadStatus(String leadType, Call_Report__c eachCallReport, String oppStage) {
    //    String newStatus = null;
    //    if(CampaignLead_Service.expectOppStageSet == null) 
    //        CampaignLead_Service.expectOppStageSet = CampaignLead_Service.getExpectOppStageSet();

    //    if (leadType == GlobalConstants.LEAD_FOR_SALES) {
    //        if(eachCallReport != null) {
    //            if(isCallPlan(eachCallReport.RecordTypeId) && eachCallReport.Status__c == GlobalConstants.PLAN) {
    //                newStatus = GlobalConstants.PLAN;
    //            } else  if (eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_CANNOT_APPLY) {
    //                newStatus = GlobalConstants.NOT_INTERESTED_THIS_TIME;
    //            } else if (eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_NOT_INTEREST || eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_CUSTOMER_NOT_INTERESTED) {
    //                newStatus = GlobalConstants.NOT_INTERESTED;
    //            } else if (eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_CUSTOMER_INTERESTED || eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY || eachCallReport.Offer_Interest__c == GlobalConstants.OFFER_INTEREST_WITH_CONDITION) {
    //                newStatus = GlobalConstants.CUSTOMER_INTERESTED;
    //            }
    //        }
    //        if(oppStage != null) {
    //            if(CampaignLead_Service.expectOppStageSet.contains(oppStage))
    //                newStatus = oppStage;    
    //        }
    //    } 
    //    else if (leadType == GlobalConstants.LEAD_TO_DO || leadType == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER) {
    //        if(eachCallReport != null) {
    //            if(isConvertCallPlanToCallReport(eachCallReport)) {
    //                newStatus = GlobalConstants.PLAN;
    //            }else if(isCallReport(eachCallReport.RecordTypeId)){
    //                newStatus = GlobalConstants.STATUS_NEW;
    //            }else if(isCallPlan(eachCallReport.RecordTypeId)){
    //                newStatus = GlobalConstants.PLAN;
    //            }else {
    //                newStatus = GlobalConstants.STATUS_NEW;
    //            }                
    //        }
    //    }
    //    return newStatus;
    //}

    //private static SObject checkPossibleLeadPriority(Target_List__c targerListValue ,Map<Id,Opportunity> possibleOppMap, Map<Id,Call_Report__c> possibleCallPlanMap, Map<Id,Call_Report__c> possibleCallReportMap){
    //    if(targerListValue.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES || targerListValue.Lead_Type__c == GlobalConstants.LEAD_TO_DO){
    //        if(possibleOppMap.size() > 0 && targerListValue.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES){
    //            for(Opportunity eachPossibleOpp : possibleOppMap.values()){
    //                if(!GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(eachPossibleOpp.StageName)){
    //                    Opportunity_Lead__c newOppLead = new Opportunity_Lead__c(
    //                    Opportunity__c = eachPossibleOpp.Id,
    //                    Target_List__c = targerListValue.Id,
    //                    Is_Focusing__c = true,
    //                    Opportunity_Lead_Status__c = CampaignLead_Service.getNewLeadStatus(targerListValue.Lead_Type__c, null, eachPossibleOpp.StageName)
    //                    );
    //                    return newOppLead;
    //                }
    //            }
    //        }
    //        if(possibleCallReportMap.size() > 0){
    //            for(Call_Report__c eachPossibleCallReport : possibleCallReportMap.values()){
    //                if(eachPossibleCallReport.Offer_Credit_Product__c || eachPossibleCallReport.Negotiation__c || eachPossibleCallReport.Collect_Documents__c){

    //                    Call_Report_Lead__c newCallReportLead = new Call_Report_Lead__c(
    //                    Call_Plan_Call_Report__c = eachPossibleCallReport.Id,
    //                    Target_List__c = targerListValue.Id,
    //                    Call_Report_Lead_Status__c = CampaignLead_Service.getNewLeadStatus(targerListValue.Lead_Type__c, eachPossibleCallReport, null));
    //                    if(eachPossibleCallReport.Offer_Interest__c != '' && eachPossibleCallReport.Offer_Interest__c != null){
    //                        return newCallReportLead;
    //                    }
    //                }
    //            }
    //        }
    //        if(possibleCallPlanMap.size() > 0 && targerListValue.Status__c != GlobalConstants.STATUS_DONE){
    //            for(Call_Report__c eachPossibleCallPlan : possibleCallPlanMap.values()){
    //                if(eachPossibleCallPlan.Status__c.equalsIgnoreCase(GlobalConstants.Plan)){

    //                    Call_Report_Lead__c newCallPlanLead = new Call_Report_Lead__c(
    //                    Call_Plan_Call_Report__c = eachPossibleCallPlan.Id,
    //                    Target_List__c = targerListValue.Id,
    //                    Call_Report_Lead_Status__c = CampaignLead_Service.getNewLeadStatus(targerListValue.Lead_Type__c, eachPossibleCallPlan, null)
    //                    );
    //                    return newCallPlanLead;
    //                }

    //            }
    //        }

    //        return null;
    //    }else

    //    return null;
    //}

    //public static void createLeadBackwardAssociated(){
    //    if(oppLeadAssoList.size()>0){
    //        List<Call_Report_Opportunity__c> possibleAssoCallReportOppList = [SELECT Call_Plan_Call_Report__c,Id,Name,Opportunity_Name__c,Stage__c,Status__c,Opportunity_Name__r.IsConvertFromCallReport__c FROM Call_Report_Opportunity__c WHERE Opportunity_Name__c IN:oppLeadAssoList];
    //        if(possibleAssoCallReportOppList.size() > 0){
    //            for(Call_Report_Opportunity__c eachPossibleAssoCallReportOpp:possibleAssoCallReportOppList){
    //                callReportLeadAssoList.add(eachPossibleAssoCallReportOpp.Call_Plan_Call_Report__c);
    //            }
    //        }
    //    }

    //    Map<Id,List<Call_Report__c>> possiblePrimaryCallReportWithSecondaryMap = new Map<Id,List<Call_Report__c>>();
    //    Map<Id,Target_List__c> possiblePrimaryCallReportWithTargetListMap = new Map<Id,Target_List__c>();
    //    Id RECORDTYPE_SME_CUSTOMER = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
    //    Id RECORDTYPE_SME_PROSPECT = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT);

    //    Map<Id,List<Call_Report__c>> possibleAssoCallReportListMapByPrimaryCallReport = new Map<Id,List<Call_Report__c>>();
    //    Map<Id,Target_List__c> possibleMainTargetListWithAssoMapByPrimaryCallReport = new Map<Id,Target_List__c>();

    //    if(!callReportLeadAssoList.isEmpty()){
    //        List<Call_Report__c> possibleAssoCallReportList = [SELECT Id, Primary_Call_Plan_Call_Report__c, RecordTypeId, RecordType.DeveloperName, Plan_Date__c, CIS_ID__c, Name, Status__c, Offer_Interest__c FROM Call_Report__c WHERE Primary_Call_Plan_Call_Report__c IN :callReportLeadAssoList];
            
    //        if(!possibleAssoCallReportList.isEmpty()){
    //            for(Call_Report__c eachPossibleCallReportAsso : possibleAssoCallReportList){
    //                if(!possibleAssoCallReportListMapByPrimaryCallReport.containsKey(eachPossibleCallReportAsso.Primary_Call_Plan_Call_Report__c)){
    //                    possibleAssoCallReportListMapByPrimaryCallReport.put(eachPossibleCallReportAsso.Primary_Call_Plan_Call_Report__c,new List<Call_Report__c>());
    //                }
    //                possibleAssoCallReportListMapByPrimaryCallReport.get(eachPossibleCallReportAsso.Primary_Call_Plan_Call_Report__c).add(eachPossibleCallReportAsso);
    //            }
    //        }

    //        List<Call_Report_Lead__c> possibleCallReportLeadOfPrimaryCallReport = [SELECT Call_Plan_Call_Report__c,Call_Plan_Call_Report__r.CIS_ID__c,Call_Plan_Call_Report__r.CIS_ID__r.Id,Call_Plan_Call_Report__r.CIS_ID__r.CIS__c,Call_Plan_Call_Report__r.CIS_ID__r.RecordTypeId,Call_Plan_Call_Report__r.CIS_ID__r.Name,Call_Plan_Call_Report__r.RecordTypeId,Call_Plan_Call_Report__r.Status__c,Call_Plan_Call_Report__r.Offer_Interest__c,Call_Plan_Call_Report__r.Plan_Date__c, Call_Plan_Call_Report__r.Primary_Call_Plan_Call_Report__c ,Target_List__r.Id,Target_List__r.Lead_Type__c,Target_List__r.Lead_Campaign__r.Add_Associated_Lead__c,Target_List__r.Lead_Campaign__r.Name,Type__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c IN :callReportLeadAssoList];
    //        if(!possibleCallReportLeadOfPrimaryCallReport.isEmpty()){
    //            for(Call_Report_Lead__c eachCallLead : possibleCallReportLeadOfPrimaryCallReport){
    //                if(!possibleMainTargetListWithAssoMapByPrimaryCallReport.containsKey(eachCallLead.Call_Plan_Call_Report__c)){
    //                    possibleMainTargetListWithAssoMapByPrimaryCallReport.put(eachCallLead.Call_Plan_Call_Report__c,eachCallLead.Target_List__r);
    //                }
    //            }
    //        }
    //    }

    //    if(!possibleAssoCallReportListMapByPrimaryCallReport.isEmpty()){
    //        Map<String,Target_List__c> newPossibleAssoTargetList = new Map<String,Target_List__c>();

    //        for(Id eachPossiblePrimaryCallReportId : possibleAssoCallReportListMapByPrimaryCallReport.keySet()){
    //            for(Call_Report__c eachPossiblePrimaryCallReportWithSecondary : possibleAssoCallReportListMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId)){
    //                String newStatus = CampaignLead_Service.getNewLeadStatus(possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Lead_Type__c, eachPossiblePrimaryCallReportWithSecondary, null);
    //                if(possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Lead_Campaign__r.Add_Associated_Lead__c){
    //                    Target_List__c tempNewTargetList = new Target_List__c();
    //                    tempNewTargetList.IsFromTrigger__c = true;
    //                    tempNewTargetList.Status__c = newStatus;
    //                    tempNewTargetList.CIS_ID_Prospect_Name__c = eachPossiblePrimaryCallReportWithSecondary.CIS_ID__c;
    //                    tempNewTargetList.Lead_Campaign__c = possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Lead_Campaign__c;
    //                    tempNewTargetList.Main_Customer__c = possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Id;
    //                    tempNewTargetList.External_ID__c = String.valueOf(possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Lead_Campaign__r.Name)+ ':' +String.valueOf(eachPossiblePrimaryCallReportWithSecondary.CIS_ID__c);
    //                    tempNewTargetList.External_ID_CDB__c = String.valueOf(possibleMainTargetListWithAssoMapByPrimaryCallReport.get(eachPossiblePrimaryCallReportId).Lead_Campaign__r.Name)+ ':' +String.valueOf(eachPossiblePrimaryCallReportWithSecondary.CIS_ID__c);
                        
    //                    newPossibleAssoTargetList.put(tempNewTargetList.External_ID__c,tempNewTargetList);
    //                }
    //            }
    //        }

    //        if(!newPossibleAssoTargetList.isEmpty()){
    //            upsert newPossibleAssoTargetList.values() External_ID__c;
    //        }
    //    }
    //}

    //public static void createLeadBackward(List<Target_List__c> targetList) {
    //    Map<Id,List<Target_List__c>> accountTargetListMap = new Map<Id,List<Target_List__c>>();
    //    Map<Id,Map<Id,Target_List__c>> targetListsMapByCampaignIdMapByAccountId = new Map<Id,Map<Id,Target_List__c>>();
    //    Map<Id,List<Campaign>> accountWithCampaign = new Map<Id,List<Campaign>>();

    //    for(Target_List__c eachTarget : targetList) {
    //        if(eachTarget.CIS_ID_Prospect_Name__c != null) {
    //            if(!accountTargetListMap.containsKey(eachTarget.CIS_ID_Prospect_Name__c)){
    //                accountTargetListMap.put(eachTarget.CIS_ID_Prospect_Name__c, new List<Target_List__c>());    
    //            }
    //            accountTargetListMap.get(eachTarget.CIS_ID_Prospect_Name__c).add(eachTarget);
    //            if(!targetListsMapByCampaignIdMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c)){
    //                targetListsMapByCampaignIdMapByAccountId.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<Id,Target_List__c>());
    //                accountWithCampaign.put(eachTarget.CIS_ID_Prospect_Name__c,new List<Campaign>());
    //            }
    //            targetListsMapByCampaignIdMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).put(eachTarget.Lead_Campaign__c, eachTarget);
    //            accountWithCampaign.get(eachTarget.CIS_ID_Prospect_Name__c).add(eachTarget.Lead_Campaign__r);
    //        }
    //    }

    //    Map<Id,Opportunity_Lead__c> possibleOppLeadMap = new Map<Id,Opportunity_Lead__c>();
    //    List<Opportunity_Lead__c> possibleOppLeadList = new List<Opportunity_Lead__c>();
    //    Map<Id,Call_Report_Lead__c> possibleCallReportLeadMap = new Map<Id,Call_Report_Lead__c>();
    //    List<Call_Report_Lead__c> possibleCallReportLeadList = new List<Call_Report_Lead__c>();

    //    possibleOppLeadList = [SELECT Id, Opportunity__c, Target_List__c, Opportunity_Lead_Status__c FROM Opportunity_Lead__c WHERE Target_List__c IN :targetList AND Opportunity__r.IsNewCredit__c = 1];
    //    for(Opportunity_Lead__c eachPossibleOppLead : possibleOppLeadList){
    //        possibleOppLeadMap.put(eachPossibleOppLead.Target_List__c, eachPossibleOppLead);
    //    }
    //    possibleCallReportLeadList = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Target_List__c IN :targetList];
    //    for(Call_Report_Lead__c eachPossibleCallReportLead : possibleCallReportLeadList){
    //        possibleCallReportLeadMap.put(eachPossibleCallReportLead.Target_List__c, eachPossibleCallReportLead);
    //    }

    //    Map<Id,Opportunity> possibleOppMap = new Map<Id,Opportunity>();
    //    Map<Id,Call_Report__c> possibleCallReportMap = new Map<Id,Call_Report__c>();
    //    Map<Id,Call_Report__c> possibleCallPlanMap = new Map<Id,Call_Report__c>();

    //    List<Call_Report_Lead__c> newCallReportLeadList = new List<Call_Report_Lead__c>();
    //    List<Call_Report_Lead__c> updateCallReportLeadList = new List<Call_Report_Lead__c>();
    //    List<Opportunity_Lead__c> newOppLeadList = new List<Opportunity_Lead__c>();
    //    List<Opportunity_Lead__c> updateOppLeadList = new List<Opportunity_Lead__c>();
    //    Map<Id, Target_List__c> updateTargetList = new Map<Id, Target_List__c>();

    //    Map<Id,Account> accountMap = new Map<Id,Account>([
    //        SELECT Id, RecordType.DeveloperName, CIS__c,
    //            (SELECT Id, Type, Submit_Issue__c, AccountId, StageName, CreatedDate FROM Opportunities WHERE IsNewCredit__c = 1 ORDER BY CreatedDate DESC),
    //            (SELECT Id, Offer_Interest__c, Status__c, RecordTypeId, RecordType.DeveloperName, Offer_Credit_Product__c, 
    //                Collect_Documents__c, Negotiation__c, Servicing__c, Customer_Insight__c, Gift__c, DPD__c, Non_Credit__c, 
    //                No_Change__c, Pain__c, Primary_Call_Plan_Call_Report__c, CreatedDate,
    //                Plan_Date__c, CIS_ID__c FROM Call_Reports__r ORDER BY CreatedDate DESC) 
    //        FROM Account 
    //        WHERE Id IN:targetListsMapByCampaignIdMapByAccountId.keySet()]);

    //    for(Account eachAccount : accountMap.values()) {
    //        possibleOppMap.clear();
    //        possibleCallPlanMap.clear();
    //        possibleCallReportMap.clear();
    //        if(accountWithCampaign.get(eachAccount.Id) != null && accountWithCampaign.get(eachAccount.Id).size() > 0){
    //            for(Campaign eachCampaign : accountWithCampaign.get(eachAccount.Id)){
    //                if(eachCampaign.Effective_Date__c != null && eachCampaign.EndDate != null){
    //                    if(eachAccount.Opportunities != null && eachAccount.Opportunities.size() > 0){
    //                        for(Opportunity eachOpportunity : eachAccount.Opportunities){
    //                            Date oppCreatedDate = Date.newinstance(eachOpportunity.CreatedDate.year(), eachOpportunity.CreatedDate.month(), eachOpportunity.CreatedDate.day());
    //                            if(oppCreatedDate >= eachCampaign.Effective_Date__c && oppCreatedDate <= eachCampaign.EndDate){
    //                                possibleOppMap.put(eachOpportunity.Id, eachOpportunity);
    //                            }
    //                        }
    //                    }
    //                    if(eachAccount.Call_Reports__r != null && eachAccount.Call_Reports__r.size() > 0){
    //                        for(Call_Report__c eachCallPlanCallReport : eachAccount.Call_Reports__r){
    //                            Date callCreatedDate = Date.newinstance(eachCallPlanCallReport.CreatedDate.year(), eachCallPlanCallReport.CreatedDate.month(), eachCallPlanCallReport.CreatedDate.day());
    //                            if(callCreatedDate >= eachCampaign.Effective_Date__c && callCreatedDate <= eachCampaign.EndDate){
    //                                if(isCallPlan(eachCallPlanCallReport.RecordTypeId)){
    //                                    possibleCallPlanMap.put(eachCallPlanCallReport.Id, eachCallPlanCallReport);
    //                                }
    //                                if(isCallReport(eachCallPlanCallReport.RecordTypeId)){
    //                                    possibleCallReportMap.put(eachCallPlanCallReport.Id, eachCallPlanCallReport);
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }

    //        for(Target_List__c eachTgl : accountTargetListMap.get(eachAccount.Id)){
    //            SObject resultLeadPriority = checkPossibleLeadPriority(eachTgl,possibleOppMap,possibleCallPlanMap,possibleCallReportMap);

    //            if(resultLeadPriority != null){
    //                String newStatus;
    //                if(resultLeadPriority.getsObjectType() == Opportunity_Lead__c.getsObjectType()){
    //                    newStatus = String.valueOf(resultLeadPriority.get('Opportunity_Lead_Status__c'));
    //                    if(possibleOppLeadMap.containsKey(Id.valueOf(String.valueOf(resultLeadPriority.get('Target_List__c'))))){
    //                        resultLeadPriority.put('Id', possibleOppLeadMap.get(Id.valueOf(String.valueOf(resultLeadPriority.get('Target_List__c')))).Id);
    //                        updateOppLeadList.add((Opportunity_Lead__c)resultLeadPriority);
    //                        oppLeadAssoList.add(Id.valueOf(String.valueOf(resultLeadPriority.get('Opportunity__c'))));
    //                    }else{                 
    //                        Opportunity_Lead__c oppLead = (Opportunity_Lead__c)resultLeadPriority;
    //                        newOppLeadList.add(oppLead);
    //                        oppLeadAssoList.add(Id.valueOf(String.valueOf(resultLeadPriority.get('Opportunity__c'))));
    //                    }
    //                }else{
    //                    newStatus = String.valueOf(resultLeadPriority.get('Call_Report_Lead_Status__c'));

    //                    if(possibleCallReportLeadMap.containsKey(Id.valueOf(String.valueOf(resultLeadPriority.get('Target_List__c'))))){
    //                        resultLeadPriority.put('Id', possibleCallReportLeadMap.get(Id.valueOf(String.valueOf(resultLeadPriority.get('Target_List__c')))).Id);
    //                        updateCallReportLeadList.add((Call_Report_Lead__c)resultLeadPriority);
    //                        callReportLeadAssoList.add(Id.valueOf(String.valueOf(resultLeadPriority.get('Call_Plan_Call_Report__c'))));
    //                    }else{
    //                        newCallReportLeadList.add((Call_Report_Lead__c)resultLeadPriority);
    //                        callReportLeadAssoList.add(Id.valueOf(String.valueOf(resultLeadPriority.get('Call_Plan_Call_Report__c'))));
    //                    }
    //                }
    //                if(newStatus != eachTgl.Status__c || newStatus != eachTgl.Lead_Campaign__r.Status){
    //                    eachTgl.Status__c = newStatus;
    //                    eachTgl.IsSyncToCDB__c = false;
    //                    updateTargetList.put(eachTgl.Id, eachTgl);
    //                }
    //            }
    //        }
    //    }



    //    List<Opportunity_Lead__c> upsertOppLeadList = new List<Opportunity_Lead__c>();
    //    upsertOppLeadList.addAll((List<Opportunity_Lead__c>) newOppLeadList);
    //    upsertOppLeadList.addAll((List<Opportunity_Lead__c>) updateOppLeadList);

    //    List<Call_Report_Lead__c> upsertCallReportLeadList = new List<Call_Report_Lead__c>();
    //    upsertCallReportLeadList.addAll((List<Call_Report_Lead__c>) newCallReportLeadList);
    //    upsertCallReportLeadList.addAll((List<Call_Report_Lead__c>) updateCallReportLeadList);

        

    //    if(!upsertOppLeadList.isEmpty()){
    //        upsert upsertOppLeadList;
    //    }

    //    if(!upsertCallReportLeadList.isEmpty()){
    //        upsert upsertCallReportLeadList;
    //    }

    //    if(!updateTargetList.isEmpty()){
    //        update updateTargetList.values();
    //    }

    //    if(!updateOpportunityStatus.isEmpty()){
    //        update updateOpportunityStatus;
    //    }
    //}

    //public static void createOpportunityUpdateLeadStatus(Map<Id, Opportunity> opportunityMap) {
    //    CampaignLead_Service.createOpportunityUpdateLeadStatus(opportunityMap, null);
    //}

    //public static void createOpportunityUpdateLeadStatus(Map<Id, Opportunity> opportunityMap, Map<Id, List<Call_Report_Lead__c>> callRepLeadsMapByOppId) {
    //    List<Opportunity_Lead__c> newLeadList = new List<Opportunity_Lead__c>();
    //    Map<Id, Opportunity> updateOpportunityMap = new Map<Id, Opportunity>();
    //    Map<Id, Target_List__c> updateTargetListMap = new Map<Id, Target_List__c>();
    //    Map<Id, Map<Id, Target_List__c>> targetListsMapByCampaignIdMapByAccountId = new Map<Id, Map<Id, Target_List__c>>();
    //    Map<String, Opportunity_Lead__c> mapFocusedOppLeadByTgl = new Map<String, Opportunity_Lead__c>();
    //    Map<String, Set<String>> mapSetOppRelatedTgl = new Map<String, Set<String>>();
    //    Set<Id> accountSet = Opportunity_Service.getAccountIdsFromOpportunity(opportunityMap.values());

    //    List<Target_List__c> targetLists = new List<Target_List__c>();
    //    targetLists = 
    //    [SELECT Id, CIS_ID_Prospect_Name__c, Active_Target_List__c, Lead_Type__c, Status__c, Approved_Amount__c, Setup_Amount__c, Lead_Campaign__c, Lead_Campaign__r.Product_List_CBS__c, Lead_Campaign__r.RecordType.DeveloperName, Lead_Campaign__r.Status,
    //    (SELECT Id, Opportunity__c, Opportunity__r.StageName, Opportunity__r.Approved_Amount__c, Opportunity__r.Setup_Amount__c,Is_Focusing__c FROM Opportunities_Leads__r ORDER BY CreatedDate DESC) 
    //    FROM Target_List__c 
    //    WHERE CIS_ID_Prospect_Name__c IN :accountSet AND Status__c != :GlobalConstants.LEAD_EXPIRED AND Status__c != :GlobalConstants.TG_EXPIRED
    //    AND (Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME OR Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.CBS_LEAD_DEVNAME)
    //    AND Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES];

    //    for(Target_List__c eachTarget : targetLists) {
    //        if(!targetListsMapByCampaignIdMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c)){
    //            targetListsMapByCampaignIdMapByAccountId.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<Id, Target_List__c>());
    //        }
    //        targetListsMapByCampaignIdMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).put(eachTarget.Lead_Campaign__c, eachTarget);       

    //        if(eachTarget.Opportunities_Leads__r != null && eachTarget.Opportunities_Leads__r.size() > 0){
    //            for(Opportunity_Lead__c eachExistOpportunityLead : eachTarget.Opportunities_Leads__r){
    //                if(eachExistOpportunityLead.Is_Focusing__c){
    //                    mapFocusedOppLeadByTgl.put(eachTarget.Id,eachTarget.Opportunities_Leads__r.get(0));
    //                }
                    
    //                if(!mapSetOppRelatedTgl.containsKey(eachTarget.Id)){
    //                    mapSetOppRelatedTgl.put(eachTarget.Id,new Set<String>());
    //                }
    //                mapSetOppRelatedTgl.get(eachTarget.Id).add(eachExistOpportunityLead.Opportunity__c);
    //            }
    //        }
    //    }

    //    for(Opportunity eachNewOpportunity : opportunityMap.values()) {
    //        // Is Converted Opp
    //        if(targetListsMapByCampaignIdMapByAccountId.containsKey(eachNewOpportunity.AccountId)) { // If have existing Lead
    //            targetLists = null;
    //            Boolean isCreateLead        = false;
    //            Boolean isUpdateTargetList  = false;
    //            Boolean isChangeFocus       = false;
    //            //Boolean isFocusing       = false;
    //            Target_List__c tempTargetList  = null;
    //            Map<String, Boolean> mapOppConditionByKey = new Map<String, Boolean>();
    //            if(eachNewOpportunity.IsConvertFromCallReport__c == true) {
    //                if(callRepLeadsMapByOppId != null && callRepLeadsMapByOppId.containsKey(eachNewOpportunity.Id)) {
    //                    for(Call_Report_Lead__c eachExistCallRepLead : callRepLeadsMapByOppId.get(eachNewOpportunity.Id)) {
    //                        if(targetListsMapByCampaignIdMapByAccountId.get(eachNewOpportunity.AccountId).containsKey(eachExistCallRepLead.Target_List__r.Lead_Campaign__c)) {
    //                            tempTargetList = targetListsMapByCampaignIdMapByAccountId.get(eachNewOpportunity.AccountId).get(eachExistCallRepLead.Target_List__r.Lead_Campaign__c);
    //                            mapOppConditionByKey = CampaignLead_Service.checkCreateOppCondition(tempTargetList, mapFocusedOppLeadByTgl, eachNewOpportunity.Id);
    //                            isCreateLead = mapOppConditionByKey.get('isCreateLead');
    //                            isUpdateTargetList = mapOppConditionByKey.get('isUpdateTargetList');
    //                            isChangeFocus = mapOppConditionByKey.get('isChangeFocus');
    //                            String newStatus = CampaignLead_Service.getNewLeadStatus(tempTargetList.Lead_Type__c, null, eachNewOpportunity.StageName);

    //                            if(isCreateLead) {
    //                                newLeadList.add(new Opportunity_Lead__c(
    //                                    Opportunity__c = eachNewOpportunity.Id,
    //                                    Target_List__c = tempTargetList.Id,
    //                                    Opportunity_Lead_Status__c = newStatus,
    //                                    Is_Focusing__c  = isChangeFocus
    //                                ));
    //                            }
    //                            if (newStatus != null && newStatus != tempTargetList.Status__c && isUpdateTargetList) {
    //                                tempTargetList.Status__c = newStatus;
    //                            }
    //                            if (tempTargetList.Approved_Amount__c != eachNewOpportunity.Approved_Amount__c) {
    //                                tempTargetList.Approved_Amount__c = eachNewOpportunity.Approved_Amount__c;
    //                                isUpdateTargetList = true;
    //                            }
    //                            if (tempTargetList.Setup_Amount__c != eachNewOpportunity.Setup_Amount__c) {
    //                                tempTargetList.Setup_Amount__c = eachNewOpportunity.Setup_Amount__c;
    //                                isUpdateTargetList = true;
    //                            }
    //                            if(isUpdateTargetList) {
    //                                updateTargetListMap.put(tempTargetList.Id, tempTargetList);
    //                            }
    //                        }
    //                    }
    //                    continue;
    //                }
    //            }
                
    //            targetLists = targetListsMapByCampaignIdMapByAccountId.get(eachNewOpportunity.AccountId).values();
    //            for(Target_List__c eachTarget : targetLists) {
    //                if(eachTarget.Lead_Campaign__r.Status == GlobalConstants.ACTIVE) {
    //                    isUpdateTargetList = false;
    //                    isCreateLead = false;

    //                    String newStatus = CampaignLead_Service.getNewLeadStatus(eachTarget.Lead_Type__c, null, eachNewOpportunity.StageName);
    //                    // Add CBS Condition 18/10/2559
    //                    if(eachTarget.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME){
    //                        if(eachTarget.Active_Target_List__c == null) continue;
    //                        if(eachNewOpportunity.StageName == GlobalConstants.STATUS_NEW) {
    //                            newStatus = GlobalConstants.NEW_OPPORTUNITY;
    //                        } else {
    //                            newStatus = eachNewOpportunity.StageName;
    //                        }
    //                        if(eachTarget.Lead_Campaign__r.Product_List_CBS__c != null && eachNewOpportunity.Product_List_CBS__c != null) {
    //                            Set<String> campaingProductSet = new Set<String>(eachTarget.Lead_Campaign__r.Product_List_CBS__c.split(';'));
    //                            Set<String> oppProductSet = new Set<String>(eachNewOpportunity.Product_List_CBS__c.split(','));

    //                            if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppProductSet)){ 
    //                                if(TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY,newStatus,eachTarget.Status__c)) {
    //                                    eachTarget.Status__c = newStatus;
    //                                    isUpdateTargetList = true;
    //                                }
    //                                isCreateLead = true;
    //                            }
    //                        }
    //                    } else {
    //                        mapOppConditionByKey = CampaignLead_Service.checkCreateOppCondition(eachTarget, mapFocusedOppLeadByTgl, eachNewOpportunity.Id);
    //                        isCreateLead = mapOppConditionByKey.get('isCreateLead');
    //                        isUpdateTargetList = mapOppConditionByKey.get('isUpdateTargetList');
    //                        isChangeFocus = mapOppConditionByKey.get('isChangeFocus');
    //                        if (newStatus != null && newStatus != eachTarget.Status__c && isUpdateTargetList) {
    //                            eachTarget.Status__c = newStatus;
    //                        }
    //                    }   
    //                    if(isCreateLead && (!mapSetOppRelatedTgl.containsKey(eachTarget.Id) || !mapSetOppRelatedTgl.get(eachTarget.Id).contains(eachNewOpportunity.Id))) {
    //                        newLeadList.add(new Opportunity_Lead__c(
    //                            Opportunity__c = eachNewOpportunity.Id,
    //                            Target_List__c = eachTarget.Id,
    //                            Opportunity_Lead_Status__c = newStatus,
    //                            Is_Focusing__c  = isChangeFocus
    //                        ));
    //                    }
    //                    if (eachTarget.Approved_Amount__c != eachNewOpportunity.Approved_Amount__c) {
    //                        eachTarget.Approved_Amount__c = eachNewOpportunity.Approved_Amount__c;
    //                        isUpdateTargetList = true;
    //                    }
    //                    if (eachTarget.Setup_Amount__c != eachNewOpportunity.Setup_Amount__c) {
    //                        eachTarget.Setup_Amount__c = eachNewOpportunity.Setup_Amount__c;
    //                        isUpdateTargetList = true;
    //                    }
    //                    if(isUpdateTargetList) {
    //                        updateTargetListMap.put(eachTarget.Id, eachTarget);
    //                    }
    //                }
    //            }
    //        }
    //    }

    //    if(!newLeadList.isEmpty()) upsert newLeadList;
    //    if(!updateTargetListMap.isEmpty()) update updateTargetListMap.values();

    //    TriggerHandler.bypass('OpportunityTriggerHandler');
    //    if(!updateOpportunityMap.isEmpty()) update updateOpportunityMap.values();
    //    TriggerHandler.clearBypass('OpportunityTriggerHandler');
    //}

    //public static void updateOpportunityProductList(Map<Id, Opportunity> opportunityMap) {
    //    Set<Id> accountSet = new Set<Id>();
    //    Map<Id, List<Opportunity>> oppMapByAccount = new Map<Id, List<Opportunity>>();
    //    for(Opportunity eachOpp : opportunityMap.values()) {
    //        if(eachOpp.AccountId != null && eachOpp.Product_List_CBS__c != null) {
    //            accountSet.add(eachOpp.AccountId);
    //            if(!oppMapByAccount.containsKey(eachOpp.AccountId))
    //                oppMapByAccount.put(eachOpp.AccountId, new List<Opportunity>());
    //            oppMapByAccount.get(eachOpp.AccountId).add(eachOpp);
    //        }
    //    }
    //    Map<Id, List<Target_List__c>> targetListMapByAccount = new Map<Id, List<Target_List__c>>();
    //    Set<String> existingOppLeadFromKeyOppAndTargetList = new Set<String>();
    //    List<Opportunity_Lead__c> newLeadList = new List<Opportunity_Lead__c>();

    //    List<Target_List__c> targetLists = new List<Target_List__c>();
    //    targetLists = 
    //    [SELECT Id, Lead_Campaign__r.Product_List_CBS__c, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.OwnerId, Lead_Type__c, Status__c, Lead_Campaign__c,Lead_Campaign__r.Name,Lead_Campaign__r.Add_Associated_Lead__c,Lead_Campaign__r.Sub_Type__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Lead_Campaign__r.Priority__c,Lead_Campaign__r.Priority_Group__c,Lead_Campaign__r.EndDate,Lead_Campaign__r.StartDate,Lead_Campaign__r.RecordType.DeveloperName,Approved_Amount__c, Setup_Amount__c,IsRespLeadToDo__c,
    //    (SELECT Id, Opportunity__c, Target_List__c,Is_Focusing__c FROM Opportunities_Leads__r)
    //    FROM Target_List__c 
    //    WHERE CIS_ID_Prospect_Name__c IN :accountSet 
    //        AND Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.CBS_LEAD_DEVNAME
    //        AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES];
    //    for(Target_List__c eachTarget : targetLists) {
    //        if(!targetListMapByAccount.containsKey(eachTarget.CIS_ID_Prospect_Name__c))
    //            targetListMapByAccount.put(eachTarget.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
    //        targetListMapByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).add(eachTarget);
    //        for(Opportunity_Lead__c eachOppLead: eachTarget.Opportunities_Leads__r){
    //            existingOppLeadFromKeyOppAndTargetList.add(eachOppLead.Opportunity__c + '-' + eachOppLead.Target_List__c);
    //        }
    //    }

    //    Map<Id, Target_List__c> updateTargetLists = new Map<Id, Target_List__c>();
    //    for(Id eachAccountId : accountSet) {
    //        if(targetListMapByAccount.containsKey(eachAccountId) && oppMapByAccount.containsKey(eachAccountId)) {
    //            for(Opportunity eachOpp : oppMapByAccount.get(eachAccountId)) {
    //                if(eachOpp.StageName != null && eachOpp.Product_List_CBS__c != null) {
    //                    Set<String> oppProductSet = new Set<String>(eachOpp.Product_List_CBS__c.split(','));
    //                    for(Target_List__c eachTarget : targetListMapByAccount.get(eachAccountId)) {
    //                        String newStatus = eachTarget.Status__c;
    //                        Boolean isCreateLead        = false;
    //                        Boolean isUpdateTargetList  = false;

    //                        if(eachTarget.Lead_Campaign__r.Product_List_CBS__c != null) {
    //                            Set<String> campaingProductSet = new Set<String>(eachTarget.Lead_Campaign__r.Product_List_CBS__c.split(';'));
    //                            if(updateTargetLists.containsKey(eachTarget.Id)) {
    //                                eachTarget.Status__c = updateTargetLists.get(eachTarget.Id).Status__c;
    //                            }
    //                            if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppProductSet) && TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY, eachOpp.StageName, eachTarget.Status__c)){
    //                                isUpdateTargetList = true;
    //                                newStatus = eachOpp.StageName;
    //                                if(!existingOppLeadFromKeyOppAndTargetList.contains(eachOpp.Id + '-' + eachTarget.Id)) {
    //                                    isCreateLead = true;
    //                                }
    //                            }
    //                        }
    //                        if(isCreateLead) {
    //                            newLeadList.add(new Opportunity_Lead__c(
    //                                Opportunity__c = eachOpp.Id,
    //                                Target_List__c = eachTarget.Id,
    //                                Opportunity_Lead_Status__c = newStatus
    //                            ));
    //                        }

    //                        if(isUpdateTargetList) {
    //                            eachTarget.Status__c = newStatus;
    //                            updateTargetLists.put(eachTarget.Id, eachTarget);
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    //    if(!updateTargetLists.isEmpty())
    //        update updateTargetLists.values();

    //    if(!newLeadList.isEmpty()) insert newLeadList;
    //}

    //public static Map<String, Boolean> checkCreateOppCondition(Target_List__c eachTarget, Map<String, Opportunity_Lead__c> mapFocusedOppLeadByTgl, Id eachOpportunityId) {
    //    Map<String, Boolean> mapOppConditionByKey = new Map<String, Boolean>();
    //    Boolean isCreateLead = false;
    //    Boolean isUpdateTargetList = false;
    //    Boolean isChangeFocus = false;
    //    Boolean isExistingFocusOpp = false;
    //    Opportunity_Lead__c focusedOpportunity = mapFocusedOppLeadByTgl.get(eachTarget.Id);

    //    if(eachTarget.Opportunities_Leads__r != null && eachTarget.Opportunities_Leads__r.size() > 0) { // Have Existing Opportunity Lead
    //        if(focusedOpportunity == null) {
    //            isCreateLead = true;
    //            isUpdateTargetList = true;
    //        } else {
    //            if(!GlobalConstants.OPP_STAGE_COMPLETE_WIN.contains(focusedOpportunity.Opportunity__r.StageName)){
    //                if(GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(focusedOpportunity.Opportunity__r.StageName)){
    //                    // Create Lead + Update Status
    //                    isUpdateTargetList = true;
    //                }
    //                isCreateLead = true;
    //            }
    //        }
    //    }else{ // No existing Call Plan / Call Report / Opportunity
    //        // Create Lead + Update Status
    //        isCreateLead = true;
    //        if(focusedOpportunity == null) {
    //            isUpdateTargetList = true;
    //            isChangeFocus = true; 
    //        }
    //    }
    //    mapOppConditionByKey.put('isCreateLead', isCreateLead);
    //    mapOppConditionByKey.put('isUpdateTargetList', isUpdateTargetList);
    //    mapOppConditionByKey.put('isChangeFocus', isChangeFocus);

    //    return mapOppConditionByKey;
    //}

    //public static void updateOpportunityUpdateLeadStatus(Map<Id, Opportunity> opportunityMap) {
    //    Set<Id> accountSet = Opportunity_Service.getAccountIdsFromOpportunity(opportunityMap.values());
    //    Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id, IsFocusingLead__c, StageName, Product_List_CBS__c FROM Opportunities WHERE StageName NOT IN :getClosedOppStageSet()), (SELECT Id, Product_List_CBS__c, Status__c FROM Opportunities_Planning__r WHERE Status__c NOT IN :getClosedOppStageSet()) FROM Account WHERE Id IN :accountSet]); // Add CBS Opp Planning
    //    Map<Id, Opportunity_Lead__c> updateOppLeadMap = new Map<Id, Opportunity_Lead__c>();
    //    Map<Id, Target_List__c> updateTargetListMap = new Map<Id, Target_List__c>();
    //    Map<Id, Opportunity> updateOpportunityMap = new Map<Id, Opportunity>();
    //    Map<Id, Boolean> isFocusOppMapByTargetList = new Map<Id, Boolean>();
    //    Map<Id, Opportunity> allOpportunityMap = new Map<Id, Opportunity>();
    //    Map<Id, Opportunity_Lead__c> mapOppLeadFocusByTgl = new Map<Id, Opportunity_Lead__c>();
    //    Set<Id> isFocusOppInAccount = new Set<Id>();
    //    Set<Id> oppIdsInOppLead = new Set<Id>();

    //    for(Account eachAccount : accountMap.values()) {
    //        if(eachAccount.Opportunities != null && eachAccount.Opportunities.size() > 0) {
    //            for(Opportunity eachOpp : eachAccount.Opportunities) {
    //                allOpportunityMap.put(eachOpp.Id, eachOpp);
    //            }
    //        }
    //    }

    //    List<Opportunity_Lead__c> existOppLeadList = new List<Opportunity_Lead__c>();
    //    existOppLeadList = [SELECT Id, Opportunity__c,Opportunity__r.IsNewCredit__c,Opportunity__r.Submit_Issue__c,Opportunity__r.SP_Submit_Issue__c, Opportunity__r.Product_List_CBS__c, Opportunity__r.AccountId, Opportunity__r.StageName, Opportunity__r.IsFocusingLead__c, Is_Focusing__c, Opportunity_Lead_Status__c, Status__c, Target_List__c, Target_List__r.Lead_Type__c, Target_List__r.Status__c, Target_List__r.Lead_Campaign__r.RecordType.DeveloperName, Target_List__r.Lead_Campaign__r.Product_List_CBS__c FROM Opportunity_Lead__c WHERE (Opportunity__c IN :opportunityMap.keySet() OR Opportunity__c IN :allOpportunityMap.keySet()) ORDER BY CreatedDate ]; // Add CBS Opp Product List, Record Type
        
    //    for(Opportunity_Lead__c eachOppLead : existOppLeadList) {
    //        oppIdsInOppLead.add(eachOppLead.Opportunity__c);

    //        if(eachOppLead.Is_Focusing__c){
    //            mapOppLeadFocusByTgl.put(eachOppLead.Target_List__c,eachOppLead);
    //        }
    //    }

    //    for(Opportunity_Lead__c eachOppLead : existOppLeadList) {
    //        Boolean isUpdateTargetList = false;            
    //        //start INC000000593982_INC000000601674
    //        if(eachOppLead.Opportunity__c != null && eachOppLead.Target_List__c != null) {
    //        //end INC000000593982_INC000000601674
    //            String newStatus = CampaignLead_Service.getNewLeadStatus(eachOppLead.Target_List__r.Lead_Type__c, null, eachOppLead.Opportunity__r.StageName);
    //            eachOppLead.Opportunity_Lead_Status__c = newStatus;
    //            Target_List__c eachTarget = new Target_List__c(Id = eachOppLead.Target_List__c);

    //            // *** Check CBS Lead Record Type ***
    //            if(eachOppLead.Target_List__r.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME) {
    //                // Add CBS Condition 18/10/2559
    //                Set<String> campaingProductSet = new Set<String>();
    //                if(eachOppLead.Target_List__r.Lead_Campaign__r.Product_List_CBS__c != null) {
    //                    campaingProductSet.addAll(eachOppLead.Target_List__r.Lead_Campaign__r.Product_List_CBS__c.split(';'));
    //                    Set<String> oppProductSet = new Set<String>();
    //                    if(eachOppLead.Opportunity__r.Product_List_CBS__c != null) {
    //                        oppProductSet.addAll(eachOppLead.Opportunity__r.Product_List_CBS__c.split(','));
    //                    }
    //                    String currentTargetListStatus = eachOppLead.Target_List__r.Status__c;
    //                    if(updateTargetListMap.containsKey(eachTarget.Id)) {
    //                        currentTargetListStatus = updateTargetListMap.get(eachTarget.Id).Status__c;
    //                    }
                        
    //                    newStatus = eachOppLead.Opportunity__r.StageName;
    //                    if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppProductSet) && TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY,newStatus,currentTargetListStatus)){
    //                        isUpdateTargetList = true;
    //                        if(GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(newStatus)){
    //                            if(accountMap.containsKey(eachOppLead.Opportunity__r.AccountId)) {
    //                                Account eachAccount = accountMap.get(eachOppLead.Opportunity__r.AccountId);
    //                                newStatus = getNewStatusForClosedOpportunityCBS(eachOppLead.Opportunity__c, newStatus, campaingProductSet, eachAccount, oppIdsInOppLead);
    //                            }
    //                            eachTarget.Status__c = newStatus;
    //                        } else {
    //                            if(newStatus == GlobalConstants.STATUS_NEW) {
    //                                newStatus = GlobalConstants.NEW_OPPORTUNITY;
    //                            }
    //                            eachTarget.Status__c = newStatus;
    //                        }
    //                    }
    //                } 
    //            } else { // SME Update Lead Condition
    //                if(eachOppLead.Opportunity__r.IsNewCredit__c == 1){
    //                    if(!mapOppLeadFocusByTgl.containsKey(eachOppLead.Target_List__c) && !GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(eachOppLead.Opportunity__r.StageName)) {
    //                        isUpdateTargetList = true;
    //                        mapOppLeadFocusByTgl.put(eachOppLead.Target_List__c,eachOppLead);
    //                        eachTarget.Status__c = newStatus;
    //                        eachOppLead.Is_Focusing__c = true;  
    //                    }else{
    //                        if(eachOppLead.Is_Focusing__c && eachOppLead.Target_List__r.Status__c != GlobalConstants.STATUS_CHANGED_OWNER){
    //                            isUpdateTargetList = true;
    //                            eachTarget.Status__c = newStatus;
    //                            if(GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(eachOppLead.Opportunity__r.StageName)){
    //                                mapOppLeadFocusByTgl.remove(eachOppLead.Target_List__c);
    //                                eachOppLead.Is_Focusing__c = false;
    //                            }
    //                        }
    //                    }
    //                    updateOppLeadMap.put(eachOppLead.Id, eachOppLead);
    //                }
    //            }

    //            if(isUpdateTargetList) {
    //                updateTargetListMap.put(eachTarget.Id, eachTarget);    
    //            }
    //        }
    //    }

    //    if(!updateOppLeadMap.isEmpty()) update updateOppLeadMap.values();
    //    if(!updateTargetListMap.isEmpty()) update updateTargetListMap.values();

    //    TriggerHandler.bypass('OpportunityTriggerHandler');
    //    if(!updateOpportunityMap.isEmpty()) update updateOpportunityMap.values();
    //    TriggerHandler.clearBypass('OpportunityTriggerHandler');
    //}

    //public static void createORconvertCallReportUpdateAndCreateLeadStatus(Map<Id, Call_Report__c> callReportMap){
    //    // Prepare Account Id Set and Primary Call Report Id Set
    //    Set<Id> accountSet = new Set<Id>();
    //    Set<Id> callReportMainIds = new Set<Id>();
    //    List<Target_List__c> targetLists = new List<Target_List__c>();
    //    Map<Id, Call_Report__c> mainCallReportMap = new Map<Id, Call_Report__c>();
    //    Map<Id, Call_Report_Lead__c> callReportLeadMapByCallReportId = new Map<Id, Call_Report_Lead__c>();
    //    Map<String, Opportunity_Lead__c> mapFocusedOppLeadByTgl = new Map<String, Opportunity_Lead__c>();
    //    Map<Id,Call_Report_Lead__c> callReportLeadMapByTGLId = new Map<Id, Call_Report_Lead__c>();

    //    // edit For Lead DPD
    //    Map<Id, Map<Id, List<Target_List__c>>> targetListsMapByCampaignIdMapByAccountId = new Map<Id, Map<Id, List<Target_List__c>>>();

    //    Map<Id, Target_List__c> updateTargetListMap = new Map<Id, Target_List__c>();
    //    Map<Id, Call_Report_Lead__c> updateCallReportLeadMap = new Map<Id, Call_Report_Lead__c>();

    //    for(Call_Report__c eachCallReport : callReportMap.values()){
    //        accountSet.add(eachCallReport.CIS_ID__c);
    //        if(eachCallReport.Primary_Call_Plan_Call_Report__c != null && isSecondaryCallReport(eachCallReport.RecordTypeId)) {
    //            callReportMainIds.add(eachCallReport.Primary_Call_Plan_Call_Report__c);
    //        }
    //    }

    //    // Map Call Report In Primary Call Report Id Set
    //    if(callReportMainIds.size() > 0) {
    //        mainCallReportMap = new Map<Id, Call_Report__c>([SELECT Id, CIS_ID__c, RecordTypeId FROM Call_Report__c WHERE Id IN:callReportMainIds]);
    //    }
    //    for(Call_Report__c eachMainCallReport : mainCallReportMap.values()){
    //        accountSet.add(eachMainCallReport.CIS_ID__c);
    //    }

    //    // Map Account In Call Report and Primary Call Report
    //    Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id, IsFocusingLead__c, StageName FROM Opportunities) FROM Account WHERE Id IN :accountSet]);
    //    // Existing Call Report/Opportunity
    //    List<Call_Report_Opportunity__c> callReportOppList = new List<Call_Report_Opportunity__c>();
    //    callReportOppList = [SELECT Id, Call_Plan_Call_Report__c, Opportunity_Name__c, Opportunity_Name__r.AccountId FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c IN :callReportMap.keySet() AND Opportunity_Name__r.IsNewCredit__c = 1];

    //    Map<Id, Id> oppIdMapByCallReportId = new Map<Id, Id>();
    //    for(Call_Report_Opportunity__c eachCallOpp : callReportOppList) {
    //        oppIdMapByCallReportId.put(eachCallOpp.Call_Plan_Call_Report__c, eachCallOpp.Opportunity_Name__c);
    //    }
    //    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, StageName, Approved_Amount__c, Setup_Amount__c, AccountId FROM Opportunity WHERE Id IN:oppIdMapByCallReportId.values()]);

    //    // Query Target List and Existing Call/Lead and/or Opp/Lead
    //    targetLists = 
    //    [SELECT Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.OwnerId, Lead_Type__c, Status__c, Lead_Campaign__c,Lead_Campaign__r.Name,Lead_Campaign__r.Add_Associated_Lead__c,Lead_Campaign__r.Sub_Type__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Lead_Campaign__r.Priority__c,Lead_Campaign__r.Priority_Group__c,Lead_Campaign__r.EndDate,Lead_Campaign__r.StartDate,Lead_Campaign__r.RecordType.DeveloperName,Approved_Amount__c, Setup_Amount__c,IsRespLeadToDo__c,Active_Target_List__c,Lead_Subtype__c,Lead_Campaign__r.Status,
    //    (SELECT Id, Opportunity__r.StageName,Is_Focusing__c FROM Opportunities_Leads__r WHERE Is_Focusing__c = true ORDER BY CreatedDate DESC LIMIT 1), 
    //    (SELECT Id, Call_Plan_Call_Report__c, Call_Plan_Call_Report__r.RecordTypeId, Call_Plan_Call_Report__r.Status__c, Call_Plan_Call_Report__r.Offer_Interest__c, Call_Plan_Call_Report__r.Offer_Credit_Product__c, Call_Plan_Call_Report__r.Negotiation__c, Call_Plan_Call_Report__r.Collect_Documents__c, Call_Plan_Call_Report__r.Servicing__c, Call_Plan_Call_Report__r.Customer_Insight__c, Call_Plan_Call_Report__r.Gift__c, Call_Plan_Call_Report__r.DPD__c, Call_Plan_Call_Report__r.Non_Credit__c, Call_Plan_Call_Report__r.No_Change__c, Call_Plan_Call_Report__r.Pain__c FROM Call_Reports_Leads__r ORDER BY CreatedDate DESC) 
    //    FROM Target_List__c 
    //    WHERE CIS_ID_Prospect_Name__c IN :accountSet 
    //    AND Status__c != :GlobalConstants.LEAD_EXPIRED AND Status__c != :GlobalConstants.TG_EXPIRED
    //    AND (Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME OR Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.CBS_LEAD_DEVNAME)];

    //    for(Target_List__c eachTarget : targetLists) {
    //        if(!eachTarget.Call_Reports_Leads__r.isEmpty() ){
    //            for(Call_Report_Lead__c eachCallLead : eachTarget.Call_Reports_Leads__r){
    //                if(callReportMap.containsKey(eachCallLead.Call_Plan_Call_Report__c) ){
    //                    Boolean isUpdateTargetList = false;
    //                    Boolean offerIsNull = false;
    //                    Opportunity_Lead__c eachExistOpportunityLead = null;
    //                    Call_Report__c eachUpdatedCallReport = callReportMap.get(eachCallLead.Call_Plan_Call_Report__c);
    //                    String newStatus = CampaignLead_Service.getNewLeadStatus(eachTarget.Lead_Type__c, eachUpdatedCallReport, null);

    //                    if (!isCallPlan(eachUpdatedCallReport.RecordTypeId) && eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && (eachUpdatedCallReport.Offer_Interest__c == null || eachUpdatedCallReport.Offer_Interest__c == '')) {
    //                        offerIsNull = true;
    //                    }
    //                    if(!((eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO && eachTarget.Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER)
    //                        || (eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO && eachTarget.Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_DPD)
    //                        || (eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER))){
    //                        if(newStatus != null && newStatus != eachTarget.Status__c) {
    //                            eachCallLead.Call_Report_Lead_Status__c = newStatus;
    //                            updateCallReportLeadMap.put(eachCallLead.Id, eachCallLead);
    //                            if(offerIsNull) {
    //                                isUpdateTargetList = true;
    //                                eachTarget.In_Call_Plan__c = false;
    //                            }
    //                            if(eachTarget.Opportunities_Leads__r == null || eachTarget.Opportunities_Leads__r.size() == 0) {
    //                                isUpdateTargetList = true;
    //                                eachTarget.Status__c = newStatus;
    //                            }else if(eachTarget.Lead_Type__c != GlobalConstants.LEAD_TO_DO && eachTarget.Opportunities_Leads__r.size() > 0) { // Have Existing Opportunity Lead
    //                                eachExistOpportunityLead = eachTarget.Opportunities_Leads__r.get(0);
    //                                if(eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.AUTO_CLOSED || eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.CLOSE_LOST || eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.DELETED_OPPORTUNITY) {
    //                                    isUpdateTargetList = true;
    //                                    eachTarget.Status__c = newStatus;
    //                                } else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && eachTarget.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME){
    //                                    if(TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_CALL_PLAN_CALL_REPORT,newStatus,eachTarget.Status__c)){
    //                                        isUpdateTargetList = true;
    //                                        eachTarget.Status__c = newStatus;
    //                                    }
    //                                }
    //                            }else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO){
    //                                isUpdateTargetList = true;
    //                                eachTarget.Status__c = newStatus;
    //                            }

    //                            if(isUpdateTargetList){
    //                                updateTargetListMap.put(eachTarget.Id, eachTarget);
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }


    //        if(eachTarget.CIS_ID_Prospect_Name__c != null && eachTarget.Lead_Campaign__r.Status == GlobalConstants.ACTIVE ) {
    //            if(!targetListsMapByCampaignIdMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c)){
    //               targetListsMapByCampaignIdMapByAccountId.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<Id, List<Target_List__c>>{eachTarget.Lead_Campaign__c => new List<Target_List__c>()});
    //            }
    //            if(!targetListsMapByCampaignIdMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).containsKey(eachTarget.Lead_Campaign__c) ){
    //                targetListsMapByCampaignIdMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).put(eachTarget.Lead_Campaign__c,new List<Target_List__c>());
    //            }
    //            targetListsMapByCampaignIdMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).get(eachTarget.Lead_Campaign__c).add(eachTarget);
    //        }
    //        if(eachTarget.Call_Reports_Leads__r != null && eachTarget.Call_Reports_Leads__r.size() > 0) {
    //            for(Call_Report_Lead__c eachCallReportLead : eachTarget.Call_Reports_Leads__r) {
    //                if(eachCallReportLead.Call_Plan_Call_Report__c != null){
    //                    callReportLeadMapByCallReportId.put(eachCallReportLead.Call_Plan_Call_Report__c, eachCallReportLead);
    //                }
    //                callReportLeadMapByTGLId.put(eachTarget.id,eachCallReportLead);
    //            }
    //        }
    //    }

    //    List<Target_List__c> newTargetLists = new List<Target_List__c>();
    //    List<Call_Report_Lead__c> newLeadList = new List<Call_Report_Lead__c>();
    //    List<Opportunity_Lead__c> newOppLeadList = new List<Opportunity_Lead__c>();
    //    Map<Id, Opportunity> updateOpportunityMap = new Map<Id, Opportunity>();
    //    Map<Id, String> leadTypeMapByMainTargetId = new Map<Id, String>();
    //    Map<Id, Id> callReportIdMapByMainTargetId = new Map<Id, Id>();
        
    //    Boolean offerIsNull = false;

    //    List<Call_Report__c> listNewCallReport = [SELECT ID,CIS_ID__c,RecordTypeId,Primary_Call_Plan_Call_Report__c,Offer_Interest__c,Status__c,Plan_Date__c,CIS_ID__r.Id,CIS_ID__r.CIS__c,CIS_ID__r.RecordTypeId,CIS_ID__r.Name FROM Call_Report__c WHERE ID IN :callReportMap.keySet()];
    //    Id RECORDTYPE_SME_CUSTOMER = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
    //    Id RECORDTYPE_SME_PROSPECT = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT);
    //    for(Call_Report__c eachNewCallReport : listNewCallReport) {
    //        if(targetListsMapByCampaignIdMapByAccountId.containsKey(eachNewCallReport.CIS_ID__c)) { // If have existing Lead
    //            targetLists = null;
    //            Call_Report_Lead__c eachExistCallReportLead = null;
    //            Opportunity_Lead__c eachExistOpportunityLead = null;
    //            Boolean isCreateLead = false;

    //            targetLists = new List<Target_List__c>();
    //            for(List<Target_List__c> listOfTargetList : targetListsMapByCampaignIdMapByAccountId.get(eachNewCallReport.CIS_ID__c).values()){
    //                if(listOfTargetList != null && listOfTargetList.size() > 0){
    //                    targetLists.addAll(listOfTargetList);
    //                }
    //            }
    //            for(Target_List__c eachTarget : targetLists) {
    //                Boolean isUpdateTargetList = false;
    //                if(eachTarget.Lead_Campaign__r.Status != GlobalConstants.ACTIVE || eachTarget.Status__c == GlobalConstants.REJECTED || eachTarget.Status__c == GlobalConstants.STATUS_CHANGED_OWNER || TargetList_Service.doesTargetListMatchTaskCondition(eachTarget)){
    //                    continue;
    //                }
    //                if((eachTarget.Lead_Type__c != GlobalConstants.LEAD_TO_DO && eachTarget.Lead_Type__c != GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER) && eachTarget.Opportunities_Leads__r != null && eachTarget.Opportunities_Leads__r.size() > 0) { // Have Existing Opportunity Lead
    //                    eachExistOpportunityLead = eachTarget.Opportunities_Leads__r.get(0);
    //                    if(!GlobalConstants.OPP_STAGE_COMPLETE_WIN.contains(eachExistOpportunityLead.Opportunity__r.StageName)){ 
    //                        // Create Lead + Update Status
    //                        if(GlobalConstants.OPP_STAGE_COMPLETE_LOST.contains(eachExistOpportunityLead.Opportunity__r.StageName)){
    //                            isCreateLead = true;
    //                            if(!isCallPlan(eachNewCallReport.RecordTypeId)) {
    //                                isUpdateTargetList = true;
    //                            }
    //                        }else {
    //                            // Create Lead NOT Update Status
    //                            isCreateLead = true;
    //                        }
    //                    }
    //                }else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && eachTarget.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME) {
    //                    // CBS Lead for Sales
    //                    isCreateLead = true;
    //                    isUpdateTargetList = true;
    //                }else if(eachTarget.Call_Reports_Leads__r != null && eachTarget.Call_Reports_Leads__r.size() > 0) { // Have Existing CallReport Lead
    //                    eachExistCallReportLead = eachTarget.Call_Reports_Leads__r.get(0);
    //                    if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO) {
    //                        if(eachTarget.Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_DPD || eachTarget.Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER){
    //                            isCreateLead = true;
    //                        }
    //                    }else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER){
    //                        isCreateLead = true;
    //                    }else if(isCallReport(eachExistCallReportLead.Call_Plan_Call_Report__r.RecordTypeId)) {
    //                        if(isCallPlan(eachNewCallReport.RecordTypeId)) { // Exist Call Report and Create Call Plan
    //                            // Create Lead NOT Update Status
    //                            isCreateLead = true;
    //                            if((eachExistCallReportLead.Call_Plan_Call_Report__r.Offer_Credit_Product__c == null &&
    //                                eachExistCallReportLead.Call_Plan_Call_Report__r.Negotiation__c == null &&
    //                                eachExistCallReportLead.Call_Plan_Call_Report__r.Collect_Documents__c == null) ||
    //                                (eachExistCallReportLead.Call_Plan_Call_Report__r.Offer_Credit_Product__c == false &&
    //                                eachExistCallReportLead.Call_Plan_Call_Report__r.Negotiation__c == false &&
    //                                eachExistCallReportLead.Call_Plan_Call_Report__r.Collect_Documents__c == false)) {
    //                                isUpdateTargetList = true;
    //                            }
    //                        }else{
    //                            // Create Lead + Update Status
    //                            isCreateLead = true;
    //                            isUpdateTargetList = true;
    //                        }
    //                    }else if(isCallPlan(eachExistCallReportLead.Call_Plan_Call_Report__r.RecordTypeId)) {
    //                        if(isCallPlan(eachNewCallReport.RecordTypeId)) { // Exist Call Plan and Create Call Plan
    //                            if(eachExistCallReportLead.Call_Plan_Call_Report__r.Status__c == GlobalConstants.CANCEL) {
    //                                // Create Lead + Update Status
    //                                isCreateLead = true;
    //                                isUpdateTargetList = true;
    //                            }
    //                        }else{
    //                            // Create Lead + Update Status
    //                            isCreateLead = true;
    //                            isUpdateTargetList = true;
    //                        }
    //                    }
    //                }else{ // No existing Call Plan / Call Report / Opportunity
    //                    // Create Lead + Update Status
    //                    isCreateLead = true;
    //                    isUpdateTargetList = true;
    //                }

    //                // ----- FOR Set New Status -----
    //                String newStatus = CampaignLead_Service.getNewLeadStatus(eachTarget.Lead_Type__c, eachNewCallReport, null);
    //                if(!isCallPlan(eachNewCallReport.RecordTypeId) && eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && (eachNewCallReport.Offer_Interest__c == null || eachNewCallReport.Offer_Interest__c == '')) {
    //                    offerIsNull = true;
    //                }else{
    //                    offerIsNull = false;
    //                }

    //                if(newStatus != null && newStatus != eachTarget.Status__c ) {
    //                    if((eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO || eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER) && !eachTarget.IsRespLeadToDo__c && (isCallPlan(eachNewCallReport.RecordTypeId) || isConvertCallPlanToCallReport(eachNewCallReport))){
    //                        eachTarget.Status__c = newStatus;
    //                        isUpdateTargetList = true;
    //                    }else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && eachTarget.Lead_Campaign__r.RecordType.DeveloperName == GlobalConstants.CBS_LEAD_DEVNAME){
    //                        if(TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_CALL_PLAN_CALL_REPORT,newStatus,eachTarget.Status__c)){
    //                            eachTarget.Status__c = newStatus;
    //                        }
    //                    }else if(eachTarget.Lead_Type__c != GlobalConstants.LEAD_TO_DO && eachTarget.Lead_Type__c != GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER){
    //                        if(!isCallPlan(eachNewCallReport.RecordTypeId)){
    //                            eachTarget.Status__c = newStatus;
    //                        }else if(newStatus == GlobalConstants.PLAN){
    //                            eachTarget.Status__c = newStatus;
    //                        }
    //                    }
    //                    if(offerIsNull) eachTarget.In_Call_Plan__c = false;
    //                }

    //                // If is Secondary and in target need to set Main
    //                if(eachNewCallReport.Primary_Call_Plan_Call_Report__c != null && mainCallReportMap.containsKey(eachNewCallReport.Primary_Call_Plan_Call_Report__c) && isSecondaryCallReport(eachNewCallReport.RecordTypeId)) {
    //                    Call_Report__c mainCallReport = mainCallReportMap.get(eachNewCallReport.Primary_Call_Plan_Call_Report__c);
    //                    if(targetListsMapByCampaignIdMapByAccountId.containsKey(mainCallReport.CIS_ID__c) && targetListsMapByCampaignIdMapByAccountId.get(mainCallReport.CIS_ID__c).containsKey(eachTarget.Lead_Campaign__c)) {
    //                        eachTarget.Main_Customer__c = targetListsMapByCampaignIdMapByAccountId.get(mainCallReport.CIS_ID__c).get(eachTarget.Lead_Campaign__c).get(0).Id;
    //                        isUpdateTargetList = true;
    //                    }
    //                }

    //                if(isCreateLead && (!callReportLeadMapByCallReportId.containsKey(eachNewCallReport.Id) || !callReportLeadMapByTGLId.containsKey(eachTarget.Id) )) {
    //                    if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO){
    //                        if(eachTarget.Lead_Campaign__r.Sub_Type__c != GlobalConstants.LEAD_SUB_TYPE_TO_INFORM
    //                            && eachTarget.Lead_Campaign__r.Sub_Type__c != GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM
    //                            && !(eachTarget.Lead_Campaign__r.Sub_Type__c == GlobalConstants.LEAD_SUB_TYPE_DPD && eachTarget.Active_Target_List__c == null) ){
    //                            newLeadList.add(new Call_Report_Lead__c(
    //                                Call_Plan_Call_Report__c = eachNewCallReport.Id,
    //                                Target_List__c = eachTarget.Id,
    //                                Call_Report_Lead_Status__c = eachTarget.Status__c
    //                            ));
    //                        }
    //                    }else{
    //                        newLeadList.add(new Call_Report_Lead__c(
    //                            Call_Plan_Call_Report__c = eachNewCallReport.Id,
    //                            Target_List__c = eachTarget.Id,
    //                            Call_Report_Lead_Status__c = newStatus
    //                        ));
    //                    }
    //                }

    //                if(isUpdateTargetList) {
    //                    updateTargetListMap.put(eachTarget.Id, eachTarget);
    //                }
    //            }
    //        } 
    //        // Not in Existing Target List
    //        if(eachNewCallReport.Primary_Call_Plan_Call_Report__c != null && mainCallReportMap.containsKey(eachNewCallReport.Primary_Call_Plan_Call_Report__c) && isSecondaryCallReport(eachNewCallReport.RecordTypeId)) {
    //            // Is Secondary Call Report and have Primary In Target List
    //            targetLists = null;
    //            Call_Report__c mainCallReport = mainCallReportMap.get(eachNewCallReport.Primary_Call_Plan_Call_Report__c);
    //            if(targetListsMapByCampaignIdMapByAccountId.containsKey(mainCallReport.CIS_ID__c)) {
    //               // targetLists = targetListsMapByCampaignIdMapByAccountId.get(mainCallReport.CIS_ID__c).values().get(0);
    //                targetLists = new List<Target_List__c>();
    //                for(List<Target_List__c> listOfTargetList : targetListsMapByCampaignIdMapByAccountId.get(mainCallReport.CIS_ID__c).values()){
    //                    if(listOfTargetList != null && listOfTargetList.size() > 0){
    //                        targetLists.addAll(listOfTargetList);
    //                    }
    //                }
    //                for(Target_List__c mainTargetList : targetLists) {   
    //                    if(targetListsMapByCampaignIdMapByAccountId.containsKey(eachNewCallReport.CIS_ID__c) && targetListsMapByCampaignIdMapByAccountId.get(eachNewCallReport.CIS_ID__c).containsKey(mainTargetList.Lead_Campaign__c)) {
    //                        continue;
    //                    }
    //                    if(!mainTargetList.Lead_Campaign__r.Add_Associated_Lead__c){
    //                        continue;
    //                    }

    //                    String newStatus = CampaignLead_Service.getNewLeadStatus(mainTargetList.Lead_Type__c, eachNewCallReport, null);
    //                    if (!isCallPlan(eachNewCallReport.RecordTypeId) && mainTargetList.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES && (eachNewCallReport.Offer_Interest__c == null || eachNewCallReport.Offer_Interest__c == '')) {
    //                        offerIsNull = true;
    //                    } else {
    //                        offerIsNull = false;
    //                    }

    //                    Target_List__c newTarget = new Target_List__c();
    //                    newTarget.IsFromTrigger__c = true;
    //                    newTarget.CIS_ID_Prospect_Name__c = eachNewCallReport.CIS_ID__c;
    //                    newTarget.Lead_Campaign__c = mainTargetList.Lead_Campaign__c;
    //                    newTarget.Main_Customer__c = mainTargetList.Id;
    //                    newTarget.Status__c = newStatus;
    //                    //if(eachNewCallReport.CIS_ID__r.RecordTypeId == RECORDTYPE_SME_PROSPECT) {
    //                        newTarget.External_ID__c = String.valueOf(mainTargetList.Lead_Campaign__r.Name) + ':' + String.valueOf(eachNewCallReport.CIS_ID__r.Id);
    //                        newTarget.External_ID_CDB__c = String.valueOf(mainTargetList.Lead_Campaign__r.Name) + ':' + String.valueOf(eachNewCallReport.CIS_ID__r.Id);
    //                    //}else{
    //                    //    newTarget.External_ID__c = String.valueOf(mainTargetList.Lead_Campaign__r.Name) + ':' + String.valueOf(eachNewCallReport.CIS_ID__r.CIS__c);
    //                    //}
    //                    if(offerIsNull) newTarget.In_Call_Plan__c = false;

    //                    leadTypeMapByMainTargetId.put(newTarget.Main_Customer__c, mainTargetList.Lead_Type__c);
    //                    callReportIdMapByMainTargetId.put(newTarget.Main_Customer__c, eachNewCallReport.Id);
    //                    newTargetLists.add(newTarget);
    //                }
    //            }
    //        }
    //    }

    //    // Create New Target List for Associated Customer
    //    if(!newTargetLists.isEmpty()) {
    //        upsert newTargetLists External_ID__c;
    //        for(Target_List__c eachNewTargetlist : newTargetLists) {
    //            if(eachNewTargetlist.Main_Customer__c != null && callReportIdMapByMainTargetId.containsKey(eachNewTargetlist.Main_Customer__c)) {
    //                Id callRepId = callReportIdMapByMainTargetId.get(eachNewTargetlist.Main_Customer__c);
    //                newLeadList.add(new Call_Report_Lead__c(
    //                    Call_Plan_Call_Report__c = callReportIdMapByMainTargetId.get(eachNewTargetlist.Main_Customer__c),
    //                    Target_List__c = eachNewTargetlist.Id,
    //                    Call_Report_Lead_Status__c = eachNewTargetlist.Status__c
    //                ));
    //                Boolean isCreateLead        = false;
    //                Boolean isUpdateTargetList  = false;
    //                Boolean isChangeFocus       = false;
    //                Boolean isFocusing = false;
    //                // If Associated Is Main Borrower and created Opportunity => Create Opp/Lead
    //                if(oppIdMapByCallReportId.containsKey(callRepId) && (leadTypeMapByMainTargetId.containsKey(eachNewTargetlist.Main_Customer__c) && leadTypeMapByMainTargetId.get(eachNewTargetlist.Main_Customer__c) == GlobalConstants.LEAD_FOR_SALES)) {
    //                    String oppId = oppIdMapByCallReportId.get(callRepId);
    //                    Opportunity eachOpp = opportunityMap.get(oppId);
    //                    //Account eachAccount = accountMap.get(eachOpp.AccountId);
    //                    Map<String, Boolean> mapOppConditionByKey = CampaignLead_Service.checkCreateOppCondition(eachNewTargetlist, mapFocusedOppLeadByTgl, oppId);
                        
    //                    isCreateLead = mapOppConditionByKey.get('isCreateLead');
    //                    isUpdateTargetList = mapOppConditionByKey.get('isUpdateTargetList');
    //                    isChangeFocus = mapOppConditionByKey.get('isChangeFocus');

    //                    String newStatus = CampaignLead_Service.getNewLeadStatus(leadTypeMapByMainTargetId.get(eachNewTargetlist.Main_Customer__c), null, eachOpp.StageName);
    //                    if (newStatus != null && newStatus != eachNewTargetlist.Status__c) {
    //                        eachNewTargetlist.Status__c = newStatus;
    //                    }

    //                    if(isChangeFocus) {
    //                        isFocusing = true;
    //                    }

    //                    if(isCreateLead) {
    //                        newOppLeadList.add(new Opportunity_Lead__c(
    //                            Opportunity__c = oppId,
    //                            Target_List__c = eachNewTargetlist.Id,
    //                            Opportunity_Lead_Status__c = newStatus,
    //                            Is_Focusing__c  = isFocusing
    //                        ));
    //                    }
    //                    //eachNewTargetlist.Approved_Amount__c = eachOpp.Approved_Amount__c;
    //                    //eachNewTargetlist.Setup_Amount__c = eachOpp.Setup_Amount__c;
    //                    if(isUpdateTargetList) {
    //                        updateTargetListMap.put(eachNewTargetlist.Id, eachNewTargetlist);
    //                    }
    //                }
    //            }
    //        }
    //    }

    //    List<Call_Report_Lead__c> callReportLeadToUpsert = new List<Call_Report_Lead__c>();
    //    if(!newLeadList.isEmpty()) callReportLeadToUpsert.addAll(newLeadList);
    //    if(!updateCallReportLeadMap.isEmpty()) callReportLeadToUpsert.addAll(updateCallReportLeadMap.values());

    //    if(!callReportLeadToUpsert.isEmpty()) upsert callReportLeadToUpsert;
    //    if(!newOppLeadList.isEmpty()) upsert newOppLeadList;
    //    if(!updateTargetListMap.isEmpty()) update updateTargetListMap.values();

    //    TriggerHandler.bypass('OpportunityTriggerHandler');
    //    if(!updateOpportunityMap.isEmpty()) update updateOpportunityMap.values();
    //    TriggerHandler.clearBypass('OpportunityTriggerHandler');
    //}

    ////Get New Target List Status For Closed Opportunity CBS
    //private static String getNewStatusForClosedOpportunityCBS(Id currentOpportunityId, String newStatus, Set<String> campaingProductSet, Account eachAccount, Set<Id> oppIdsInOppLead){
    //    if(eachAccount.Opportunities_Planning__r != null)
    //    for(Opportunity_Planning__c eachOppPlanning : eachAccount.Opportunities_Planning__r) {
    //        if(eachOppPlanning.Product_List_CBS__c != null && eachOppPlanning.Status__c != GlobalConstants.OPP_PLAN_WIN_MANDATE) {
    //            Set<String> oppPlannignProductSet = new Set<String>(eachOppPlanning.Product_List_CBS__c.split(','));
                
    //            if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppPlannignProductSet) && 
    //                TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY_PLANNING, eachOppPlanning.Status__c, newStatus)) {
    //                newStatus = eachOppPlanning.Status__c;
    //            }    
    //        }
    //    }

    //    String checkingStatus = '';
    //    if(eachAccount.Opportunities != null)
    //    for(Opportunity eachOpp : eachAccount.Opportunities) {
    //        if(eachOpp.Id == currentOpportunityId || eachOpp.Product_List_CBS__c == null || !oppIdsInOppLead.contains(eachOpp.Id)) continue;
            
    //        Set<String> newOppProductSet = new Set<String>(eachOpp.Product_List_CBS__c.split(','));

    //        if(eachOpp.StageName == GlobalConstants.STATUS_NEW) {
    //            checkingStatus = GlobalConstants.NEW_OPPORTUNITY;
    //        } else {
    //            checkingStatus = eachOpp.StageName;
    //        }
            
    //        if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, newOppProductSet) 
    //            && TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY, checkingStatus, newStatus)) {
    //            newStatus = checkingStatus;
    //        }
    //    }

    //    return newStatus;
    //}

    ///**
    //    LeadDPD
    //**/

    public static Map<String,Target_List__c> getTargetListMapByExternalId(Set<Id> accountIdSet,Campaign campaign){
        Map<String,Target_List__c> targetListMapByLPMId = new Map<String,Target_List__c>();
        List<Target_List__c> targetLists = [SELECT Id,No_of_Active_Times__c,Active_Target_List__c,LPM__c,External_ID__c,Response_Level_1__c,Response_Level_2__c,Memo__c,Status__c,Response_Date__c,Application_ID__c,Active_Date__c,IsRespLeadToDo__c From Target_List__c WHERE CIS_ID_Prospect_Name__c IN :accountIdSet AND Lead_Campaign__c = :campaign.id];
        for(Target_List__c eachTargetList : targetLists){
            targetListMapByLPMId.put(eachTargetList.External_ID__c,eachTargetList);
        }
        return targetListMapByLPMId;
    }

    public static void setEventFieldSet(Campaign newCampaign,Campaign oldCampaign) {
        newCampaign.Previous_Dress_Code__c      = oldCampaign.Dress_Code__c;
        newCampaign.Previous_End_Date_Time__c   = oldCampaign.End_Date_Time__c;
        newCampaign.Previous_Food__c            = oldCampaign.Food__c;
        newCampaign.Previous_Name__c            = oldCampaign.Name;
        newCampaign.Previous_Start_Date_Time__c = oldCampaign.Start_Date_Time__c;
        newCampaign.Previous_Venue__c           = oldCampaign.Venue__c;
    }

    public static void setHistoryTracking(Campaign newCampaign,Campaign oldCampaign){
        Boolean isFieldChange = false;
        String newHistory = '';
        String oldHistory = '';
        String delimiter = ',';
        String endLine = ';';
   
        newHistory = 'UserId=' + UserInfo.getUserId() + delimiter + 'Time=' + System.now().format('yyyy-MM-dd HH:mm');
        for(String eachFieldTracking : GlobalConstants.CAMPAIGN_FIELDSTRACKING){
            if(newCampaign.get(eachFieldTracking) != oldCampaign.get(eachFieldTracking)){
                newHistory = newHistory + delimiter + eachFieldTracking +'(oldRecord='+oldCampaign.get(eachFieldTracking)+':newRecord='+newCampaign.get(eachFieldTracking)+')';
                isFieldChange = true;
            }
        }

        newHistory = newHistory + endLine;
        if(isFieldChange){
            if( String.isNotBlank(newCampaign.History_tracking__c)  && newCampaign.History_tracking__c.length() > 45000){
                oldHistory = newCampaign.History_tracking__c.split(endLine,2).get(1);
            }else{
                oldHistory = newCampaign.History_tracking__c == null ? '' : newCampaign.History_tracking__c;
            }
            newCampaign.History_tracking__c = oldHistory + newHistory;
        }
    }

    public static void stampCDBField(Campaign eachCampaign) {
        User currentUser = UserService.getCurrentUserInfo();
        if(eachCampaign.Created_By_CDB__c == null && eachCampaign.Created_Date_CDB__c == null 
            && eachCampaign.Last_Modified_By_CDB__c == null && eachCampaign.Last_Modified_Date_CDB__c == null){
            eachCampaign.Created_By_CDB__c = currentUser.Employee_ID__c;
            eachCampaign.Created_Date_CDB__c = System.now().format('yyyy-MM-dd');
            eachCampaign.Last_Modified_By_CDB__c = currentUser.Employee_ID__c;
            eachCampaign.Last_Modified_Date_CDB__c = System.now().format('yyyy-MM-dd');
        }
    }

    public static void checkCampaignToActive(Campaign newCampaign, Campaign oldCampaign){
        if((newCampaign.Status == GlobalConstants.PLANNED && (newCampaign.StartDate != oldCampaign.StartDate && newCampaign.StartDate != null && newCampaign.StartDate <= System.today()))) {
            CampaignLead_Service.setCampaignToActive(newCampaign);
        }
    }

    public static void checkCampaignToActive(Campaign newCampaign){
        if(newCampaign.Status == GlobalConstants.PLANNED && newCampaign.StartDate != null && newCampaign.StartDate <= System.today()) {
            CampaignLead_Service.setCampaignToActive(newCampaign);
        }
    }

    public static void setCampaignToActive(Campaign newCampaign){
        newCampaign.IsActive = true;
        newCampaign.Status = GlobalConstants.ACTIVE;
    }

    public static Boolean isCampaignExpiring(Campaign newCampaign){
        if(newCampaign.Status != null && (newCampaign.Status == GlobalConstants.EXPIRE_PROCESS || newCampaign.Status == GlobalConstants.CANCEL_PROCESS)){
            return true;
        }
        return false;
    }

    //public static void recalculateOppLeadWhenOppTypeChange(List<Application_History__c> listAppHis){
    //    Set<Id> removeOpportunityLeadSet = new Set<Id>();
    //    Set<Id> createOpportunityLeadSet = new Set<Id>();
    //    Map<Id,Opportunity> removeOpportunityLeadMap = new Map<Id,Opportunity>();
    //    Map<Id,Opportunity> createOpportunityLeadMap = new Map<Id,Opportunity>();
    //    List<Application_History__c> listAppHisWithOpp = [SELECT Id,OppName__c,OppName__r.Submit_Issue__c,OppName__r.SP_Submit_Issue__c,SP_Submit_Issue__c FROM Application_History__c WHERE Id IN :listAppHis];

    //    for(Application_History__c eachApp : listAppHisWithOpp){
    //        if(((eachApp.OppName__r.SP_Submit_Issue__c == 'รอการ Update' || String.isBlank(eachApp.OppName__r.SP_Submit_Issue__c)) && eachApp.OppName__r.Submit_Issue__c != eachApp.SP_Submit_Issue__c) 
    //            || (eachApp.OppName__r.SP_Submit_Issue__c != 'รอการ Update' && !String.isBlank(eachApp.OppName__r.SP_Submit_Issue__c) && eachApp.OppName__r.SP_Submit_Issue__c != eachApp.SP_Submit_Issue__c)){
    //            if(eachApp.SP_Submit_Issue__c == GlobalConstants.SERVICING){
    //                removeOpportunityLeadSet.add(eachApp.OppName__c);
    //            }else if(eachApp.SP_Submit_Issue__c == GlobalConstants.NEW_CREDIT){
    //                createOpportunityLeadSet.add(eachApp.OppName__c);
    //            }
    //        }
    //    }

    //    if(removeOpportunityLeadSet != null || createOpportunityLeadSet != null){
    //        for(Opportunity eachOpp : [SELECT Id,SP_Submit_Issue__c,Submit_Issue__c,IsConvertFromCallReport__c,AccountId,CMAS_Status__c,CWU_Number__c,Business_Code__c,Business_Code__r.Name,Owner.Segment__c,Product_List_CBS__c FROM Opportunity WHERE Id IN :removeOpportunityLeadSet OR Id IN :createOpportunityLeadSet]){
    //            if(removeOpportunityLeadSet.contains(eachOpp.Id)){
    //                removeOpportunityLeadMap.put(eachOpp.Id, eachOpp);
    //            }else if(createOpportunityLeadSet.contains(eachOpp.Id)){
    //                createOpportunityLeadMap.put(eachOpp.Id, eachOpp);
    //            }
    //        }
    //        deleteOppLeadServicingAndChangeTglStatus(removeOpportunityLeadMap);
    //        recalculateOppLeadWhenOppTypeChange(removeOpportunityLeadMap,createOpportunityLeadMap);
    //    }
    //}

    //public static void recalculateOppLeadWhenOppTypeChange(Map<Id,Opportunity> mapRemoveOpportunityLead,Map<Id,Opportunity> createOpportunityLeadMap){
    //    if(createOpportunityLeadMap!=null && createOpportunityLeadMap.size() > 0){
    //        Map<Id,Opportunity> tempOpp = new Map<Id,Opportunity>([SELECT Id,AccountId,IsConvertFromCallReport__c,StageName,Product_List_CBS__c FROM Opportunity WHERE Id IN :createOpportunityLeadMap.keySet()]);
    //        CampaignLead_Service.createOpportunityUpdateLeadStatus(tempOpp);
    //    }
    //    //run after create opp/lead
    //    if(mapRemoveOpportunityLead!=null && mapRemoveOpportunityLead.size() > 0){
    //        CampaignLead_Service.updateOpportunityUpdateLeadStatus(mapRemoveOpportunityLead);
    //    }
    //}

    //public static void deleteOppLeadServicingAndChangeTglStatus(Map<Id,Opportunity> mapRemoveOpportunityLead){
    //    if(mapRemoveOpportunityLead!=null && mapRemoveOpportunityLead.size() > 0){
    //        Map<String,Target_List__c> mapUpdateTglStatusToNewMapById = new Map<String,Target_List__c>();
    //        Set<ID> oppID = mapRemoveOpportunityLead.keySet();
    //        List<Opportunity_Lead__c> listRemoveOppLead = [SELECT Id,Target_List__c,Is_Focusing__c FROM Opportunity_Lead__c WHERE Opportunity__c in :oppID];
    //        for(Opportunity_Lead__c eachOppLead : listRemoveOppLead){
    //            if(eachOppLead.Is_Focusing__c){
    //                Target_List__c updateTgl = new Target_List__c(
    //                    Id = eachOppLead.Target_List__c,
    //                    Status__c = GlobalConstants.STATUS_NEW
    //                );
    //                mapUpdateTglStatusToNewMapById.put(updateTgl.Id, updateTgl);
    //            }
    //        }

    //        if(mapUpdateTglStatusToNewMapById.values().size() > 0){
    //            TriggerHandler.bypass('TargetListTriggerHandler');
    //            update mapUpdateTglStatusToNewMapById.values();
    //            TriggerHandler.clearBypass('TargetListTriggerHandler');
    //        }
    //        delete listRemoveOppLead;
    //    }
    //}
}