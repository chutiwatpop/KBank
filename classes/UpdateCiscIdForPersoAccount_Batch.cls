global class UpdateCiscIdForPersoAccount_Batch implements Database.Batchable<sObject> {
	
	String query;
	List<Database.SaveResult> results = null;
	
	global UpdateCiscIdForPersoAccount_Batch() {
		//Retrieve all pending contact-contact
		List<Contact> noCisIdContacts = [SELECT Id From Contact where CIS__c = Null or CIS__c = ''];
		//noCisIdContacts 170956 records
		List<String> noCisIdStrings = new List<String>();
		for (Contact contacts : noCisIdContacts){
			noCisIdStrings.add(contacts.Id);
		}
		query = 'select FinServ__Contact__c, FinServ__RelatedContact__c from FinServ__ContactContactRelation__c where FinServ__RelatedContact__c IN (\'' + String.join(noCisIdStrings,'\',\'') + '\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<FinServ__ContactContactRelation__c> scope) {
		Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();
		Contact baseContact = null;
		Contact relatedContact = null;
		for (FinServ__ContactContactRelation__c rel : scope) {
			baseContact = new Contact(Id=rel.FinServ__Contact__c);
			relatedContact = new Contact(Id=rel.FinServ__RelatedContact__c);

			relatedContact.CIS__c = baseContact.AccountId;

			contactToUpdate.put(rel.FinServ__RelatedContact__c, relatedContact);
		}

		results = Database.update(contactToUpdate.values(), false);
	}
	
	global void finish(Database.BatchableContext BC) {
		if(results != null && results.size() > 0){
			System.debug('CIS_ID has been updated for {'+results.size()+'} contacts.');
		} else {
			System.debug('CIS_ID flag has not been updated.');
		}
	}
	
}