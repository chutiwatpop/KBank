global class CBS_GroupSubGroup_Transaction_Batch  implements Database.Batchable<sObject>,Database.Stateful {
    
    String query;
    String defaultQuery = 'SELECT Id,Customer__c,Customer__r.Primary_Segment_Code__c,Group_Sub_Group__c,Group_Sub_Group__r.Group_Lookup__c,Group_Sub_Group__r.Sub_Group_Lookup__c,Group_Sub_Group_Transaction_Update__c,OwnerId,Customer__r.CIS__c,Is_Active__c FROM Customer_Group_Sub_Group__c ';
    Boolean checkInitial;
    Map<Id,Customer_Group_Sub_Group__c> customerGroupSubGroupMap;
    List<Group_Sub_Group_Transaction__c> groupSubGroupTransactionList;
    Set<Id> accountsClearFlagIdSet = new Set<Id>();

    global CBS_GroupSubGroup_Transaction_Batch () {
        this.query = defaultQuery + 'WHERE Group_Sub_Group_Transaction_Update__c = true AND Is_Active__c = true';
    }
    global CBS_GroupSubGroup_Transaction_Batch (Boolean initial) {
        if(initial == true){
            this.query = defaultQuery + 'WHERE Is_Active__c = true';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Group_Sub_Group__c> customerGroupSubGroupList) {
        customerGroupSubGroupMap = new Map<Id,Customer_Group_Sub_Group__c>();
        groupSubGroupTransactionList = new List<Group_Sub_Group_Transaction__c>();

        if(customerGroupSubGroupList.size() != 0){
        	for(Customer_Group_Sub_Group__c customerGroupSubGroup :customerGroupSubGroupList){
        		customerGroupSubGroupMap.put(customerGroupSubGroup.Customer__c, customerGroupSubGroup);
        	}

        	List<Target_List__c> targetListByCIS = [SELECT Id,CIS_ID_Prospect_Name__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN : customerGroupSubGroupMap.keySet()];
            if(!targetListByCIS.isEmpty()){
        		for(Target_List__c targetList :targetListByCIS){
                    createGroupSubGroupList(targetList.Id,targetList.CIS_ID_Prospect_Name__c,'TargetList');
                }
        	}
        	/*List<Call_Report__c> callReportByCIS = [SELECT Id,CIS_ID__c FROM Call_Report__c WHERE CIS_ID__c IN :customerGroupSubGroupMap.keySet()];
            if(!callReportByCIS.isEmpty()){
                for(Call_Report__c callReport :callReportByCIS){
                    createGroupSubGroupList(callReport.Id,callReport.CIS_ID__c,'CallReport');
                }
            }
            List<Opportunity_Planning__c> oppPlanningByCIS = [SELECT Id,CIS_ID__c FROM Opportunity_Planning__c WHERE CIS_ID__c IN :customerGroupSubGroupMap.keySet()];
            if(!oppPlanningByCIS.isEmpty()){
                for(Opportunity_Planning__c oppPlanning :oppPlanningByCIS){
                    createGroupSubGroupList(oppPlanning.Id,oppPlanning.CIS_ID__c,'OpportunityPlanning');
                }
            }
            List<Event> eventLists = [SELECT Id, WhatId FROM Event WHERE Status__c = 'Contacted' AND WhatId != null];
            Map<Id,Id> possibleOpportunityMap = new Map<Id,Id>();
            for(Event eachEvent : eventLists){
                if(!possibleOpportunityMap.containsKey(eachEvent.WhatId)){
                    possibleOpportunityMap.put(eachEvent.WhatId, eachEvent.Id);
                }
            }*/

            List<Opportunity> opportunityByCIS = [SELECT Id,AccountId,owner.Profile.Name FROM Opportunity WHERE AccountId IN :customerGroupSubGroupMap.keySet()];
            if(!opportunityByCIS.isEmpty()){
                for(Opportunity opportunity :opportunityByCIS){
                    if(GlobalConstants.PROFILE_CBS_SET.contains(opportunity.owner.Profile.Name)){
                        createGroupSubGroupList(opportunity.Id,opportunity.AccountId,'Opportunity');
                    }            
                }
            }
            if(!groupSubGroupTransactionList.isEmpty()){
                try{
                    upsert groupSubGroupTransactionList External_ID__c;
                } catch(Exception ex){
                    GlobalUtility.logMessage('ERROR','CBS_GroupSubGroup_Transaction_Batch','execute_CBS_GroupSubGroup_Transaction_Batch',null,null,ex.getMessage(),null,ex,null);
                }
		    }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
         if(customerGroupSubGroupMap != null && !customerGroupSubGroupMap.isEmpty()){
            //List<Account> accountsClearFlagList = [SELECT Id,Group_Sub_Group_Transaction_Update__c FROM Account WHERE Id IN :accountsClearFlagIdSet];
            List<Account> accountsClearFlagList = [SELECT Id,Group_Sub_Group_Transaction_Update__c FROM Account WHERE Id IN :customerGroupSubGroupMap.keySet()];
            for(Account accountClearFlag :accountsClearFlagList){
                accountClearFlag.Group_Sub_Group_Transaction_Update__c = false;
            }
            try{
                TriggerHandler.bypass('AccountTriggerHandler');
                update accountsClearFlagList;
                TriggerHandler.clearBypass('AccountTriggerHandler');
            } catch(Exception ex){
                GlobalUtility.logMessage('ERROR','CBS_GroupSubGroup_Transaction_Batch','finish_CBS_GroupSubGroup_Transaction_Batch',null,null,ex.getMessage(),null,ex,null);
            }
        }
    }

    private void createGroupSubGroupList(Id objectId,Id accountId,String objectName){
    	String sortName;

    	Group_Sub_Group_Transaction__c groupSubGroupTranNew = new Group_Sub_Group_Transaction__c();
        if(objectName.equals('TargetList')){
    		sortName = 'T';
    		groupSubGroupTranNew.Target_List_Lookup__c = objectId;
    	/*}else if(objectName.equals('CallReport')){
    		sortName = 'C';
    		groupSubGroupTranNew.Call_Plan_Call_Report_Lookup__c = objectId;
    	}else if(objectName.equals('OpportunityPlanning')){
    		sortName = 'OP';
    		groupSubGroupTranNew.Opportunity_Planning_Lookup__c = objectId;*/
    	}else if(objectName.equals('Opportunity')){
    		sortName = 'O';
            if(groupSubGroupTranNew.Opportunity_Lookup__c != null){
                return;
            }
    		groupSubGroupTranNew.Opportunity_Lookup__c = objectId;
    	}
        groupSubGroupTranNew.CIS_ID__c = customerGroupSubGroupMap.get(accountId).Customer__c;
        groupSubGroupTranNew.Group_Lookup__c = customerGroupSubGroupMap.get(accountId).Group_Sub_Group__r.Group_Lookup__c;
        groupSubGroupTranNew.Sub_Group_Lookup__c = customerGroupSubGroupMap.get(accountId).Group_Sub_Group__r.Sub_Group_Lookup__c;
        groupSubGroupTranNew.Group_Sub_Group_Lookup__c = customerGroupSubGroupMap.get(accountId).Group_Sub_Group__c;
        groupSubGroupTranNew.Customer_Group_Sub_Group__c = customerGroupSubGroupMap.get(accountId).Id;
        groupSubGroupTranNew.External_ID__c = customerGroupSubGroupMap.get(accountId).Customer__r.CIS__c + ':'+sortName+':'+ objectId;
        groupSubGroupTranNew.OwnerId = customerGroupSubGroupMap.get(accountId).OwnerId;
        groupSubGroupTransactionList.add(groupSubGroupTranNew);
        //accountsClearFlagIdSet.add(customerGroupSubGroupMap.get(accountId).Customer__c);
    }
    
}