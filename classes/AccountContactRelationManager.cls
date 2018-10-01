public class AccountContactRelationManager implements ICustomerRelation  {
	private Map<String, SLL_Relation__c> accountContactSllRelationMap = new Map<String, SLL_Relation__c>();
	private List<Application_Log__c> errorLogList;
	private Map<String, List<String>> knownErrorMessages;

	public AccountContactRelationManager(List<Application_Log__c> errorLogList) {
		knownErrorMessages = new Map<String, List<String>>();
		this.errorLogList = errorLogList;
	}

	public void addRelationToList(SLL_Relation__c sllItem) {
		if ((sllItem.Subject_Type_Code__c != sllItem.Object_Type_Code__c) && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Subject_Relation_Code__c) && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Object_Relation_Code__c)) {
			accountContactSllRelationMap.put(sllItem.SLL_ExternalId__c, sllItem);
		}
	}

	public void insertRelation(Map<String, Account> customerSllInfo) {
		
		Map<String,AccountContactRelation> accountContactRelationMap = new Map<String,AccountContactRelation>();
		if (accountContactSllRelationMap.size() > 0) {
			for (String sllExternalId : accountContactSllRelationMap.keySet()) {
				SLL_Relation__c sllItem = accountContactSllRelationMap.get(sllExternalId);
				if(HouseHoldManager.getInstance().hasExistRole(sllItem.Subject_Relation_Code__c) && HouseHoldManager.getInstance().hasExistRole(sllItem.Object_Relation_Code__c) ){
					Id relatedAccountId;
					Id relatedContactId;
					String roleName;
					String externalKey;

					if (isRelationValid(sllItem, customerSllInfo) == true) {
						if(sllItem.Subject_Type_Code__c == 'I'){
							relatedAccountId = customerSllInfo.get(sllItem.Object_CIS_ID__c).Id;
							relatedContactId = customerSllInfo.get(sllItem.Subject_CIS_ID__c).PersonContactId;
							roleName =  HouseHoldManager.getInstance().getRelationDescription(sllItem.Subject_Relation_Code__c);
						}else{
							relatedAccountId = customerSllInfo.get(sllItem.Subject_CIS_ID__c).Id;
							relatedContactId = customerSllInfo.get(sllItem.Object_CIS_ID__c).PersonContactId;
							roleName =  HouseHoldManager.getInstance().getRelationDescription(sllItem.Object_Relation_Code__c);
						}

						externalKey = String.valueOf(relatedAccountId)+String.valueOf(relatedContactId);
						if(accountContactRelationMap.containsKey(externalKey)){
							accountContactRelationMap.get(externalKey).Roles = accountContactRelationMap.get(externalKey).Roles +';'+roleName;
						}else{
							AccountContactRelation accountContactRelation = new AccountContactRelation();
							accountContactRelation.AccountId = relatedAccountId;
							accountContactRelation.ContactId = relatedContactId;
							accountContactRelation.Roles = roleName;
							accountContactRelation.IsActive = true;
							accountContactRelation.FinServ__IncludeInGroup__c = false;
							accountContactRelation.FinServ__PrimaryGroup__c = false;
							accountContactRelation.FinServ__Primary__c = false;
							accountContactRelation.FinServ__Rollups__c = 'All';
							accountContactRelation.Is_Createby_Integration__c = true;
							accountContactRelation.Percent_Share__c = sllItem.Percent_Share__c;
							accountContactRelation.SLL_ExternalId__c = sllItem.SLL_ExternalId__c;
							accountContactRelationMap.put(externalKey, accountContactRelation);
						}
					}
				}
			}
		}

		Database.SaveResult[] saveResult = Database.insert(accountContactRelationMap.values(), false);
		System.debug('saveResult : ' + saveResult);
		generateErrorLog(saveResult);
		setIsRelationGeneratedFlag(accountContactRelationMap.values());
	}

	private void setIsRelationGeneratedFlag(List<AccountContactRelation> accountContactRelationList) {
		for (AccountContactRelation accountContactRelation : accountContactRelationList) {
			if (accountContactRelation.Id != null && accountContactRelation.SLL_ExternalId__c != null) {
				if (accountContactSllRelationMap.containsKey(accountContactRelation.SLL_ExternalId__c)) {
					accountContactSllRelationMap.get(accountContactRelation.SLL_ExternalId__c).Is_Relation_Generated__c = true;
				}
			}
		}
	}


	public Map<String, SLL_Relation__c> getSllRelationMapAfterAddRelation() {
		return accountContactSllRelationMap;
	}

	private Boolean isRelationValid(SLL_Relation__c sllItem, Map<String, Account> customerSllInfo) {
		Boolean isRelationValid = true;

		if(sllItem.Subject_CIS_ID__c == sllItem.Object_CIS_ID__c) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_1, sllItem.Id);
		}

		if ((!customerSllInfo.containsKey(sllItem.Subject_CIS_ID__c)) || (!customerSllInfo.containsKey(sllItem.Object_CIS_ID__c))) {
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_2, sllItem.Id);
			isRelationValid = false;
		}
		if (isRelationValid && ((sllItem.Subject_Type_Code__c == 'I' && String.isEmpty(customerSllInfo.get(sllItem.Subject_CIS_ID__c).PersonContactId) == true) ||
			(sllItem.Object_Type_Code__c == 'I' && String.isEmpty(customerSllInfo.get(sllItem.Object_CIS_ID__c).PersonContactId) == true))) {
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_3, sllItem.Id);
			isRelationValid = false;
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
			errorLogList.add(GlobalUtility.generateKnownErrorLog(knownErrorMessages, 'AccountContactRelationManager'));
		}
		errorLogList.addAll(GlobalUtility.generateLogResults(saveResult, 'AccountContactRelationManager'));
	}
}