public class JunctionService {
	private static Map<Id,Target_List__c> targetListCBSMap = new Map<Id,Target_List__c>();

	public void initialJunctionWithOpportunityId(Set<Id> opportunityIdLists){
		Map<Id,List<Junction__c>> opportunityJunctionListMap = new Map<Id,List<Junction__c>>();
		Map<Id,List<Target_List__c>> possibleTargetListMap  = new Map<Id,List<Target_List__c>>();
		Map<Id,List<OpportunityLineItem>> possibleOpportunityLineItemMap = new Map<Id,List<OpportunityLineItem>>();
		possibleTargetListMap = queryAllTargetListWithOpportunity(opportunityIdLists);
		opportunityJunctionListMap = queryJunctionWithOpportunityId(possibleTargetListMap.keySet());
		possibleOpportunityLineItemMap = queryOpportunityLineItemWithOpportunityId(possibleTargetListMap.keySet());
		deleteJunctionMap(opportunityJunctionListMap);
		calculateJunctionMap(possibleTargetListMap,possibleOpportunityLineItemMap);
	}

	private void deleteJunctionMap(Map<Id,List<Junction__c>> opportunityJunctionListMap){
		List<Junction__c> deleteJunctionList = new List<Junction__c>();
		for(Id eachOpportunityId : opportunityJunctionListMap.keySet()){
			for(Junction__c eachJunction : opportunityJunctionListMap.get(eachOpportunityId)){
				deleteJunctionList.add(eachJunction);
			}
		}
		if(deleteJunctionList.size() > 0) Delete deleteJunctionList;
	}

	private void calculateJunctionMap(Map<Id,List<Target_List__c>> possibleTargetListMap, Map<Id,List<OpportunityLineItem>> possibleOpportunityLineItemMap){
		List<Junction__c> newJunctionList = new List<Junction__c>();
		for(Id eachOpportunityId : possibleTargetListMap.keySet()){
			for(Target_List__c eachTargetList : possibleTargetListMap.get(eachOpportunityId)){
				Boolean isCountLead = true;
				if(possibleOpportunityLineItemMap.containsKey(eachOpportunityId)){
					for(OpportunityLineItem eachOpportunityLineItems : possibleOpportunityLineItemMap.get(eachOpportunityId)){
						newJunctionList.add(new Junction__c(Opportunity__c = eachOpportunityId,
															Target_List__c = eachTargetList.Id,
															Product__c = eachOpportunityLineItems.Product2Id,
															Application__c = eachOpportunityLineItems.Application__c == null ? eachOpportunityLineItems.Application_CBS__c : eachOpportunityLineItems.Application__c,
															Product_Result__c = eachOpportunityLineItems.Product_Results__c,
															Reasons__c = eachOpportunityLineItems.Reasons__c,
															VolumnLimit__c = eachOpportunityLineItems.Volume_Limit__c,
															FrontEnd_Fee__c = eachOpportunityLineItems.FrontEnd_Fee__c,
															Income__c = eachOpportunityLineItems.Income__c,
															Count_Lead__c = isCountLead));
						isCountLead = false;
					}
				}else{
					newJunctionList.add(new Junction__c(Opportunity__c = eachOpportunityId,
														Target_List__c = eachTargetList.Id,
														Count_Lead__c = isCountLead));
				}
			}
		}
		if(newJunctionList.size() > 0) Insert newJunctionList;
		if(newJunctionList.size() > 0 && targetListCBSMap.size() > 0) updateJunctionMappingOnOpportunity(newJunctionList,targetListCBSMap);
	}

	private void updateJunctionMappingOnOpportunity(List<Junction__c> newJunctionList, Map<Id,Target_List__c> targetListCBSMap){
		Map<Id,Opportunity> updateOpportunityMap = new Map<Id,Opportunity>();
		for(Junction__c tempJunction : newJunctionList){
			if(targetListCBSMap.containsKey(tempJunction.Opportunity__c)){
				updateOpportunityMap.put(tempJunction.Opportunity__c, new Opportunity(Id=tempJunction.Opportunity__c, Junction__c=tempJunction.Id));
			}
		}
		TriggerHandler.bypass('OpportunityTriggerHandler');
        Database.update(updateOpportunityMap.values());
    	TriggerHandler.clearBypass('OpportunityTriggerHandler');
	}

