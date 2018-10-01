public with sharing class CustomerBusinessCodeTriggerHandler extends TriggerHandler {

	private Map<String,Decimal> customerBusinessCodeRatioMapByAccountId;
	private Map<String,Decimal> newCustomerBusinessCodeRatioMapByAccountId;
	private Map<Id,Account> accountMapById;
	private Map<Id,Business_Code__c> businessCodeMapById;

	public override void allBefore() {
		Decimal oldTotal;
		Decimal newTotal;
		Set<Id> businessCodeIdSet = new Set<Id>();
		Set<String> customerBusinessCodeIdList = new Set<String>();
		newCustomerBusinessCodeRatioMapByAccountId = new Map<String,Decimal>();
		for(Customer_Business_Code__c eachCustomerBusinessCode : (List<Customer_Business_Code__c>) Trigger.new) {
			oldTotal = 0;
			newTotal = 0;
			Decimal eachRatio = GlobalUtility.toDecimal(eachCustomerBusinessCode.Ratio__c);

			if(!businessCodeIdSet.contains(eachCustomerBusinessCode.Business_Code__c)){
				businessCodeIdSet.add(eachCustomerBusinessCode.Business_Code__c);
			}
			if(Trigger.oldMap != null && Trigger.oldMap.containsKey(eachCustomerBusinessCode.Id)){
				customerBusinessCodeIdList.add(eachCustomerBusinessCode.Id);
			}

			if(!newCustomerBusinessCodeRatioMapByAccountId.containsKey(eachCustomerBusinessCode.CIS__c)){
				newCustomerBusinessCodeRatioMapByAccountId.put(eachCustomerBusinessCode.CIS__c,eachRatio);
			}else{
				oldTotal = newCustomerBusinessCodeRatioMapByAccountId.get(eachCustomerBusinessCode.CIS__c);
				newCustomerBusinessCodeRatioMapByAccountId.put(eachCustomerBusinessCode.CIS__c,oldTotal+eachRatio);
			}
		}

		customerBusinessCodeRatioMapByAccountId = Customer_BusinessCode_Service.getTotalCustomerBusinessCodeRatioMapByAccountId(newCustomerBusinessCodeRatioMapByAccountId.keySet(),customerBusinessCodeIdList);
		for(Customer_Business_Code__c eachCustomerBusinessCode : (List<Customer_Business_Code__c>) Trigger.new){
			oldTotal = 0;
			newTotal = 0;
			if(customerBusinessCodeRatioMapByAccountId.containsKey(eachCustomerBusinessCode.CIS__c)){
				oldTotal = customerBusinessCodeRatioMapByAccountId.get(eachCustomerBusinessCode.CIS__c);
			}
			if(newCustomerBusinessCodeRatioMapByAccountId.containsKey(eachCustomerBusinessCode.CIS__c)){
				newTotal = newCustomerBusinessCodeRatioMapByAccountId.get(eachCustomerBusinessCode.CIS__c);
			}
			if( (GlobalUtility.toDecimal(oldTotal) + GlobalUtility.toDecimal(newTotal) ) > 100){
				eachCustomerBusinessCode.addError(ExceptionMessage.TOTAL_RATIO_MORE_THAN_100);
			}
		}

		accountMapById = new Map<Id,Account>([SELECT Id,CIS__c From Account WHERE id IN :newCustomerBusinessCodeRatioMapByAccountId.keySet()]);
		businessCodeMapById = new Map<Id,Business_Code__c>([SELECT Id,External_ID__c,Keyword__c,Business_Code_Description__c,Name From Business_Code__c WHERE Id IN :businessCodeIdSet]);
		
	}

	public override void beforeInsert(){
		for(Customer_Business_Code__c eachCustomerBusinessCode : (List<Customer_Business_Code__c>) Trigger.new){
			if(accountMapById.containsKey(eachCustomerBusinessCode.CIS__c) && businessCodeMapById.containsKey(eachCustomerBusinessCode.Business_Code__c)){
				String businessCodeExternalId = businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).External_ID__c;
				Account eachAccount = accountMapById.get(eachCustomerBusinessCode.CIS__c);
				eachCustomerBusinessCode.Name = businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Name;
				eachCustomerBusinessCode.External__c = Customer_BusinessCode_Service.generateExternalId(eachAccount,businessCodeExternalId);
				eachCustomerBusinessCode.KeyWord_text__c =  businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Keyword__c;
				eachCustomerBusinessCode.Description_text__c =  businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Business_Code_Description__c;
			}

		}
	}

	public override void beforeUpdate(){
		for(Customer_Business_Code__c eachCustomerBusinessCode : (List<Customer_Business_Code__c>) Trigger.new){
			Customer_Business_Code__c oldRecord = (Customer_Business_Code__c)Trigger.oldMap.get(eachCustomerBusinessCode.id);
			if(eachCustomerBusinessCode.Business_Code__c != oldRecord.Business_Code__c){
				if(accountMapById.containsKey(eachCustomerBusinessCode.CIS__c) && businessCodeMapById.containsKey(eachCustomerBusinessCode.Business_Code__c)){
					String businessCodeExternalId = businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).External_ID__c;
					Account eachAccount = accountMapById.get(eachCustomerBusinessCode.CIS__c);
					eachCustomerBusinessCode.Name = businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Name;
					eachCustomerBusinessCode.External__c = Customer_BusinessCode_Service.generateExternalId(eachAccount,businessCodeExternalId);
					eachCustomerBusinessCode.KeyWord_text__c =  businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Keyword__c;
					eachCustomerBusinessCode.Description_text__c = businessCodeMapById.get(eachCustomerBusinessCode.Business_Code__c).Business_Code_Description__c;
				}
			}
		}

	}

}