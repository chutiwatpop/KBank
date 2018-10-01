public class ContactContactRelation implements ICustomerRelation  {
	private Map<String, SLL_Relation__c> contactContactSllRelationMap;
	private List<FinServ__ReciprocalRole__c> reciprocalRolesList;
	private List<Application_Log__c> errorLogList;
	private Map<String, List<String>> knownErrorMessages;

	public ContactContactRelation(List<FinServ__ReciprocalRole__c> reciprocalRolesList, List<Application_Log__c> errorLogList) {
		contactContactSllRelationMap = new Map<String, SLL_Relation__c>();
		this.reciprocalRolesList = reciprocalRolesList;
		this.errorLogList = errorLogList;
		knownErrorMessages = new Map<String, List<String>>();
	}

	public void addRelationToList(SLL_Relation__c sllItem) {
		if (sllItem.Subject_Type_Code__c == 'I' && sllItem.Object_Type_Code__c == 'I' && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Subject_Relation_Code__c) && 
			!HouseHoldManager.getInstance().isHouseHoldCode(sllItem.Object_Relation_Code__c)) {
			contactContactSllRelationMap.put(sllItem.SLL_ExternalId__c, sllItem);
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
		List<FinServ__ContactContactRelation__c> contactContactRelationList = new List<FinServ__ContactContactRelation__c>();
		if (contactContactSllRelationMap.size() > 0) {
			for (String sllExternalId : contactContactSllRelationMap.keySet()) {
				SLL_Relation__c sllItem = contactContactSllRelationMap.get(sllExternalId);
				if (isRelationValid(sllItem, customerSllInfo) == true && sllItem.Subject_CIS_ID__c != sllItem.Object_CIS_ID__c) {
					FinServ__ContactContactRelation__c contactContactRelation = new FinServ__ContactContactRelation__c();
					contactContactRelation.FinServ__Role__c = findReciprocalRole(sllItem.Subject_Relation_Code__c, sllItem.Object_Relation_Code__c).Id;
					contactContactRelation.FinServ__Contact__c = customerSllInfo.get(sllItem.Subject_CIS_ID__c).PersonContactId;
					contactContactRelation.FinServ__RelatedContact__c = customerSllInfo.get(sllItem.Object_CIS_ID__c).PersonContactId;
					contactContactRelation.Is_Createby_Integration__c = true;
					contactContactRelation.SLL_ExternalId__c = sllItem.SLL_ExternalId__c;
					contactContactRelationList.add(contactContactRelation);
				}
			}
		}

		Database.SaveResult[] saveResult = Database.insert(contactContactRelationList, false);
		generateErrorLog(saveResult);
		setIsRelationGeneratedFlag(contactContactRelationList);
	}

	private void setIsRelationGeneratedFlag(List<FinServ__ContactContactRelation__c> contactContactRelationList) {
		for (FinServ__ContactContactRelation__c contactContactRelation : contactContactRelationList) {
			if (contactContactRelation.Id != null && contactContactRelation.SLL_ExternalId__c != null) {
				if (contactContactSllRelationMap.containsKey(contactContactRelation.SLL_ExternalId__c)) {
					contactContactSllRelationMap.get(contactContactRelation.SLL_ExternalId__c).Is_Relation_Generated__c = true;
				}
			}
		}
	}

	public Map<String, SLL_Relation__c> getSllRelationMapAfterAddRelation() {
		return contactContactSllRelationMap;
	}

	private Boolean isRelationValid(SLL_Relation__c sllItem, Map<String, Account> customerSllInfo) {
		Boolean isRelationValid = true;
		
		if(sllItem.Subject_CIS_ID__c == sllItem.Object_CIS_ID__c) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_1, sllItem.Id);
		}
		if (isRelationValid && (!customerSllInfo.containsKey(sllItem.Subject_CIS_ID__c)) || (!customerSllInfo.containsKey(sllItem.Object_CIS_ID__c))) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_2, sllItem.Id);
		}
		if (isRelationValid && (String.isEmpty(customerSllInfo.get(sllItem.Subject_CIS_ID__c).PersonContactId) == true ||
			String.isEmpty(customerSllInfo.get(sllItem.Object_CIS_ID__c).PersonContactId) == true)) {
			isRelationValid = false;
			putKnownError(GlobalConstants.KNOWN_ERR_CC_CODE_3, sllItem.Id);
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
			errorLogList.add(GlobalUtility.generateKnownErrorLog(knownErrorMessages, 'ContactContactRelation'));
		}
		errorLogList.addAll(GlobalUtility.generateLogResults(saveResult, 'ContactContactRelation'));
	}
}