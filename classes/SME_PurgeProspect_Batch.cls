global class SME_PurgeProspect_Batch implements Database.Batchable<sObject> {
	
	String query;
	Datetime purgeDateTime;
	
	global SME_PurgeProspect_Batch() {
		this.initQuery(Integer.valueOf(Label.Purge_Prospect));
	}

	global SME_PurgeProspect_Batch(Integer purgeDays) {
		this.initQuery(purgeDays);
	}

	private void initQuery(Integer purgeDays) {		
      Date purgeDate = System.today() - purgeDays;
      this.purgeDateTime = Datetime.newInstance(purgeDate.year(), purgeDate.month(), purgeDate.day());
      String dateTimeFormat = purgeDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

		this.query = 'SELECT Id, CreatedDate, (SELECT Id FROM Customer_Ownership_Requests__r), (SELECT Id, LastModifiedDate FROM Tasks ORDER BY LastModifiedDate DESC LIMIT 1), (SELECT Id, LastModifiedDate FROM Opportunities ORDER BY LastModifiedDate DESC LIMIT 1), (SELECT Id, LastModifiedDate FROM Call_Reports__r ORDER BY LastModifiedDate DESC), (SELECT Id, CreatedDate, LastModifiedDate FROM Contacts ORDER BY LastModifiedDate DESC LIMIT 1), (SELECT Id, LastModifiedDate FROM Campaign_Members_Leads__r ORDER BY LastModifiedDate DESC LIMIT 1) FROM Account WHERE (RecordType.DeveloperName = \'Organization_Prospect\' OR RecordType.DeveloperName = \'INDIVIDUAL_PROSPECT_DEVNAME\') AND CreatedDate <= ' + dateTimeFormat;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		List<Customer_Ownership_Request__c> customerOwnershipList = new List<Customer_Ownership_Request__c>();
   		List<Call_Report__c> callReportList = new List<Call_Report__c>();

   		System.debug('purgeDateTime:' + purgeDateTime);

   		List<Account> accountDeleteList = new List<Account>();
   		for(Account eachObject : scope) {
   			if(eachObject.CreatedDate <= purgeDateTime
               && (eachObject.Tasks.size() == 0 || eachObject.Tasks[0].LastModifiedDate <= purgeDateTime)
   				&& (eachObject.Opportunities.size() == 0 || eachObject.Opportunities[0].LastModifiedDate <= purgeDateTime)
   				&& (eachObject.Contacts.size() == 0 || eachObject.Contacts[0].LastModifiedDate <= purgeDateTime)
   				&& (eachObject.Campaign_Members_Leads__r.size() == 0 || eachObject.Campaign_Members_Leads__r[0].LastModifiedDate <= purgeDateTime)
			) {
   				accountDeleteList.add(eachObject);

   				if(eachObject.Customer_Ownership_Requests__r != null)	
   					customerOwnershipList.addAll((List<Customer_Ownership_Request__c>) eachObject.Customer_Ownership_Requests__r);
   			}
   			
   		}
   		if(!customerOwnershipList.isEmpty())
   			delete customerOwnershipList;
   		if(!accountDeleteList.isEmpty())
			   delete accountDeleteList;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}