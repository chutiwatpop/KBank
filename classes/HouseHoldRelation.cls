public class HouseHoldRelation implements ICustomerRelation {
	private Map<String, SLL_Relation__c> houseHoldRelationMap;
	private Id houseHoldRecordTypeId;
	private List<Application_Log__c> errorLogList;
	private Map<String, List<String>> knownErrorMessages;

	public HouseHoldRelation(Id houseHoldRecordTypeId, List<Application_Log__c> errorLogList) {
		houseHoldRelationMap = new Map<String, SLL_Relation__c>();
		this.houseHoldRecordTypeId = houseHoldRecordTypeId;
		this.errorLogList = errorLogList;
		knownErrorMessages = new Map<String, List<String>>();
	}

	public void addRelationToList(SLL_Relation__c sllItem) {
		if (sllItem.Subject_Type_Code__c == 'I' && sllItem.Object_Type_Code__c == 'I' && 
			HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Subject_Relation_Code__c) && 
			HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Object_Relation_Code__c)) {
			houseHoldRelationMap.put(sllItem.SLL_ExternalId__c, sllItem);
		}
	}

	public void insertRelation(Map<String, Account> customerSllInfo) {
		if (houseHoldRelationMap.size() > 0) {
			Map<String, Account> houseHoldRecords = createHouseHold(customerSllInfo);
			addMemberToHouseHold(houseHoldRecords, customerSllInfo);
		}
	}

	public Map<String, SLL_Relation__c> getSllRelationMapAfterAddRelation() {
		return houseHoldRelationMap;
	}

	private Map<String, Account> createHouseHold(Map<String, Account> customerSllInfo) {
		Map<String, Account> houseHoldRecords = new Map<String, Account>();
		
		for (String sllExternalId : houseHoldRelationMap.keySet()) {
			SLL_Relation__c sllItem = houseHoldRelationMap.get(sllExternalId);
			if (houseHoldRecords.containsKey(sllItem.Subject_CIS_ID__c) == false) {
				Account customerInfo = customerSllInfo.get(sllItem.Subject_CIS_ID__c);
				Account houseHoldRecordPerson = new Account();
				houseHoldRecordPerson.RecordTypeId = houseHoldRecordTypeId;
				houseHoldRecordPerson.Name = getHouseHoldName(customerInfo);
				houseHoldRecordPerson.CIS__c = 'H_' + sllItem.Subject_CIS_ID__c;
				houseHoldRecords.put(sllItem.Subject_CIS_ID__c, houseHoldRecordPerson);
			}
		}
		
		List<Database.UpsertResult> results = Database.upsert(houseHoldRecords.values(), Account.Fields.CIS__c, false);
		generateErrorLog(results);

		return houseHoldRecords;
	}

	private String getHouseHoldName(Account customerInfo) {
		String name;

		if (!String.isEmpty(customerInfo.Encrypt_Name_TH__c) && !String.isEmpty(customerInfo.Encrypt_Surname_TH__c)) {
			name = 'บ้านคุณ' + customerInfo.Encrypt_Name_TH__c + ' ' + customerInfo.Encrypt_Surname_TH__c;
		} else if (!String.isEmpty(customerInfo.Encrypt_Name_EN__c) && !String.isEmpty(customerInfo.Encrypt_Surname_EN__c)) {
			name = customerInfo.Encrypt_Name_EN__c + ' ' + customerInfo.Encrypt_Surname_EN__c + ' Household';
		} else {
			name = customerInfo.CIS__c;
		}

		return name;
	}

	private void addMemberToHouseHold(Map<String, Account> houseHoldRecords, Map<String, Account> customerSllInfo) {
		List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
		Map<String, List<String>> subjectRoles = new Map<String, List<String>>();

		for (String sllExternalId : houseHoldRelationMap.keySet()) {
			SLL_Relation__c sllItem = houseHoldRelationMap.get(sllExternalId);
			if (isRelationValid(sllItem)) {
				if (subjectRoles.containsKey(sllItem.Subject_CIS_ID__c) == true) {
					List<String> roles = subjectRoles.get(sllItem.Subject_CIS_ID__c);
					if (roles.contains(HouseHoldManager.getInstance().getRelationDescription(sllItem.Subject_Relation_Code__c)) == false) {
						subjectRoles.get(sllItem.Subject_CIS_ID__c).add(HouseHoldManager.getInstance().getRelationDescription(sllItem.Subject_Relation_Code__c));
					}
				} else {
					List<String> roles = new List<String>();
					roles.add(HouseHoldManager.getInstance().getRelationDescription(sllItem.Subject_Relation_Code__c));
					subjectRoles.put(sllItem.Subject_CIS_ID__c, roles);
				}

				// Add all object member to subject's house hold
				if (isRelationValid(customerSllInfo, sllItem) == true) {
					addAccountContactToList(accountContactRelations, houseHoldRecords.get(sllItem.Subject_CIS_ID__c).Id, 
						customerSllInfo.get(sllItem.Object_CIS_ID__c).PersonContactId, 
						HouseHoldManager.getInstance().getRelationDescription(sllItem.Object_Relation_Code__c), sllItem.SLL_ExternalId__c);
				}
			}
		}

		// Add all subject member to house hold
		for (String subjectCisId : subjectRoles.keySet()) {
			if (isRelationValid(customerSllInfo.get(subjectCisId)) == true) {
				addAccountContactToList(accountContactRelations, houseHoldRecords.get(subjectCisId).Id, 
					customerSllInfo.get(subjectCisId).PersonContactId, String.join(subjectRoles.get(subjectCisId), ';'), '');
			}
		}

		Database.SaveResult[] saveResult = Database.insert(accountContactRelations, false);
		generateErrorLog(saveResult);
		setIsRelationGeneratedFlag(accountContactRelations);
	}

	private void setIsRelationGeneratedFlag(List<AccountContactRelation> accountContactRelations) {
		for (AccountContactRelation accountContactRelation : accountContactRelations) {
			if (accountContactRelation.Id != null && accountContactRelation.SLL_ExternalId__c != null) {
				if (houseHoldRelationMap.containsKey(accountContactRelation.SLL_ExternalId__c)) {
					houseHoldRelationMap.get(accountContactRelation.SLL_ExternalId__c).Is_Relation_Generated__c = true;
				}
			}
		}
	}

	private void addAccountContactToList(List<AccountContactRelation> accountContactRelations, String accountId, String personContactId, String roles, String sllExternalId) {
		AccountContactRelation accountContact = new AccountContactRelation();
		accountContact.AccountId = accountId;
		accountContact.ContactId = personContactId;
		accountContact.Roles = roles;
		accountContact.SLL_ExternalId__c = sllExternalId;
		accountContact.Is_Createby_Integration__c = true;
		accountContactRelations.add(accountContact);
	}

	private Boolean isRelationValid(Map<String, Account> customerSllInfoMap, SLL_Relation__c sllItem) {
		Boolean isRelationValid = true;

		if (!customerSllInfoMap.containsKey(sllItem.Object_CIS_ID__c)) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_5, sllItem.Id);
		}

		if (isRelationValid) {
			Account customerSllInfo = customerSllInfoMap.get(sllItem.Object_CIS_ID__c);
			isRelationValid = isRelationValid(customerSllInfo);
		}

		return isRelationValid;
	}

	private Boolean isRelationValid(Account customerSllInfo) {
		Boolean isRelationValid = true;
		
		if (String.isEmpty(customerSllInfo.PersonContactId) == true) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_4, customerSllInfo.Id);
		}

		return isRelationValid;
	}

	private Boolean isRelationValid(SLL_Relation__c sllItem) {
		Boolean isRelationValid = true;

		if(sllItem.Subject_CIS_ID__c == sllItem.Object_CIS_ID__c) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_1, sllItem.Id);
		}

		return isRelationValid;
	}

	private void putKnownError(String errorCode, Id errorRecordId) {
		if(!knownErrorMessages.containsKey(errorCode)) {
			knownErrorMessages.put(errorCode, new List<String>());
		}
		knownErrorMessages.get(errorCode).add(errorRecordId);
	}

	private void generateErrorLog(Database.SaveResult[] saveResult){
		if (knownErrorMessages.size() > 0) {
			errorLogList.add(GlobalUtility.generateKnownErrorLog(knownErrorMessages, 'HouseHoldRelation'));
		}
		errorLogList.addAll(GlobalUtility.generateLogResults(saveResult, 'HouseHoldRelation'));
	}

	private void generateErrorLog(Database.UpsertResult[] upsertResult) {
		errorLogList.addAll(GlobalUtility.generateLogResults(upsertResult, 'HouseHoldRelation'));
	}
}