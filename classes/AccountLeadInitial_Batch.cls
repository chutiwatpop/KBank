global class AccountLeadInitial_Batch implements Database.Batchable<sObject>, Database.Stateful {    
    String query;
    Set<Id> accountIds;
    Boolean isClearOldData;
    Boolean isLeadPriority;
    Boolean isCallFromInitial;

    global AccountLeadInitial_Batch() {
        this.isClearOldData = true;
        this.isLeadPriority = true;
        accountIds = new Set<Id>();
        this.query = 'SELECT Id,RecordType.DeveloperName,CIS__c FROM Account';
    }

    global AccountLeadInitial_Batch(Boolean isClearOldData,Boolean isLeadPriority) {
        this.isClearOldData = isClearOldData;
        this.isLeadPriority = isLeadPriority;
        accountIds = new Set<Id>();
        this.query = 'SELECT Id,RecordType.DeveloperName,CIS__c FROM Account';
    }

    global AccountLeadInitial_Batch(String cisID) {
        this.isClearOldData = isClearOldData;
        this.isLeadPriority = true;
        accountIds = new Set<Id>();
        this.query = 'SELECT Id,RecordType.DeveloperName,CIS__c FROM Account WHERE CIS__c=\''+cisID+'\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountListResult) {
        List<Account> accountList = new List<Account>();
        for(Account eachAccount : accountListResult){
            if(eachAccount.RecordType.DeveloperName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME
                || eachAccount.RecordType.DeveloperName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME
                || (eachAccount.CIS__c != null && GlobalUtility.isNumberAlphabet(eachAccount.CIS__c) && eachAccount.CIS__c.length() <= 10 && Integer.valueOf(eachAccount.CIS__c) < 1000000000)){
                accountList.add(eachAccount);
            }
        }
        // CR Bad Lead DPD
        Map<String,AggregateResult> LPMAggreGateResultMapByCIS = new Map<String,AggregateResult>();
        Map<Id, Map<String, Set<String>>> mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        Map<Id,Account> updateAccountMap = new Map<Id,Account>();
        List<Target_List__c> relatedTargetList = [SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status, Lead_Campaign__r.StartDate, Lead_Campaign__r.EndDate, Lead_Campaign__r.Priority_Group__c, Lead_Campaign__r.Priority__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN :accountList AND Lead_Campaign__r.StartDate <= TODAY AND Lead_Campaign__r.EndDate >= TODAY ORDER BY Lead_Campaign__r.Priority_Group__c ASC NULLS LAST, Lead_Campaign__r.Priority__c ASC, CIS_ID_Prospect_Name__c ASC, Lead_Campaign__r.Name ASC];
        List<AggregateResult> LPMCustomerAggregateResultList = [SELECT CIS__c,MAX(LPM__r.Display_DPD__c) MAXDPD,SUM(LPM__r.Total_Outstanding__c) TOTALOUT From LPM_Customer__c WHERE CIS__c IN :accountList Group By CIS__c];
        Map<Id,Account> accountByID = new Map<Id,Account>();

        for(AggregateResult eachResultLPM : LPMCustomerAggregateResultList){
            LPMAggreGateResultMapByCIS.put(String.valueof(eachResultLPM.get('CIS__c')),eachResultLPM);
        }

        if(isLeadPriority){
            relatedTargetList = this.orderByPriority(relatedTargetList);
        }

        for (Target_List__c eachTarget : relatedTargetList) {
            String campaignName;
            if(isLeadPriority && (eachTarget.Lead_Campaign__r.Priority_Group__c != null && eachTarget.Lead_Campaign__r.Priority_Group__c != '')){
                String priorityGroup;
                if(eachTarget.Lead_Campaign__r.Priority_Group__c == 'Hot'){priorityGroup = 'H';}
                else if(eachTarget.Lead_Campaign__r.Priority_Group__c == 'Warm'){priorityGroup = 'W';}
                else if(eachTarget.Lead_Campaign__r.Priority_Group__c == 'Cold'){priorityGroup = 'C';}
                campaignName = String.valueOf(priorityGroup) + String.valueOf(eachTarget.Lead_Campaign__r.Priority__c) +'-'+ String.valueOf(eachTarget.Lead_Campaign__r.Name);
            }else{
                campaignName = eachTarget.Lead_Campaign__r.Name;
            }

            if(mapTargetsByAccount.containsKey(eachTarget.CIS_ID_Prospect_Name__c)) {
                if(mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).get(eachTarget.Lead_Type__c) == null) {
                    Set<String> leadSetString = new Set<String>();
                    leadSetString.add(campaignName);
                    mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).put(eachTarget.Lead_Type__c, leadSetString);
                } else {
                    mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).get(eachTarget.Lead_Type__c).add(campaignName);            
                }
            } else {   
                Set<String> leadSetString = new Set<String>();
                leadSetString.add(campaignName);

                mapTargetsByAccount.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<String, Set<String>>{eachTarget.Lead_Type__c => leadSetString});
            }
        }
        
        updateAccountMap =  calculateAccountLead(mapTargetsByAccount);

        List<Account> updateAccounts = new List<Account>();
        for(Account eachAccount : accountList) {
            if(isClearOldData != null && isClearOldData) {
             
                if(LPMAggreGateResultMapByCIS.containsKey(eachAccount.id)){
                    String maxDPD =  '';
                    Decimal totalOutstanding = 0;
                    if(LPMAggreGateResultMapByCIS.get(eachAccount.id).get('MAXDPD') != null){
                        maxDPD = GlobalUtility.toValue( LPMAggreGateResultMapByCIS.get(eachAccount.id).get('MAXDPD') );
                    }
                    if(LPMAggreGateResultMapByCIS.get(eachAccount.id).get('TOTALOUT') != null){
                        totalOutstanding = Decimal.valueOf( GlobalUtility.toValue(LPMAggreGateResultMapByCIS.get(eachAccount.id).get('TOTALOUT')) );
                    }

                    if(updateAccountMap.containsKey(eachAccount.id)){
                        updateAccountMap.get(eachAccount.id).Max_DPD__c = maxDPD;
                        updateAccountMap.get(eachAccount.id).Total_Outstanding__c = totalOutstanding;
                    }else{
                        eachAccount.Max_DPD__c = maxDPD;
                        eachAccount.Total_Outstanding__c = totalOutstanding;
                        updateAccountMap.put(eachAccount.Id,eachAccount);
                    }
                }
            }
        }

        if(!updateAccountMap.isEmpty()){
            //Add ByPass Trigger Fix INC000000567874
            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccountMap.values();
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }

    private List<Target_List__c> orderByPriority(List<Target_List__c> allTargetList) {
        List<Target_List__c> finalOrderByPriority = new List<Target_List__c>();
        List<Target_List__c> orderByHotPriority = new List<Target_List__c>();
        List<Target_List__c> orderByWarmPriority = new List<Target_List__c>();
        List<Target_List__c> orderByColdPriority = new List<Target_List__c>();
        List<Target_List__c> orderByBlankPriority = new List<Target_List__c>();
        for(Target_List__c tempTargetList : allTargetList){
            if(String.valueOf(tempTargetList.Lead_Campaign__r.Priority_Group__c) == 'Hot'){
                orderByHotPriority.add(tempTargetList);
            }else if(String.valueOf(tempTargetList.Lead_Campaign__r.Priority_Group__c) == 'Warm'){
                orderByWarmPriority.add(tempTargetList);
            }else if(String.valueOf(tempTargetList.Lead_Campaign__r.Priority_Group__c) == 'Cold'){
                orderByColdPriority.add(tempTargetList);
            }else{
                orderByBlankPriority.add(tempTargetList);
            }
        }
        finalOrderByPriority.addAll(orderByHotPriority);
        finalOrderByPriority.addAll(orderByWarmPriority);
        finalOrderByPriority.addAll(orderByColdPriority);
        finalOrderByPriority.addAll(orderByBlankPriority);
        return finalOrderByPriority;
    }

    private Map<Id,Account> calculateAccountLead(Map<Id, Map<String, Set<String>>> mapTargetsByAccount) {
        Account eachAccount;
        Map<Id,Account> updateAccountMap = new Map<Id,Account>();
        for (Id eachAccountId : mapTargetsByAccount.keySet()) {
            eachAccount = new Account(Id = eachAccountId);
            List<String> leadForSaleList = new List<String>();
            List<String> leadToInformList = new List<String>();
            List<String> leadToDoList = new List<String>();
            List<String> leadForActionWithCustomerList = new List<String>();
            List<String> leadForFeedbackList = new List<String>();

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_SALES) != null) {
                leadForSaleList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_SALES));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_INFORM) != null) {
                leadToInformList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_INFORM));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.CAMPAIGN) != null) {
                leadToInformList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.CAMPAIGN));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_DO) != null) {
                leadToDoList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_DO));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER) != null) {
                leadForActionWithCustomerList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_FEEDBACK) != null) {
                leadForFeedbackList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_FEEDBACK));
            }

            eachAccount.Lead_For_Sales__c = leadForSaleList.isEmpty() ? null : String.join(leadForSaleList, ',');
            eachAccount.Lead_To_Do__c = leadToDoList.isEmpty() ? null : String.join(leadToDoList, ',');
            eachAccount.Lead_To_Inform__c = leadToInformList.isEmpty() ? null : String.join(leadToInformList, ',');
            eachAccount.Lead_for_Action_with_Customer_CBS__c = leadForActionWithCustomerList.isEmpty() ? null : String.join(leadForActionWithCustomerList, ',');
            eachAccount.Lead_for_Feedback_CBS__c = leadForFeedbackList.isEmpty() ? null : String.join(leadForFeedbackList, ',');
            updateAccountMap.put(eachAccount.Id,eachAccount);
        }
        return updateAccountMap;
    }

    global void finish(Database.BatchableContext BC) {}
}