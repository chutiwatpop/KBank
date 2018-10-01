global class SME_ActiveTargetListInitial_Batch implements Database.Batchable<sObject>{
	String query;
	public SME_ActiveTargetListInitial_Batch() {
		query = 'SELECT Id, Lead_Status__c, Lead_Type__c, Lead_Subtype__c, Status__c, Active_Target_List__c, CIS_ID_Prospect_Name__c FROM Target_List__c';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Target_List__c> scope) {
    	List<Target_List__c> updateTargetList = new List<Target_List__c>();
    	for(Target_List__c eachTarget : scope){
            System.debug('target type : '+eachTarget.Lead_Type__c);
            System.debug('target status : '+eachTarget.Status__c);
            System.debug('target Lead Status : '+eachTarget.Lead_Status__c);
            
    		if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_SALES || eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO || eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_INFORM || eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER || eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_FEEDBACK){
    			if(eachTarget.Status__c != GlobalConstants.REJECTED && eachTarget.Status__c != GlobalConstants.CANCEL_LEAD && eachTarget.Status__c != GlobalConstants.LEAD_EXPIRED && eachTarget.Status__c != GlobalConstants.AUTO_CLOSED && eachTarget.Status__c != GlobalConstants.DELETED_OPPORTUNITY){
                    eachTarget.Active_Target_List__c = eachTarget.CIS_ID_Prospect_Name__c;
                    updateTargetList.add(eachTarget);
                }else if(eachTarget.Status__c == GlobalConstants.REJECTED || eachTarget.Status__c == GlobalConstants.AUTO_CLOSED || eachTarget.Status__c == GlobalConstants.DELETED_OPPORTUNITY){
                    if(eachTarget.Lead_Status__c != GlobalConstants.CANCEL && eachTarget.Lead_Status__c != GlobalConstants.EXPIRED){
                        eachTarget.Active_Target_List__c = eachTarget.CIS_ID_Prospect_Name__c;
                        updateTargetList.add(eachTarget);
                    }
                }
    		}
      //      else if(eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_DO || eachTarget.Lead_Type__c == GlobalConstants.LEAD_TO_INFORM 
      //              || eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER || eachTarget.Lead_Type__c == GlobalConstants.LEAD_FOR_FEEDBACK){
      //          if(eachTarget.Lead_Status__c != GlobalConstants.EXPIRED && eachTarget.Lead_Status__c != GlobalConstants.CANCEL){
      //              eachTarget.Active_Target_List__c = eachTarget.CIS_ID_Prospect_Name__c;
      //              updateTargetList.add(eachTarget);
      //          }
    		//}
            else if(eachTarget.Lead_Type__c == GlobalConstants.CAMPAIGN){
                if(eachTarget.Status__c != GlobalConstants.REJECTED && eachTarget.Status__c != GlobalConstants.CANCEL_CAMPAIGN && eachTarget.Status__c != GlobalConstants.LEAD_EXPIRED && eachTarget.Status__c != GlobalConstants.AUTO_CLOSED && eachTarget.Status__c != GlobalConstants.DELETED_OPPORTUNITY){
                    eachTarget.Active_Target_List__c = eachTarget.CIS_ID_Prospect_Name__c;
                    updateTargetList.add(eachTarget);
                }else if(eachTarget.Status__c == GlobalConstants.REJECTED || eachTarget.Status__c == GlobalConstants.AUTO_CLOSED || eachTarget.Status__c == GlobalConstants.DELETED_OPPORTUNITY){
                    if(eachTarget.Lead_Status__c != GlobalConstants.CANCEL && eachTarget.Lead_Status__c != GlobalConstants.EXPIRED){
                        eachTarget.Active_Target_List__c = eachTarget.CIS_ID_Prospect_Name__c;
                        updateTargetList.add(eachTarget);
                    }
                }
    		}
    	}

    	TriggerHandler.bypass('TargetListTriggerHandler');
    	update updateTargetList;
    	TriggerHandler.clearBypass('TargetListTriggerHandler');
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}