	private Map<Id,List<Junction__c>> queryJunctionWithOpportunityId(Set<Id> opportunityIdLists){
        Map<Id,List<Junction__c>> currentOpportunityJunctionMap = new Map<Id,List<Junction__c>>();
        List<Junction__c> currentJunctionList = [SELECT Id, Opportunity__c, Target_List__c, Product_Name__c, Application__c, Product__c, Product_Result__c, Reasons__c, VolumnLimit__c, FrontEnd_Fee__c, Income__c, Count_Lead__c FROM Junction__c WHERE Opportunity__c IN:opportunityIdLists];
        for(Junction__c eachJunction : currentJunctionList){
            if(currentOpportunityJunctionMap.containsKey(eachJunction.Opportunity__c)){
                currentOpportunityJunctionMap.get(eachJunction.Opportunity__c).add(eachJunction);
            }else{
                List<Junction__c> newJunctionList = new List<Junction__c>();
                newJunctionList.add(eachJunction);
                currentOpportunityJunctionMap.put(eachJunction.Opportunity__c , newJunctionList);
            }
        }
        return currentOpportunityJunctionMap;
    }

	private Map<Id,List<OpportunityLineItem>> queryOpportunityLineItemWithOpportunityId(Set<Id> opportunityIdLists){
        Map<Id,List<OpportunityLineItem>> possibleOpportunityLineItemMap = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> currentOpportunityLineItemList = [SELECT Id, OpportunityId, Product2Id, Application__c, Application_CBS__c, Product_Results__c, Reasons__c, Volume_Limit__c, FrontEnd_Fee__c, Income__c FROM OpportunityLineItem WHERE OpportunityId IN:opportunityIdLists];
        for(OpportunityLineItem eachOpportunityLineItem : currentOpportunityLineItemList){
            if(possibleOpportunityLineItemMap.containsKey(eachOpportunityLineItem.OpportunityId)){
                possibleOpportunityLineItemMap.get(eachOpportunityLineItem.OpportunityId).add(eachOpportunityLineItem);
            }else{
                List<OpportunityLineItem> newOpportunityLineItemList = new List<OpportunityLineItem>();
                newOpportunityLineItemList.add(eachOpportunityLineItem);
                possibleOpportunityLineItemMap.put(eachOpportunityLineItem.OpportunityId , newOpportunityLineItemList);
            }
        }
        return possibleOpportunityLineItemMap;
    }

	private Map<Id,List<Target_List__c>> queryAllTargetListWithOpportunity(Set<Id> opportunityIdLists){
		Map<Id,List<Target_List__c>> possibleTargetListMap  = new Map<Id,List<Target_List__c>>();
		List<Target_List__c> possibleTargetListWithOpportunity = new List<Target_List__c>();
		if(opportunityIdLists != null){
			possibleTargetListWithOpportunity = [SELECT Id, Opportunity__c, Opportunity__r.Owner.Segment__c FROM Target_List__c WHERE Opportunity__c IN:opportunityIdLists];
		}else{
			possibleTargetListWithOpportunity = [SELECT Id, Opportunity__c, Opportunity__r.Owner.Segment__c FROM Target_List__c WHERE Opportunity__c != null];
		}
		
		for(Target_List__c eachTargetList : possibleTargetListWithOpportunity){
			if(possibleTargetListMap.containsKey(eachTargetList.Opportunity__c)){
				possibleTargetListMap.get(eachTargetList.Opportunity__c).add(eachTargetList);
			}else{
				if(GlobalConstants.CBS_SEGMENT_CODE_SET.contains(eachTargetList.Opportunity__r.Owner.Segment__c)) targetListCBSMap.put(eachTargetList.Opportunity__c, eachTargetList);
				List<Target_List__c> tempTargetList = new List<Target_List__c>();
				tempTargetList.add(eachTargetList);
				possibleTargetListMap.put(eachTargetList.Opportunity__c, tempTargetList);
			}
		}
		return possibleTargetListMap;
	}
}