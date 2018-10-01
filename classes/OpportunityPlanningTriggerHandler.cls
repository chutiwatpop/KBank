public without sharing class OpportunityPlanningTriggerHandler extends TriggerHandler {
//	public override void afterInsert() {
//		Set<Id> accountSet = new Set<Id>();
//		Map<Id, List<Opportunity_Planning__c>> oppPlanMapByAccount = new Map<Id, List<Opportunity_Planning__c>>();
//		for(Opportunity_Planning__c oppPlanning : (List<Opportunity_Planning__c>)Trigger.new) {
//			if(oppPlanning.Status__c != null &&  oppPlanning.CIS_ID__c != null && oppPlanning.Product_List_CBS__c != null) {
//				accountSet.add(oppPlanning.CIS_ID__c);
//				if(!oppPlanMapByAccount.containsKey(oppPlanning.CIS_ID__c))
//					oppPlanMapByAccount.put(oppPlanning.CIS_ID__c, new List<Opportunity_Planning__c>());
//				oppPlanMapByAccount.get(oppPlanning.CIS_ID__c).add(oppPlanning);
//			}
//		}
//		updateTargetListStatus(accountSet, oppPlanMapByAccount);
//	}

//	public override void afterUpdate() {
//		Map<Id, List<Opportunity_Planning__c>> oppPlanMapByAccount = new Map<Id, List<Opportunity_Planning__c>>();
//		Set<Id> accountSet = new Set<Id>();
//		Opportunity_Planning__c oldOppPlanning;
//		for(Opportunity_Planning__c newOppPlanning : (List<Opportunity_Planning__c>)Trigger.new) {
//			oldOppPlanning = (Opportunity_Planning__c) Trigger.oldMap.get(newOppPlanning.Id);
//			if((newOppPlanning.Status__c != oldOppPlanning.Status__c) || (newOppPlanning.Product_List_CBS__c != oldOppPlanning.Product_List_CBS__c)) {
//				accountSet.add(newOppPlanning.CIS_ID__c);
//				if(!oppPlanMapByAccount.containsKey(newOppPlanning.CIS_ID__c))
//					oppPlanMapByAccount.put(newOppPlanning.CIS_ID__c, new List<Opportunity_Planning__c>());
//				oppPlanMapByAccount.get(newOppPlanning.CIS_ID__c).add(newOppPlanning);
//			}
//		}
//		updateTargetListStatus(accountSet, oppPlanMapByAccount);
//	}

//	private void updateTargetListStatus(Set<Id> accountSet, Map<Id, List<Opportunity_Planning__c>> oppPlanMapByAccount) {

//        Set<String> oppStageNameSet = new Set<String>{
//            GlobalConstants.STOCK_NEGOTIATION,
//            GlobalConstants.CREATE_WRITE_UP,
//            GlobalConstants.WAITING_FOR_CREDIT_APPROVAL,
//            GlobalConstants.CREDIT_APPROVAL_PROCESS,
//            GlobalConstants.CASE_IS_REJECT,
//            GlobalConstants.WAITING_FOR_CREDIT_SETUP,
//            GlobalConstants.PARTIAL_LOAN_SETUP,
//            GlobalConstants.ALL_LOAN_SETUP,
//            GlobalConstants.CLOSE_LOST,
//            GlobalConstants.AUTO_CLOSED,
//            GlobalConstants.DELETED_OPPORTUNITY,
//            GlobalConstants.CLOSED_WON,
//            GlobalConstants.NEW_OPPORTUNITY
//        };

//        Set<String> closeOppPlanning = new Set<String>{
//            GlobalConstants.OPP_PLAN_LOST,
//            GlobalConstants.OPP_PLAN_CANCELLED,
//            GlobalConstants.OPP_PLAN_REJECTED,
//            GlobalConstants.OPP_PLAN_WIN_MANDATE
//        };
////Fix INC000000668026
//        Map<Id, Account> accountMap = new Map<Id, Account>(
//        	[SELECT Id, 
//        		(SELECT Id, Product_List_CBS__c, Status__c FROM Opportunities_Planning__r WHERE Status__c NOT IN :closeOppPlanning),
//        		(SELECT Id, Lead_Campaign__r.Product_List_CBS__c, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.OwnerId, Lead_Type__c, Status__c, Lead_Campaign__c,Lead_Campaign__r.Name,Lead_Campaign__r.Add_Associated_Lead__c,Lead_Campaign__r.Sub_Type__c, Lead_Campaign__r.Lead_Campaign_Event_Code__c, Lead_Campaign__r.Priority__c,Lead_Campaign__r.Priority_Group__c,Lead_Campaign__r.EndDate,Lead_Campaign__r.StartDate,Lead_Campaign__r.RecordType.DeveloperName,Approved_Amount__c, Setup_Amount__c,IsRespLeadToDo__c
//        			FROM Campaign_Members_Leads__r 
//        			WHERE Lead_Campaign__r.RecordType.DeveloperName = :GlobalConstants.CBS_LEAD_DEVNAME
//            		AND Lead_Type__c = :GlobalConstants.LEAD_FOR_SALES
//                    AND Status__c !=: GlobalConstants.REJECTED)
//        	FROM Account WHERE Id IN :accountSet]);

//        Map<Id, Target_List__c> updateTargetLists = new Map<Id, Target_List__c>();
//        for(Account eachAccount : accountMap.values()) {
//        	if(eachAccount.Campaign_Members_Leads__r.size() > 0 && oppPlanMapByAccount.containsKey(eachAccount.Id)) {
//        		for(Opportunity_Planning__c eachOppPlannning : oppPlanMapByAccount.get(eachAccount.Id)) {
//        			if(eachOppPlannning.Status__c != null && eachOppPlannning.Product_List_CBS__c != null) {
//	        			Set<String> oppPlannignProductSet = new Set<String>(eachOppPlannning.Product_List_CBS__c.split(','));
//	        			for(Target_List__c eachTarget : eachAccount.Campaign_Members_Leads__r) {
//	        				if(eachTarget.Lead_Campaign__r.Product_List_CBS__c != null) {
//	        					Set<String> campaingProductSet = new Set<String>(eachTarget.Lead_Campaign__r.Product_List_CBS__c.split(';'));
//			        			if(updateTargetLists.containsKey(eachTarget.Id)) {
//			        				eachTarget.Status__c = updateTargetLists.get(eachTarget.Id).Status__c;
//			        			}
//			        			System.debug('POP_DEBUG Opp Planning Status__c:' + eachOppPlannning.Status__c + ' Target List Status__c:' + eachTarget.Status__c);
//			        			System.debug('POP_DEBUG isUpdateTargetList:' + TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY_PLANNING,eachOppPlannning.Status__c,eachTarget.Status__c) + ' isInLead:' + GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppPlannignProductSet));

//			        			if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppPlannignProductSet)){
//						            String newStatus = eachOppPlannning.Status__c;
//									if(newStatus != GlobalConstants.OPP_PLAN_WIN_MANDATE && !oppStageNameSet.contains(eachTarget.Status__c)) {
//										if(accountMap.containsKey(eachOppPlannning.CIS_ID__c))
//				                            newStatus = getNewStatusForClosedOpportunityCBS(eachOppPlannning.Id, eachOppPlannning.CIS_ID__c, newStatus, campaingProductSet, accountMap);
//				                        eachTarget.Status__c = newStatus;
//				                        updateTargetLists.put(eachTarget.Id, eachTarget);
//				                        System.debug('POP_DEBUG withStatus:' + newStatus);
//									}
//						        }
//	        				}
//				        }
//	        		}
//        		}
//        	}
//        }
//        if(!updateTargetLists.isEmpty())
//        	update updateTargetLists.values();
//	}

//	//Get New Target List Status For Closed Opportunity CBS
//    private static String getNewStatusForClosedOpportunityCBS(Id currentId, Id accountId, String currentStatus, Set<String> campaingProductSet, Map<Id, Account> accountMap){
//        Account eachAccount = accountMap.get(accountId);
//        if(eachAccount.Opportunities_Planning__r != null)
//        for(Opportunity_Planning__c eachOppPlanning : eachAccount.Opportunities_Planning__r) {
//            if(eachOppPlanning.Product_List_CBS__c != null) {
//                Set<String> oppPlannignProductSet = new Set<String>(eachOppPlanning.Product_List_CBS__c.split(','));
                
//                System.debug('POP_DEBUG oldStatus:' + currentStatus + ' / eachOppPlanning:' + eachOppPlanning.Status__c);
//                System.debug('POP_DEBUG isUpdateTargetList:' + TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY_PLANNING, eachOppPlanning.Status__c, currentStatus) + ' isInLead:' + GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppPlannignProductSet));
//                if(GlobalUtility.isDataOfSetTwoInSetOne(campaingProductSet, oppPlannignProductSet) && 
//                    TargetList_Service.isNewStatusHasProgressEqualOrMoreThanTargetListStatusForCBS(TargetList_Service.STAGE_OPPORTUNITY_PLANNING, eachOppPlanning.Status__c, currentStatus)) {
//                    currentStatus = eachOppPlanning.Status__c;
//                }    
//            }
//        }

//        return currentStatus;
//    }
}