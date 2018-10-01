global class UpdateTaskDetail_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	public Map<Id,Campaign> mapLeadChangeFieldValueThatDependWithTask;
	
	global UpdateTaskDetail_Batch(Map<Id,Campaign> mapLeadChangeFieldValueThatDependWithTask) {
        System.debug('Start UpdateTaskDetail_Batch');
		this.mapLeadChangeFieldValueThatDependWithTask = mapLeadChangeFieldValueThatDependWithTask;
		List<Id> campaignIds = new List<Id>(mapLeadChangeFieldValueThatDependWithTask.keySet());
		query = 'SELECT Id,Type,Lead_Sub_Type__c,Subject,Priority,Priority_Group__c,ActivityDate,Start_Date__c,Lead_Campaign_Event__c FROM Task WHERE Lead_Campaign_Event__c IN (\'' + String.join(campaignIds,'\',\'')+'\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Task> listTask) {
		for(Task eachTask : listTask){
            Campaign lead = mapLeadChangeFieldValueThatDependWithTask.get(eachTask.Lead_Campaign_Event__c);
            if(eachTask.Subject != lead.Name){
                eachTask.Subject = lead.Name;
            }
            if(eachTask.Priority != lead.Priority__c){
                eachTask.Priority = lead.Priority__c == null?'-':lead.Priority__c;
            }
            if(eachTask.Priority_Group__c != lead.Priority_Group__c){
                eachTask.Priority_Group__c = lead.Priority_Group__c == null?'-':lead.Priority_Group__c;
            }
            if(eachTask.ActivityDate != lead.EndDate){
                eachTask.ActivityDate = lead.EndDate;
            }
            if(eachTask.Start_Date__c != lead.StartDate){
                eachTask.Start_Date__c = lead.StartDate;
            }
            if(eachTask.Type != lead.Type__c){
                eachTask.Type = lead.Type__c;
            }
            if(eachTask.Lead_Sub_Type__c != lead.Sub_Type__c){
                if(lead.Sub_Type__c == null){
                    eachTask.Lead_Sub_Type__c = lead.Sub_Type_CBS__c;
                }else{
                    eachTask.Lead_Sub_Type__c = lead.Sub_Type__c;
                }
            }
        }

        update listTask;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}