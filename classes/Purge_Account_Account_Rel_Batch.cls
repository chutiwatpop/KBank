global class Purge_Account_Account_Rel_Batch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    Boolean isOneTime = false;
	global Purge_Account_Account_Rel_Batch(){
	}

	global Purge_Account_Account_Rel_Batch(Boolean isOneTime){
		this.isOneTime = isOneTime;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id FROM FinServ__AccountAccountRelation__c';
		if(!isOneTime){
			query = query + ' WHERE Is_Createby_Integration__c = true';
		}
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<FinServ__AccountAccountRelation__c> listAccAccRel) {
		List<Database.DeleteResult> results = Database.delete(listAccAccRel,false);
		List<Application_Log__c> listErrorLog = new List<Application_Log__c>();
		for(Database.DeleteResult dr : results) {
			if (!dr.isSuccess()){
				Application_Log__c al = new Application_Log__c();
				Datetime dt = Datetime.now();
		        String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
		        al.Name = 'ALOG-'+formattedDt;
				al.Debug_Level__c = 'Error';
				al.Message__c = JSON.serialize(dr.getId()) +'-'+ JSON.serialize(dr.getErrors());
				al.Source__c = 'Purge_Account_Account_Rel_Batch';
				listErrorLog.add(al);
			} 
		}
		if(!listErrorLog.isEmpty()){
			System.enqueueJob(new ApplicationLog_Queue(listErrorLog));
		}
	}

	global void finish(Database.BatchableContext BC) {
		Database.executeBatch(new Purge_Contact_Contact_Rel_Batch(isOneTime));
	}
}