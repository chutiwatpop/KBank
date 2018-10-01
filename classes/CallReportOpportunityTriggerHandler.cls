/**
* @author komsan.wi@beryl8.com
* @30/09/2015 created new
*/
public without sharing class CallReportOpportunityTriggerHandler extends TriggerHandler{

    public override void afterDelete() {
        Set<Id> oppIdSet = new Set<Id>();
        for(Call_Report_Opportunity__c callReportOpp : (List<Call_Report_Opportunity__c>)Trigger.old) {
            oppIdSet.add(callReportOpp.Opportunity_Name__c);
        }
        CallReport_Service.updateActualVisitDateOfOpp(oppIdSet);
    }

    public override void afterInsert() {
    	Set<Id> callReportSet = new Set<Id>();
        Set<Id> opportunitySet = new Set<Id>(); 
        Map<Id, Id> oppIdMapByCallRepId = new Map<Id,Id> ();
    	for(Call_Report_Opportunity__c eachCallOpp : (List<Call_Report_Opportunity__c>)Trigger.new){
    		if(eachCallOpp.Call_Plan_Call_Report__c!=null) callReportSet.add(eachCallOpp.Call_Plan_Call_Report__c);
            if(eachCallOpp.Opportunity_Name__c!=null) {
                oppIdMapByCallRepId.put(eachCallOpp.Call_Plan_Call_Report__c, eachCallOpp.Opportunity_Name__c);    
            }            
    	}
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        if(!oppIdMapByCallRepId.isEmpty()){
            opportunityMap = new Map<Id,Opportunity>([SELECT Id, AccountId, StageName, IsConvertFromCallReport__c, Approved_Amount__c, Setup_Amount__c FROM Opportunity WHERE Id IN:oppIdMapByCallRepId.values() AND IsNewCredit__c = 1]);
            CallReport_Service.updateActualVisitDateOfOpp(opportunityMap.keySet());
        }
        List<Call_Report_Lead__c> callreportLeadList = new List<Call_Report_Lead__c>();
    	callreportLeadList = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.CIS_ID_Prospect_Name__c, Target_List__r.Lead_Type__c, Target_List__r.Lead_Campaign__c FROM Call_Report_Lead__c WHERE Target_List__r.Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES AND Call_Plan_Call_Report__c in :callReportSet];
        
        Map<Id, List<Call_Report_Lead__c>> callRepLeadsMapByOppId = new Map<Id, List<Call_Report_Lead__c>>();
        for(Call_Report_Lead__c eachCallRepLead : callreportLeadList) {
            if(oppIdMapByCallRepId.containsKey(eachCallRepLead.Call_Plan_Call_Report__c)) {
                if(!callRepLeadsMapByOppId.containsKey(oppIdMapByCallRepId.get(eachCallRepLead.Call_Plan_Call_Report__c)))
                    callRepLeadsMapByOppId.put(oppIdMapByCallRepId.get(eachCallRepLead.Call_Plan_Call_Report__c), new List<Call_Report_Lead__c>());
                callRepLeadsMapByOppId.get(oppIdMapByCallRepId.get(eachCallRepLead.Call_Plan_Call_Report__c)).add(eachCallRepLead);
            }
        }
        if(!callRepLeadsMapByOppId.isEmpty())
            CampaignLead_Service.createOpportunityUpdateLeadStatus(opportunityMap, callRepLeadsMapByOppId);
    }
}