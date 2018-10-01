public class AccountAccountRelation implements ICustomerRelation  {
	private Map<String, SLL_Relation__c> accountAccountSllRelationMap;
	private List<FinServ__ReciprocalRole__c> reciprocalRolesList;
	private List<String> recordTypeOrganization;
	private List<Application_Log__c> errorLogList;
	private Map<String, List<String>> knownErrorMessages;

	public AccountAccountRelation(List<FinServ__ReciprocalRole__c> reciprocalRolesList, List<Id> recordTypeOrganization, List<Application_Log__c> errorLogList) {
		accountAccountSllRelationMap = new Map<String, SLL_Relation__c>();
		this.reciprocalRolesList = reciprocalRolesList;
		this.recordTypeOrganization = recordTypeOrganization;
		knownErrorMessages = new Map<String, List<String>>();
		this.errorLogList = errorLogList;
	}


	public void addRelationToList(SLL_Relation__c sllItem) {
		if (sllItem.Subject_Type_Code__c == 'O' && sllItem.Object_Type_Code__c == 'O' && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Subject_Relation_Code__c) && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Object_Relation_Code__c)) {
			accountAccountSllRelationMap.put(sllItem.SLL_ExternalId__c, sllItem);
		}
	}

	private FinServ__ReciprocalRole__c findReciprocalRole(String roleCode, String inverseRoleCode) {
		FinServ__ReciprocalRole__c expectedRole;
		for (FinServ__ReciprocalRole__c roleItem : reciprocalRolesList) {
			if (roleItem.Inverse_Role_Code__c == roleCode && roleItem.Role_Code__c == inverseRoleCode) {
				expectedRole = roleItem;
				break;
			}
		}

		return expectedRole;
	}

	public void insertRelation(Map<String, Account> customerSllInfo) {
		List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>();
		if (accountAccountSllRelationMap.size() > 0) {
			for (String sllExternalId : accountAccountSllRelationMap.keySet()) {
				SLL_Relation__c sllItem = accountAccountSllRelationMap.get(sllExternalId);
				if (isRelationValid(sllItem, customerSllInfo)) {
					FinServ__AccountAccountRelation__c accountAccountRelation = new FinServ__AccountAccountRelation__c();
					accountAccountRelation.FinServ__Role__c = findReciprocalRole(sllItem.Subject_Relation_Code__c, sllItem.Object_Relation_Code__c).Id;
					accountAccountRelation.FinServ__Account__c = customerSllInfo.get(sllItem.Subject_CIS_ID__c).Id;
					accountAccountRelation.FinServ__RelatedAccount__c = customerSllInfo.get(sllItem.Object_CIS_ID__c).Id;
					accountAccountRelation.Percent_Share__c = sllItem.Percent_Share__c;
					accountAccountRelation.SLL_ExternalId__c = sllItem.SLL_ExternalId__c;
					accountAccountRelation.Is_Createby_Integration__c = true;
					accountAccountRelationList.add(accountAccountRelation);
				}
			}
		}

		Database.SaveResult[] saveResult = Database.insert(accountAccountRelationList, false);
		generateErrorLog(saveResult);
		setIsRelationGeneratedFlag(accountAccountRelationList);
	}

	private void setIsRelationGeneratedFlag(List<FinServ__AccountAccountRelation__c> accountAccountRelationList) {
		for (FinServ__AccountAccountRelation__c accountAccountRelation : accountAccountRelationList) {
			if (accountAccountRelation.Id != null && accountAccountRelation.SLL_ExternalId__c != null) {
				if (accountAccountSllRelationMap.containsKey(accountAccountRelation.SLL_ExternalId__c)) {
					accountAccountSllRelationMap.get(accountAccountRelation.SLL_ExternalId__c).Is_Relation_Generated__c = true;
				}
			}
		}
	}

	public Boolean isRelationValid(SLL_Relation__c sllItem, Map<String, Account> customerSllInfo) {
		Boolean isRelationValid = true;

		if (!customerSllInfo.containsKey(sllItem.Subject_CIS_ID__c) || !customerSllInfo.containsKey(sllItem.Object_CIS_ID__c) || 
			sllItem.Subject_CIS_ID__c == sllItem.Object_CIS_ID__c || 
			!recordTypeOrganization.contains(customerSllInfo.get(sllItem.Subject_CIS_ID__c).RecordTypeId) ||
			!recordTypeOrganization.contains(customerSllInfo.get(sllItem.Object_CIS_ID__c).RecordTypeId)) {
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_2, sllItem.Id);
			isRelationValid = false;
		}

		if(sllItem.Subject_CIS_ID__c == sllItem.Object_CIS_ID__c) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_1, sllItem.Id);
		}

		return isRelationValid;
	}

	public Map<String, SLL_Relation__c> getSllRelationMapAfterAddRelation() {
		return accountAccountSllRelationMap;
	}

	private void putKnownError(String errorCode, Id errorRecordId) {
		if(!knownErrorMessages.containsKey(errorCode)) {
			knownErrorMessages.put(errorCode, new List<String>());
		}
		knownErrorMessages.get(errorCode).add(errorRecordId);
	}

	private void generateErrorLog(Database.SaveResult[] saveResult){
		if (knownErrorMessages.size() > 0) {
			errorLogList.add(GlobalUtility.generateKnownErrorLog(knownErrorMessages, 'AccountAccountRelation'));
		}
		errorLogList.addAll(GlobalUtility.generateLogResults(saveResult, 'AccountAccountRelation'));
	}
}