public without sharing class CallReportLeadTriggerHandler extends TriggerHandler {

    Map<Id, Target_List__c> updateTargetList;
    Target_List__c updateTarget;

    public override void init() {
        updateTargetList = new Map<Id, Target_List__c>();
    }

    public override void afterInsert() {
        for (Call_Report_Lead__c eachCallReportLead : ((List<Call_Report_Lead__c>)Trigger.new)) {
            if (eachCallReportLead.Target_List__c != null) {
                updateTarget = new Target_List__c(
                    Id = eachCallReportLead.Target_List__c,
                    In_Call_Plan__c = true
                );
                if(!updateTargetList.containsKey(eachCallReportLead.Target_List__c)){
                    updateTargetList.put(eachCallReportLead.Target_List__c, updateTarget);
                }
            }
        }
    }

    public override void afterUpdate() {
        Set<Id> oldTargetIds = new Set<Id>();

        for (Call_Report_Lead__c eachCallLead : ((List<Call_Report_Lead__c>)Trigger.new)) {
            Call_Report_Lead__c oldCallLead = (Call_Report_Lead__c)Trigger.oldMap.get(eachCallLead.Id);
            if(eachCallLead.Target_List__c != null && oldCallLead.Target_List__c != null && eachCallLead.Target_List__c != oldCallLead.Target_List__c) {
                updateTarget = new Target_List__c(
                    Id = eachCallLead.Target_List__c,
                    In_Call_Plan__c = true
                );
                if(!updateTargetList.containsKey(eachCallLead.Target_List__c))
                    updateTargetList.put(eachCallLead.Target_List__c, updateTarget);

                oldTargetIds.add(oldCallLead.Target_List__c);
            } else if(eachCallLead.Target_List__c == null || oldCallLead.Target_List__c == null) {
                eachCallLead.addError('Target_List__c can not be null');
            }
        }

        List<Call_Report_Lead__c> callReportLeadList = new List<Call_Report_Lead__c>();
        callReportLeadList = [SELECT Id, Target_List__c FROM Call_Report_Lead__c WHERE Target_List__c IN :oldTargetIds];
        
        addUpdatedTargetList(callReportLeadList, oldTargetIds);
    }

    public override void afterDelete() {
        Set<Id> existTargetIds = new Set<Id>();
        Set<Id> existCallLeadIds = new Set<Id>();

        for (Call_Report_Lead__c eachCallLead : (List<Call_Report_Lead__c>)Trigger.old) {
            if(eachCallLead.Target_List__c != null) {
                existTargetIds.add(eachCallLead.Target_List__c);
                existCallLeadIds.add(eachCallLead.Id);
            }
        }

        List<Call_Report_Lead__c> callReportLeadList = new List<Call_Report_Lead__c>();
        callReportLeadList = [SELECT Id, Target_List__c FROM Call_Report_Lead__c WHERE Id NOT IN :existCallLeadIds AND Target_List__c IN :existTargetIds];
        
        addUpdatedTargetList(callReportLeadList, existTargetIds);
    }

    void addUpdatedTargetList(List<Call_Report_Lead__c> callReportLeadList, Set<Id> existTargetIds) {
        Set<Id> newTargetIds = new Set<Id>();

        for (Call_Report_Lead__c eachCallReportLead : callReportLeadList) {
            newTargetIds.add(eachCallReportLead.Target_List__c);
        }

        for (Id eachTargetId : existTargetIds) {
            if(!newTargetIds.contains(eachTargetId)) {
                updateTarget = new Target_List__c(
                    Id = eachTargetId,
                    In_Call_Plan__c = false
                );
                if(!updateTargetList.containsKey(eachTargetId))
                    updateTargetList.put(eachTargetId, updateTarget);
            }
        }
    }

    public override void allFinally() {
        System.debug('updateTargetList:'+updateTargetList.values());
        if (!updateTargetList.isEmpty()){
            update updateTargetList.values();
        }
    }

}