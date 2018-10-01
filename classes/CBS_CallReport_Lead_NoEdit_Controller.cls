public with sharing class CBS_CallReport_Lead_NoEdit_Controller {
    public ApexPages.StandardController stdController {get; set;}
    public Call_Report__c callReportObject {get; set;}
    public List<Call_Report_Lead__c> listCallReportLead {get;set;}
    public String cisId {get; set;}
    public Boolean hasLeads {get;set;}
    
    public CBS_CallReport_Lead_NoEdit_Controller(ApexPages.StandardController stdController) {
        Set<String> tglShowIfInStatus = new Set<String>{GlobalConstants.STATUS_NEW, GlobalConstants.PLAN, GlobalConstants.CONTACTED};
        Set<String> tglShowIfInStatusForFeedback = new Set<String>{GlobalConstants.STATUS_NEW};
        this.stdController = stdController;
        listCallReportLead = new List<Call_Report_Lead__c>();
        callReportObject = (Call_Report__c) stdController.getRecord();
        callReportObject = [SELECT Id, CIS_ID__r.Id FROM Call_Report__c WHERE Id =: callReportObject.Id];
        cisId = callReportObject.CIS_ID__c;
        
        listCallReportLead = [SELECT Id, Target_List__r.Name, Call_Plan_Call_Report__r.Id, Call_Plan_Call_Report__r.CIS_ID__c, Campaign_Name__c, Target_List__r.Id, Target_List__r.Priority__c, Target_List__r.Personalised_Message__c, Target_List__r.Lead_Campaign__r.Sub_Type__c,Target_List__r.Lead_Campaign__r.Sub_Type_CBS__c,Target_List__r.Lead_Campaign__r.Type__c,Start_Date__c,End_Date__c,Target_List__r.Response_Level_1__c,Target_List__r.Response_Level_2__c,Target_List__r.Memo__c,Target_List__r.Status__c, Target_List__r.Active_Target_List__c  FROM Call_Report_Lead__c WHERE Target_List__r.Active_Target_List__c != null AND Call_Plan_Call_Report__r.Id =: callReportObject.Id AND Call_Plan_Call_Report__r.CIS_ID__c =: cisId AND Target_List__r.Lead_Campaign__r.Type__c IN (:GlobalConstants.LEAD_FOR_SALES,:GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER,:GlobalConstants.LEAD_FOR_FEEDBACK) AND Target_List__r.Status__c NOT IN (:GlobalConstants.CANCEL_LEAD,:GlobalConstants.LEAD_EXPIRED,:GlobalConstants.REJECTED)];
        List<Call_Report_Lead__c> listCallReportLead2 = new List<Call_Report_Lead__c>();

        for(Call_Report_Lead__c eachCallLead : listCallReportLead){
            if(eachCallLead.Target_List__r.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER){
                if(tglShowIfInStatus.contains(eachCallLead.Target_List__r.Status__c)){
                    listCallReportLead2.add(eachCallLead);
                }
            }else if(eachCallLead.Target_List__r.Lead_Campaign__r.Type__c == GlobalConstants.LEAD_FOR_FEEDBACK){
                if(tglShowIfInStatusForFeedback.contains(eachCallLead.Target_List__r.Status__c)){
                    listCallReportLead2.add(eachCallLead);
                }
            }else{
                listCallReportLead2.add(eachCallLead);
            }
        }

        listCallReportLead.clear();
        listCallReportLead.addAll(listCallReportLead2);

        if(listCallReportLead.isEmpty()){
            hasLeads = false;
        }else{
            hasLeads = true;
        }
    }
}