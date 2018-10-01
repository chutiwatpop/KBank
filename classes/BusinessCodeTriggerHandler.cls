public with sharing class BusinessCodeTriggerHandler extends TriggerHandler {
	
	public override void afterUpdate() {
		Map<Id,String> keyWordMapByBusinessCodeId = new Map<Id,String>();
		Map<Id,String> descriptionMapByBusinessCodeId = new Map<Id,String>();
		for(Business_Code__c eachBu : (List<Business_Code__c>)Trigger.new){
			Business_Code__c oldBu = (Business_Code__c)Trigger.oldMap.get(eachBu.id);
			if(oldBu.Keyword__c != eachBu.Keyword__c){
				keyWordMapByBusinessCodeId.put(eachBu.id,eachBu.Keyword__c);
			}
			if(oldBu.Business_Code_Description__c != eachBu.Business_Code_Description__c){
				descriptionMapByBusinessCodeId.put(eachBu.id,eachBu.Business_Code_Description__c);
			}
		}

		List<Customer_Business_Code__c> customerBusinessCodeList = [SELECT Id,Keyword_Text__c,Business_Code__c,Description_Text__c From Customer_Business_Code__c WHERE Business_Code__c IN :keyWordMapByBusinessCodeId.keySet() OR Business_Code__c IN :descriptionMapByBusinessCodeId.keySet()];
		if(!customerBusinessCodeList.isEmpty() ){
			for(Customer_Business_Code__c eachCustomerBusinessCode : customerBusinessCodeList){
				if(keyWordMapByBusinessCodeId.containsKey(eachCustomerBusinessCode.Business_Code__c)){
					eachCustomerBusinessCode.Keyword_Text__c = keyWordMapByBusinessCodeId.get(eachCustomerBusinessCode.Business_Code__c);
				}
				if(descriptionMapByBusinessCodeId.containsKey(eachCustomerBusinessCode.Business_Code__c)){
					eachCustomerBusinessCode.Description_Text__c = descriptionMapByBusinessCodeId.get(eachCustomerBusinessCode.Business_Code__c);
				}
			}

			if(customerBusinessCodeList.size() > 10000){
				Database.executeBatch(new SME_DML_Batch(customerBusinessCodeList));
			}else{
				update customerBusinessCodeList;
			}
		}
	}
}