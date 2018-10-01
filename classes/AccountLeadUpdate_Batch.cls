global class AccountLeadUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    List<Id> accountIds;
    Map<Id, Map<String, Set<String>>> mapTargetsByAccount;
    Boolean isCallFromInitial;
    Boolean isLeadPriority;

    global AccountLeadUpdate_Batch(Set<Id> setAccountIds) {
        accountIds = new List<Id>(setAccountIds);
        mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        this.query = 'SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status, Lead_Campaign__r.StartDate, Lead_Campaign__r.EndDate FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN (\'' + String.join(accountIds,'\',\'') + '\') AND Lead_Campaign__r.StartDate <= TODAY AND Lead_Campaign__r.EndDate >= TODAY AND (Expiry_Date__c >= TODAY OR Expiry_Date__c = null) ORDER BY CIS_ID_Prospect_Name__c, Lead_Campaign__r.Name ASC';
    }
    
    global AccountLeadUpdate_Batch(Set<Id> setAccountIds, Boolean isCallFromInitial) {
        this.isCallFromInitial = isCallFromInitial;
        accountIds = new List<Id>(setAccountIds);
        mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        this.query = 'SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status, Lead_Campaign__r.StartDate, Lead_Campaign__r.EndDate FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN (\'' + String.join(accountIds,'\',\'') + '\') AND Lead_Campaign__r.StartDate <= TODAY AND Lead_Campaign__r.EndDate >= TODAY AND (Expiry_Date__c >= TODAY OR Expiry_Date__c = null) ORDER BY CIS_ID_Prospect_Name__c, Lead_Campaign__r.Name ASC';
    }

    global AccountLeadUpdate_Batch(Set<Id> setAccountIds, Boolean isCallFromInitial, Boolean isLeadPriority) {
        this.isCallFromInitial = isCallFromInitial;
        this.isLeadPriority = isLeadPriority;
        accountIds = new List<Id>(setAccountIds);
        mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        this.query = 'SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status, Lead_Campaign__r.StartDate, Lead_Campaign__r.EndDate, Lead_Campaign__r.Priority_Group__c, Lead_Campaign__r.Priority__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN (\'' + String.join(accountIds,'\',\'') + '\') AND Lead_Campaign__r.StartDate <= TODAY AND Lead_Campaign__r.EndDate >= TODAY AND (Expiry_Date__c >= TODAY OR Expiry_Date__c = null) ORDER BY Lead_Campaign__r.Priority_Group__c ASC NULLS LAST, Lead_Campaign__r.Priority__c ASC, CIS_ID_Prospect_Name__c ASC, Lead_Campaign__r.Name ASC';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Target_List__c> allTargetList) {
        if(isLeadPriority){
            allTargetList = this.orderByPriority(allTargetList);
        }
        for (Target_List__c eachTarget : allTargetList) {
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
                if(mapTargetsByAccount.size() >= Integer.valueOf(Label.Campaign_Lead_Batch_Size)) {
                    this.updateAccount();
                }
                
                Set<String> leadSetString = new Set<String>();
                leadSetString.add(campaignName);

                mapTargetsByAccount.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<String, Set<String>>{eachTarget.Lead_Type__c => leadSetString});
            }
        }

        if(mapTargetsByAccount.size() > 0) {
            this.updateAccount();    
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
    
    private void updateAccount() {
        List<Account> updateAccount = new List<Account>();
        Account eachAccount;

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
            updateAccount.add(eachAccount);
        }
        if(!updateAccount.isEmpty()) {
            TriggerHandler.bypass('AccountTriggerHandler');
            Account_Service.accountTriggerMap = new Map<Id,Account>();
            if(isCallFromInitial != null && isCallFromInitial) {
                update updateAccount;
            } else {
                System.enqueueJob(new AccountLeadUpdate_Queue(updateAccount));    
            }
            TriggerHandler.clearBypass('AccountTriggerHandler');  

            mapTargetsByAccount.clear();
            if(mapTargetsByAccount.size() > 0) {
                mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();    
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}