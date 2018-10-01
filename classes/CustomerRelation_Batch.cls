global class CustomerRelation_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	List<ICustomerRelation> customerRelation;
	List<Id> recordTypeList;
	String houseHoldRecordTypeId;
	List<FinServ__ReciprocalRole__c> reciprocalRoleAccountList;
	List<FinServ__ReciprocalRole__c> reciprocalRoleContactList;
	List<String> recordTypeOrganization;
	Boolean isOneTime = false;

	global CustomerRelation_Batch() {
		Map<String, Id> recordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        List<String> recordTypeDevNameList = new List<String> {'Organization_Prospect', 'Organization_Customer', 'Individual_Prospect', 'Individual_Customer'};
        recordTypeList = new List<Id>();
        for (String recordTypeDevNameItem : recordTypeDevNameList) {
            recordTypeList.add(recordTypeMap.get(recordTypeDevNameItem));
        }

		query = 'SELECT Id, CIS__c, Temporary_Customer__c FROM Account WHERE RecordTypeId IN :recordTypeList';
	}

	global CustomerRelation_Batch(Boolean isOneTime) {
		this.isOneTime = isOneTime;
		Map<String, Id> recordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        List<String> recordTypeDevNameList = new List<String> {'Organization_Prospect', 'Organization_Customer', 'Individual_Prospect', 'Individual_Customer'};
        recordTypeList = new List<Id>();
        for (String recordTypeDevNameItem : recordTypeDevNameList) {
            recordTypeList.add(recordTypeMap.get(recordTypeDevNameItem));
        }

        query = 'SELECT Id, CIS__c, Temporary_Customer__c FROM Account WHERE RecordTypeId IN :recordTypeList';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		final String RECORD_TYPE_ACCOUNT_ROLE = 'AccountRole';
		final String RECORD_TYPE_CONTACT_ROLE = 'ContactRole';
		final String RECORD_TYPE_HOUSEHOLD = 'IndustriesHousehold';
		final String RECORD_TYPE_ORG_PROSPECT = 'Organization_Prospect';
		final String RECORD_TYPE_ORG_CUST = 'Organization_Customer';
		Map<String, Id> accountRecordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		Map<String, Id> recordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('FinServ__ReciprocalRole__c');

		recordTypeOrganization = new List<String>();
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_PROSPECT));
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_CUST));
		houseHoldRecordTypeId = accountRecordTypeMap.get(RECORD_TYPE_HOUSEHOLD); 
		reciprocalRoleAccountList = new List<FinServ__ReciprocalRole__c>();
		reciprocalRoleContactList = new List<FinServ__ReciprocalRole__c>();
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = 
			[SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, RecordTypeId, Role_External_ID__c FROM FinServ__ReciprocalRole__c];
		for (FinServ__ReciprocalRole__c reciprocalRoleItem : reciprocalRoleList) {
			if (reciprocalRoleItem.RecordTypeId == recordTypeMap.get(RECORD_TYPE_ACCOUNT_ROLE)) {
				reciprocalRoleAccountList.add(reciprocalRoleItem);
			} else if (reciprocalRoleItem.RecordTypeId == recordTypeMap.get(RECORD_TYPE_CONTACT_ROLE)) {
				reciprocalRoleContactList.add(reciprocalRoleItem);
			}
		}
		
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		customerRelation = new List<ICustomerRelation>();
		if (isOneTime) {
			customerRelation.add(new HouseHoldRelation(houseHoldRecordTypeId, errorLogList));
		}
		customerRelation.add(new AccountAccountRelation(reciprocalRoleAccountList, recordTypeOrganization, errorLogList));
		customerRelation.add(new AccountContactRelationManager(errorLogList));
		customerRelation.add(new ContactContactRelation(reciprocalRoleContactList, errorLogList));

		// Create list of CIS_c
        List<String> sllCisId = new List<String>();
        for (Account customer : scope) {
            if (customer.Temporary_Customer__c == false && customer.CIS__c != null) {
                sllCisId.add(customer.CIS__c);
            }
        }
		   
		// Query all SLL record that related with user account
		List<SLL_Relation__c> sllList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, 
			Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, Is_Relation_Generated__c, SLL_ExternalId__c FROM SLL_Relation__c WHERE Is_Relation_Generated__c = false AND Subject_CIS_ID__c IN :sllCisId ORDER BY Subject_CIS_ID__c];
		List<String> sllCustomerCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllList) {
			addItemToSllCustomerCisId(sllCustomerCisId, sllItem.Subject_CIS_ID__c);
			addItemToSllCustomerCisId(sllCustomerCisId, sllItem.Object_CIS_ID__c);
		}

		List<Account> customerSllInfoList = [SELECT  Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, Encrypt_Name_EN__c, Encrypt_Surname_EN__c, PersonContactId, RecordTypeId FROM Account WHERE CIS__c IN :sllCustomerCisId];

		Map<String, Account> customerSllInfo = new Map<String, Account>();
		// Loop all data from Account that valid
		for (Account customer : customerSllInfoList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}

		generateCustomerRelationList(sllList);

		// Insert 
		for (ICustomerRelation relation : customerRelation) {
			relation.insertRelation(customerSllInfo);
		}

		// Update customer relation flag after add relation 
		updateGeneratedFlagAfterInsertRelation(customerRelation);

		System.enqueueJob(new ApplicationLog_Queue(errorLogList));
	}

	private void updateGeneratedFlagAfterInsertRelation(List<ICustomerRelation> customerRelation) {
		Map<String, SLL_Relation__c> sllRelationMap = new Map<String, SLL_Relation__c>();

		for (ICustomerRelation relation : customerRelation) {
			sllRelationMap.putAll(relation.getSllRelationMapAfterAddRelation());
		}

		List<Database.SaveResult> results = Database.update(sllRelationMap.values(), false);
	}

	private void addItemToSllCustomerCisId(List<String> sllCustomerCisId, String cisId) {
		if (sllCustomerCisId.contains(cisId) == false) {
			sllCustomerCisId.add(cisId);
		}
	}

	private void generateCustomerRelationList(List<SLL_Relation__c> sllList) {
		for (SLL_Relation__c sllItem : sllList) {
			for (ICustomerRelation relation : customerRelation) {
				relation.addRelationToList(sllItem);
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}